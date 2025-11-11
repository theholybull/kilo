#!/usr/bin/env python3
import os, json, subprocess, urllib.parse, time, socket
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

PORT=7861
ENV=Path("/etc/kilo/personality.env")
CFG=Path("/etc/kilo/personality.json")
TRIG=Path("/etc/kilo/personality_triggers.json")
SNAPS=Path("/var/lib/kilo/snaps")

# ---------- helpers ----------
def env_get():
    d={}
    if ENV.exists():
        for ln in ENV.read_text().splitlines():
            if "=" in ln and not ln.strip().startswith("#"):
                k,v=ln.split("=",1); d[k.strip()]=v.strip()
    return d

def cfg_get():
    base={"snark_level":2,"wake_words":["kilo","hey kilo"],"eyes_url":"http://localhost:7007","offline_ok":True,
          "allow_actuation":False,"tts_mode":"online","piper_model":"/opt/piper/en_US-amy-medium.onnx"}
    try: base.update(json.loads(CFG.read_text()))
    except: pass
    return base

def cfg_set(obj):
    tmp=CFG.with_suffix(".tmp"); tmp.write_text(json.dumps(obj,indent=2)); os.chmod(tmp,0o644)
    subprocess.run(["sudo","-n","install","-m","644",str(tmp),str(CFG)], check=False)

def sh(cmd, sudo=False, timeout=10):
    if sudo and os.geteuid()!=0: cmd=["sudo","-n"]+cmd
    try:
        r=subprocess.run(cmd,capture_output=True,text=True,timeout=timeout)
        return (r.returncode, r.stdout.strip(), r.stderr.strip())
    except subprocess.TimeoutExpired:
        return (124,"","timeout")

def _sys_i2c_has(addr_hex="40"):
    # look for 1-00xx under /sys/bus/i2c/devices
    root=Path("/sys/bus/i2c/devices"); patt=f"1-00{addr_hex.lower()}"
    return any(p.name.lower()==patt for p in root.glob("1-00*"))

def _lsusb_has(vid="03e7"):
    c,o,_=sh(["/usr/bin/lsusb"]); 
    return (c==0 and any(vid.lower() in ln.lower() for ln in o.splitlines()))

def _connect_viam():
    # connect on demand for servo ops; robust to older/newer SDKs
    try:
        from viam.robot.client import RobotClient
        from viam.rpc.dial import DialOptions
    except Exception as e:
        return (None, f"viam sdk not available: {e}")
    e=env_get()
    addr=e.get("VIAM_ADDRESS"); kid=e.get("VIAM_API_KEY_ID"); key=e.get("VIAM_API_KEY")
    if not (addr and kid and key): return (None,"missing VIAM_* env")
    try:
        import inspect, asyncio
        sig=__import__("inspect").signature(RobotClient.at_address)
        if "dial_options" in sig.parameters:
            dial=DialOptions.with_api_key(key, kid)
            r=asyncio.get_event_loop().run_until_complete(RobotClient.at_address(addr, dial_options=dial))
        elif "options" in sig.parameters:
            r=asyncio.get_event_loop().run_until_complete(RobotClient.at_address(addr, RobotClient.Options.with_api_key(key, kid)))
        else:
            r=asyncio.get_event_loop().run_until_complete(RobotClient.at_address(addr, RobotClient.Options.with_api_key(key, kid)))
        return (r, None)
    except Exception as e:
        return (None, str(e))

def _piper_say(text, model):
    # echo TEXT | piper -m MODEL -f /tmp/kilo_tts.wav && aplay it
    if not text.strip(): return "empty text"
    if not Path(model).exists(): return f"piper model missing: {model}"
    if not shutil.which("piper"): return "piper not installed"
    wav="/tmp/kilo_tts.wav"
    p=subprocess.Popen(["/usr/bin/piper","-m",model,"-f",wav], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    p.communicate(text)
    if p.returncode!=0: return "piper error"
    # play if possible
    player=shutil.which("aplay") or shutil.which("paplay")
    if player: subprocess.run([player,wav],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    return "ok"

import shutil

HTML2='''<!doctype html><meta charset="utf-8"><title>Kilo Advanced</title>
<style>body{font-family:system-ui;margin:18px;max-width:980px}button{padding:8px 12px;margin:4px} section{border:1px solid #ddd;padding:12px;border-radius:8px;margin:10px 0}</style>
<h2>Kilo Advanced Control</h2>
<p><a href="http://localhost:7860" target=_blank>Open Basic UI</a></p>

<section>
<h3>Self-Check</h3>
<p><button onclick="run('selfcheck')">Run Self-Check</button></p>
<pre id=out_sc>(none)</pre>
</section>

<section>
<h3>ESC Calibration Helper</h3>
<label><input type=checkbox id=act> Allow actuation (I understand the risks)</label>
<p>
<select id=sv>
  <option>steering</option>
  <option>throttle</option>
</select>
<button onclick="servo(0)">Min (0°)</button>
<button onclick="servo(90)">Neutral (90°)</button>
<button onclick="servo(180)">Max (180°)</button>
</p>
<small>Procedure (recommended): set throttle to 180° → power ESC (beeps) → set 0° (beeps) → set 90° (neutral).</small>
<pre id=out_servo>(none)</pre>
</section>

<section>
<h3>Personality Triggers</h3>
<p>JSON array of <code>{ "pattern": "...", "reply": "..." }</code></p>
<textarea id=tr style="width:100%;height:180px"></textarea><br>
<button onclick="loadTrig()">Load</button>
<button onclick="saveTrig()">Save</button>
<button onclick="testSay()">Say test line (offline TTS if enabled)</button>
<pre id=out_tr>(none)</pre>
</section>

<section>
<h3>Eyes</h3>
<input id=ey style="width:420px"> 
<button onclick="eyes('open')">Open</button>
<button onclick="eyes('ping')">Ping</button>
<button onclick="eyes('start')">Start Service</button>
<button onclick="eyes('stop')">Stop Service</button>
<pre id=out_ey>(none)</pre>
</section>

<section>
<h3>Voice</h3>
<label>TTS mode: 
  <select id=tts_mode><option>online</option><option>offline</option></select>
</label>
<input id=tts_model style="width:420px" placeholder="/opt/piper/en_US-amy-medium.onnx">
<input id=tts_text style="width:420px" placeholder="Say something witty…">
<button onclick="say()">Speak</button>
<pre id=out_tts>(none)</pre>
</section>

<script>
async function J(u,opts){let r=await fetch(u,opts||{}); let t=await r.text(); try{return {ok:r.ok, data:JSON.parse(t)}}catch{return {ok:r.ok, data:t}}}
async function run(which){
  if(which==='selfcheck'){let r=await J('/api/selfcheck',{method:'POST'}); out_sc.textContent=(r.data.output||r.data); }
}
async function loadTrig(){
  let c=await J('/api/config'); ey.value=c.data.eyes_url||''; tts_mode.value=c.data.tts_mode||'online'; tts_model.value=c.data.piper_model||'';
  let r=await J('/api/triggers'); tr.value=JSON.stringify(r.data,null,2); out_tr.textContent='loaded';
}
async function saveTrig(){
  let arr=[]; try{arr=JSON.parse(tr.value)}catch(e){out_tr.textContent='bad JSON'; return}
  let r=await J('/api/triggers',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(arr)}); out_tr.textContent=(r.data||'saved');
  // persist cfg pieces too
  let cfg=await (await fetch('/api/config')).json(); cfg.eyes_url=ey.value; cfg.tts_mode=tts_mode.value; cfg.piper_model=tts_model.value;
  await fetch('/api/config',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(cfg)});
}
async function servo(pos){
  if(!act.checked){ out_servo.textContent='actuation disabled'; return }
  let name=document.getElementById('sv').value;
  let r=await J('/api/servo?name='+encodeURIComponent(name)+'&pos='+pos,{method:'POST'}); out_servo.textContent=(r.data||'ok');
}
async function eyes(action){
  let r=await J('/api/eyes?action='+action+'&url='+encodeURIComponent(ey.value||''),{method:'POST'}); out_ey.textContent=(r.data||'ok');
}
async function testSay(){
  let arr=[]; try{arr=JSON.parse(tr.value)}catch(e){out_tr.textContent='bad JSON'; return}
  let line = (arr[0] && arr[0].reply) ? arr[0].reply : "Testing, testing.";
  let r=await J('/api/say?text='+encodeURIComponent(line),{method:'POST'}); out_tr.textContent=(r.data||'ok');
}
async function say(){
  let r=await J('/api/say?text='+encodeURIComponent(tts_text.value||''),{method:'POST'}); out_tts.textContent=(r.data||'ok');
}
loadTrig();
</script>
'''

def selfcheck():
    out=[]
    e=env_get(); cfg=cfg_get()
    out.append(f"Time: {time.strftime('%F %T')}")
    out.append("Network: " + ", ".join({f"{i[4][0]}" for i in socket.getaddrinfo(socket.gethostname(), None)}))
    # DNS sanity
    host=e.get("VIAM_ADDRESS",""); 
    if host:
        c,o,_=sh(["getent","hosts",host])
        out.append(f"DNS {host}: {o or '(no record)'}")
        if o.startswith("10.") or " 10." in o: out.append("WARN: viam address resolves to private IP (expected if LAN-proxying).")
    # OAK, PCA, v4l
    out.append(f"OAK present (VID 03e7): { _lsusb_has('03e7') }")
    out.append(f"PCA9685 on I2C-1 @0x40: { _sys_i2c_has('40') }")
    cams=[]
    v4dir=Path("/dev/v4l/by-id")
    if v4dir.exists(): cams=[p.name for p in v4dir.glob("*-video-index0")]
    out.append("Video nodes: " + (", ".join(cams) if cams else "(none)"))
    # viam quick connect
    ok="skip"; err=""
    try:
        r,err=_connect_viam()
        if r:
            names=sorted(getattr(n,"name",str(n)) for n in r.resource_names)[:16]
            ok="ok: "+", ".join(names)
            import asyncio; asyncio.get_event_loop().run_until_complete(r.close())
        else:
            ok="fail"; 
    except Exception as ex:
        ok="fail"; err=str(ex)
    out.append("Viam connect: " + ok + (f" ({err})" if err else ""))
    # disk
    stat=os.statvfs("/")
    free_gb=stat.f_bavail*stat.f_frsize/1e9
    out.append(f"Disk free: {free_gb:.1f} GB")
    return "\n".join(out)

class H(BaseHTTPRequestHandler):
    def _send(self,code,body,ct="text/html"):
        b=body if isinstance(body,(bytes,bytearray)) else body.encode()
        self.send_response(code); self.send_header("Content-Type",ct); self.send_header("Content-Length",str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        if self.path=="/": return self._send(200,HTML2)
        if self.path=="/api/config": return self._send(200,json.dumps(cfg_get()),"application/json")
        if self.path=="/api/triggers":
            data=[]
            try: data=json.loads(TRIG.read_text())
            except: pass
            return self._send(200,json.dumps(data),"application/json")
        return self._send(404,"nope","text/plain")
    def do_POST(self):
        ln=int(self.headers.get("content-length","0") or 0)
        body=self.rfile.read(ln).decode() if ln else "{}"
        if self.path=="/api/selfcheck":
            return self._send(200,json.dumps({"output":selfcheck()}),"application/json")
        if self.path.startswith("/api/servo"):
            q=urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            name=(q.get("name") or [""])[0]; pos=int((q.get("pos") or ["0"])[0])
            if not cfg_get().get("allow_actuation",False): return self._send(403,"actuation disabled","text/plain")
            rob,err=_connect_viam()
            if not rob: return self._send(500,err,"text/plain")
            try:
                from viam.components.servo import Servo
                import asyncio
                s=Servo.from_robot(rob,name); asyncio.get_event_loop().run_until_complete(s.move(position=pos))
                asyncio.get_event_loop().run_until_complete(rob.close())
                return self._send(200,"ok","text/plain")
            except Exception as ex:
                return self._send(500,str(ex),"text/plain")
        if self.path=="/api/triggers":
            try:
                arr=json.loads(body); 
                TRIG.write_text(json.dumps(arr,indent=2)); os.chmod(TRIG,0o644)
                return self._send(200,"saved\n","text/plain")
            except Exception as ex:
                return self._send(500,str(ex),"text/plain")
        if self.path.startswith("/api/eyes"):
            q=urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            action=(q.get("action") or [""])[0]; url=(q.get("url") or [""])[0] or cfg_get().get("eyes_url","")
            if action=="open": 
                return self._send(200, f"Open: {url}\n","text/plain")
            if action=="ping":
                try:
                    import urllib.request
                    with urllib.request.urlopen(url,timeout=3) as r: 
                        return self._send(200, f"Ping {url}: {r.status}\n","text/plain")
                except Exception as ex:
                    return self._send(500, f"Ping failed: {ex}\n","text/plain")
            if action in ("start","stop"):
                unit="kilo-eyes.service"
                c,o,e=sh(["systemctl",action,unit],sudo=True)
                return self._send(200,(o+"\n"+e) or f"{action} {unit}\n","text/plain")
            return self._send(400,"bad action","text/plain")
        if self.path.startswith("/api/say"):
            q=urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            text=(q.get("text") or [""])[0]
            cfg=cfg_get()
            if cfg.get("tts_mode","online")=="offline":
                msg=_piper_say(text, cfg.get("piper_model",""))
                return self._send(200,msg,"text/plain")
            else:
                # If online, your viam-labs speech service should speak already;
                # we just ack here to keep UI responsive.
                return self._send(200,"online-speech-delegated\n","text/plain")
        if self.path=="/api/config":
            try: cfg_set(json.loads(body)); return self._send(200,"saved\n","text/plain")
            except Exception as ex: return self._send(500,str(ex)+"\n","text/plain")
        return self._send(404,"nope","text/plain")

if __name__=="__main__":
    SNAPS.mkdir(parents=True,exist_ok=True)
    HTTPServer(("0.0.0.0",PORT),H).serve_forever()
