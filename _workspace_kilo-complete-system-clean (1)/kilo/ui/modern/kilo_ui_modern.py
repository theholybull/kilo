#!/usr/bin/env python3
"""
Kilo Truck Modern UI System
Unified, remotely accessible web interface with Android integration
"""

import os
import json
import subprocess
import urllib.parse
import time
import socket
import threading
import asyncio
from pathlib import Path
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
import socketserver

# Configuration
PORT = 8080  # Main UI port
ENV = Path("/etc/kilo/personality.env")
CFG = Path("/etc/kilo/personality.json")
TRIG = Path("/etc/kilo/personality_triggers.json")
SNAPS = Path("/var/lib/kilo/snaps")
DOCS = Path("/opt/kilo/docs")
LEDGER = DOCS/"PROJECT_LEDGER.md"
MANUAL = DOCS/"README.md"
VIAM_COPY = DOCS/"viam_machine.json"
REMEMBER = DOCS/"CHAT_BOOTSTRAP.txt"
WANDER_LOG = Path("/var/log/kilo-wander.log")

# Android integration paths
ANDROID_DISCOVERY = "/opt/kilo/bin/discover-android-ip"
ANDROID_IMU_STATUS = "/tmp/android_imu_status.json"

USER = os.getenv("SUDO_USER") or os.getenv("USER") or "kilo"

SYSTEM_VIAM_CANDIDATES = [
    "/etc/viam/rdk/robot.json",
    "/etc/viam/robot.json", 
    "/etc/viam/viam.json",
    "/opt/viam/rdk/robot.json",
    "/opt/viam/robot.json",
]

class SystemManager:
    """System management utilities"""
    
    @staticmethod
    def env_get():
        d = {}
        if ENV.exists():
            for ln in ENV.read_text().splitlines():
                if "=" in ln and not ln.strip().startswith("#"):
                    k, v = ln.split("=", 1)
                    d[k.strip()] = v.strip()
        return d
    
    @staticmethod
    def sh(cmd, sudo=False, timeout=30):
        if isinstance(cmd, str):
            cmd = ["/bin/bash", "-lc", cmd]
            sudo = False
        if sudo and os.geteuid() != 0:
            cmd = ["sudo", "-n"] + cmd
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
            return (r.returncode, r.stdout.strip(), r.stderr.strip())
        except subprocess.TimeoutExpired:
            return (124, "", "timeout")
    
    @staticmethod
    def cfg_get():
        default = {
            "snark_level": 2,
            "wake_words": ["kilo", "hey kilo"],
            "eyes_url": "http://localhost:7007",
            "offline_ok": True,
            "allow_actuation": False,
            "tts_mode": "online",
            "piper_model": "/opt/piper/en_US-amy-medium.onnx",
            "android_phone_ip": "10.10.10.1",
            "android_port": "8080",
            "remote_access_enabled": False,
            "remote_access_port": "8080"
        }
        try:
            with open(CFG, 'r') as f:
                cfg = json.load(f)
                default.update(cfg)
                return default
        except:
            return default
    
    @staticmethod
    def cfg_set(obj):
        tmp = CFG.with_suffix(".tmp")
        tmp.write_text(json.dumps(obj, indent=2))
        os.chmod(tmp, 0o644)
        SystemManager.sh(["install", "-m", "644", str(tmp), str(CFG)], sudo=True)

class AndroidManager:
    """Android phone integration manager"""
    
    @staticmethod
    def discover_phone():
        """Discover Android phone on USB tethering network"""
        try:
            if Path(ANDROID_DISCOVERY).exists():
                code, out, err = SystemManager.sh([ANDROID_DISCOVERY])
                if code == 0 and out.strip():
                    return out.strip()
            
            # Fallback: scan common USB tethering network
            networks = ["192.168.42.0/24", "10.10.10.0/24"]
            for network in networks:
                code, out, err = SystemManager.sh(f"nmap -p 8080 --open -T4 {network} 2>/dev/null | grep '8080/open' | head -1")
                if out.strip():
                    ip = out.split()[0]
                    return ip
        except:
            pass
        return None
    
    @staticmethod
    def check_phone_health(ip):
        """Check if phone app is responding"""
        try:
            import urllib.request
            url = f"http://{ip}:8080/health"
            with urllib.request.urlopen(url, timeout=5) as response:
                return response.read().decode()
        except:
            return None
    
    @staticmethod
    def get_phone_imu(ip):
        """Get IMU data from phone"""
        try:
            import urllib.request
            url = f"http://{ip}:8080/imu"
            with urllib.request.urlopen(url, timeout=2) as response:
                return json.loads(response.read().decode())
        except:
            return None
    
    @staticmethod
    def get_phone_faces(ip):
        """Get face detection data from phone"""
        try:
            import urllib.request
            url = f"http://{ip}:8080/faces"
            with urllib.request.urlopen(url, timeout=2) as response:
                return json.loads(response.read().decode())
        except:
            return None
    
    @staticmethod
    def send_eyes_command(ip, emotion_type="emotion", emotion="happy"):
        """Send eyes command to phone"""
        try:
            import urllib.request
            url = f"http://{ip}:8080/eyes"
            data = json.dumps({"type": emotion_type, "emotion": emotion}).encode()
            req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=5) as response:
                return response.read().decode()
        except:
            return None

class StatusMonitor:
    """Real-time status monitoring"""
    
    def __init__(self):
        self.last_update = time.time()
        self.cache = {}
        self.cache_timeout = 5  # seconds
    
    def get_status(self, force_refresh=False):
        """Get comprehensive system status"""
        now = time.time()
        if force_refresh or now - self.last_update > self.cache_timeout:
            self.cache = self._collect_status()
            self.last_update = now
        return self.cache
    
    def _collect_status(self):
        """Collect status from all system components"""
        status = {}
        
        # Service status
        units = {
            "ui": "kilo-ui.service",
            "snap": "kilo-snap-cams.service", 
            "personality": f"kilo-personality@{USER}.service",
            "viam": "viam-agent.service",
            "android_imu": "kilo-android-imu-fixed.service"
        }
        status["services"] = {k: SystemManager.sh(["systemctl", "is-active", u], True)[1] 
                             for k, u in units.items()}
        
        # Network status
        status["network"] = self._get_network_status()
        
        # Android phone status
        cfg = SystemManager.cfg_get()
        phone_ip = cfg.get("android_phone_ip", "10.10.10.1")
        status["android"] = {
            "ip": phone_ip,
            "connected": AndroidManager.check_phone_health(phone_ip) is not None,
            "imu_data": AndroidManager.get_phone_imu(phone_ip),
            "faces": AndroidManager.get_phone_faces(phone_ip)
        }
        
        # Viam status
        status["viam"] = self._get_viam_status()
        
        # System resources
        status["system"] = self._get_system_status()
        
        return status
    
    def _get_network_status(self):
        """Get network interface status"""
        try:
            code, out, err = SystemManager.sh("ip -br addr show")
            interfaces = {}
            for line in out.splitlines():
                if "UP" in line:
                    parts = line.split()
                    if len(parts) >= 3:
                        iface = parts[0]
                        ip = parts[2].split('/')[0] if '/' in parts[2] else "N/A"
                        interfaces[iface] = {"status": "UP", "ip": ip}
            return interfaces
        except:
            return {}
    
    def _get_viam_status(self):
        """Get Viam agent status"""
        try:
            code, out, err = SystemManager.sh("ss -lntp | awk '/viam-agent/ && $1 ~ /LISTEN/ {print $4}' | sed 's/.*://;q'")
            return {
                "listening": code == 0 and out.strip() != "",
                "port": out.strip() if out.strip() else None
            }
        except:
            return {"listening": False, "port": None}
    
    def _get_system_status(self):
        """Get system resource status"""
        try:
            stat = os.statvfs("/")
            free_gb = stat.f_bavail * stat.f_frsize / 1e9
            
            # CPU load
            load_avg = os.getloadavg()[0] if hasattr(os, 'getloadavg') else 0
            
            return {
                "disk_free_gb": round(free_gb, 1),
                "cpu_load": round(load_avg, 2),
                "uptime": self._get_uptime()
            }
        except:
            return {}
    
    def _get_uptime(self):
        """Get system uptime"""
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.readline().split()[0])
                days = int(uptime_seconds // 86400)
                hours = int((uptime_seconds % 86400) // 3600)
                return f"{days}d {hours}h"
        except:
            return "unknown"

# Global instances
system_manager = SystemManager()
android_manager = AndroidManager()
status_monitor = StatusMonitor()

# Modern HTML Template with responsive design
HTML_TEMPLATE = '''<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kilo Truck Control Panel</title>
    <style>
        :root {
            --primary: #2563eb;
            --primary-dark: #1e40af;
            --success: #16a34a;
            --warning: #d97706;
            --danger: #dc2626;
            --dark: #1f2937;
            --light: #f3f4f6;
            --border: #e5e7eb;
        }
        
        * { box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            margin: 0;
            background: var(--light);
            color: var(--dark);
            line-height: 1.6;
        }
        
        .header {
            background: var(--dark);
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            margin: 0;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--success);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid var(--border);
        }
        
        .card h3 {
            margin: 0 0 1rem 0;
            color: var(--dark);
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .status-item {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid var(--border);
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-value {
            font-weight: 600;
        }
        
        .status-online { color: var(--success); }
        .status-offline { color: var(--danger); }
        .status-warning { color: var(--warning); }
        
        .btn {
            background: var(--primary);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s;
            margin: 0.25rem;
        }
        
        .btn:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }
        
        .btn:disabled {
            background: #9ca3af;
            cursor: not-allowed;
            transform: none;
        }
        
        .btn-danger {
            background: var(--danger);
        }
        
        .btn-danger:hover {
            background: #b91c1c;
        }
        
        .btn-success {
            background: var(--success);
        }
        
        .btn-success:hover {
            background: #15803d;
        }
        
        .input-group {
            display: flex;
            gap: 0.5rem;
            margin: 0.5rem 0;
            align-items: center;
        }
        
        .input-group input, .input-group select {
            padding: 0.5rem;
            border: 1px solid var(--border);
            border-radius: 4px;
            font-size: 0.9rem;
        }
        
        .input-group input[type="text"], .input-group input[type="number"] {
            flex: 1;
        }
        
        .loading {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid var(--light);
            border-top: 2px solid var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .toast {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            padding: 1rem 1.5rem;
            background: var(--dark);
            color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.3s;
            z-index: 1000;
            max-width: 400px;
        }
        
        .toast.show {
            opacity: 1;
            transform: translateY(0);
        }
        
        .toast.success { background: var(--success); }
        .toast.error { background: var(--danger); }
        .toast.warning { background: var(--warning); }
        
        .section {
            margin-bottom: 2rem;
        }
        
        .hidden { display: none; }
        
        @media (max-width: 768px) {
            .container { padding: 1rem; }
            .grid { grid-template-columns: 1fr; }
            .header { padding: 1rem; }
            .input-group { flex-direction: column; align-items: stretch; }
        }
    </style>
</head>
<body>
    <header class="header">
        <h1>
            <span class="status-indicator" id="main-status"></span>
            Kilo Truck Control Panel
        </h1>
    </header>

    <div class="container">
        <!-- Status Overview -->
        <div class="section">
            <div class="grid">
                <div class="card">
                    <h3>🤖 System Status</h3>
                    <div id="system-status">
                        <div class="loading"></div> Loading...
                    </div>
                </div>
                
                <div class="card">
                    <h3>📱 Android Phone</h3>
                    <div id="android-status">
                        <div class="loading"></div> Connecting...
                    </div>
                </div>
                
                <div class="card">
                    <h3>🌐 Network</h3>
                    <div id="network-status">
                        <div class="loading"></div> Loading...
                    </div>
                </div>
            </div>
        </div>

        <!-- Control Panels -->
        <div class="section">
            <div class="grid">
                <!-- Android Controls -->
                <div class="card">
                    <h3>📱 Phone Controls</h3>
                    
                    <div class="input-group">
                        <input type="text" id="phone-ip" placeholder="Phone IP">
                        <button class="btn" onclick="discoverPhone()">Discover</button>
                        <button class="btn" onclick="checkPhone()">Check</button>
                    </div>
                    
                    <div class="input-group">
                        <button class="btn" onclick="sendEyes('emotion', 'happy')">😊 Happy</button>
                        <button class="btn" onclick="sendEyes('emotion', 'sad')">😢 Sad</button>
                        <button class="btn" onclick="sendEyes('emotion', 'angry')">😠 Angry</button>
                    </div>
                    
                    <div class="input-group">
                        <button class="btn" onclick="sendEyes('steering', 'left')">⬅️ Look Left</button>
                        <button class="btn" onclick="sendEyes('steering', 'center')">⬆️ Look Center</button>
                        <button class="btn" onclick="sendEyes('steering', 'right')">➡️ Look Right</button>
                    </div>
                </div>

                <!-- Viam Controls -->
                <div class="card">
                    <h3>⚙️ Viam Control</h3>
                    
                    <div class="input-group">
                        <button class="btn" onclick="viamAction('status')">Status</button>
                        <button class="btn" onclick="viamAction('restart')">Restart</button>
                        <button class="btn" onclick="viamAction('detect_addr')">Detect Addr</button>
                    </div>
                    
                    <div class="input-group">
                        <button class="btn" onclick="wanderAction('start')">▶️ Start Wander</button>
                        <button class="btn btn-danger" onclick="wanderAction('stop')">⏹️ Stop Wander</button>
                    </div>
                    
                    <div class="input-group">
                        <input type="text" id="map-tag" placeholder="map-name">
                        <button class="btn" onclick="saveMap()">💾 Save Map</button>
                    </div>
                </div>

                <!-- Personality Controls -->
                <div class="card">
                    <h3>🎭 Personality</h3>
                    
                    <div class="input-group">
                        <label>Snark Level:</label>
                        <input type="range" id="snark-level" min="0" max="5" value="2" onchange="updateSnarkLevel()">
                        <span id="snark-value">2</span>
                    </div>
                    
                    <div class="input-group">
                        <button class="btn" onclick="personalityAction('start')">▶️ Start</button>
                        <button class="btn" onclick="personalityAction('restart')">🔄 Restart</button>
                        <button class="btn btn-danger" onclick="personalityAction('stop')">⏹️ Stop</button>
                    </div>
                    
                    <div class="input-group">
                        <input type="text" id="wake-words" placeholder="wake words (comma separated)">
                        <button class="btn" onclick="updateWakeWords()">Update</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Output Console -->
        <div class="section">
            <div class="card">
                <h3>📋 Output Console</h3>
                <pre id="output" style="background: #1f2937; color: #f3f4f6; padding: 1rem; border-radius: 4px; overflow-y: auto; max-height: 300px;">Ready...</pre>
                <div style="margin-top: 1rem;">
                    <button class="btn" onclick="clearOutput()">Clear</button>
                    <button class="btn" onclick="refreshStatus()">🔄 Refresh Status</button>
                </div>
            </div>
        </div>
    </div>

    <div id="toast" class="toast"></div>

    <script>
        let autoRefresh = null;
        
        // Utility functions
        function showToast(message, type = 'info') {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = `toast ${type} show`;
            setTimeout(() => toast.classList.remove('show'), 3000);
        }
        
        function logOutput(message) {
            const output = document.getElementById('output');
            const timestamp = new Date().toLocaleTimeString();
            output.textContent = `[${timestamp}] ${message}\\n` + output.textContent;
        }
        
        async function apiCall(endpoint, method = 'GET', body = null) {
            try {
                const options = { method };
                if (body) {
                    options.headers = { 'Content-Type': 'application/json' };
                    options.body = JSON.stringify(body);
                }
                
                const response = await fetch(endpoint, options);
                const data = await response.text();
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${data}`);
                }
                
                return data;
            } catch (error) {
                logOutput(`API Error: ${error.message}`);
                showToast(error.message, 'error');
                throw error;
            }
        }
        
        // Status management
        async function refreshStatus() {
            try {
                const status = JSON.parse(await apiCall('/api/status'));
                updateSystemStatus(status);
                updateAndroidStatus(status);
                updateNetworkStatus(status);
            } catch (error) {
                console.error('Status refresh failed:', error);
            }
        }
        
        function updateSystemStatus(status) {
            const container = document.getElementById('system-status');
            const services = status.services || {};
            
            let html = '<div class="status-grid">';
            Object.entries(services).forEach(([name, state]) => {
                const statusClass = state === 'active' ? 'status-online' : 'status-offline';
                html += `
                    <div class="status-item">
                        <span>${name}</span>
                        <span class="status-value ${statusClass}">${state}</span>
                    </div>
                `;
            });
            html += '</div>';
            
            if (status.system) {
                html += `
                    <div class="status-item">
                        <span>Disk Free</span>
                        <span class="status-value">${status.system.disk_free_gb} GB</span>
                    </div>
                    <div class="status-item">
                        <span>CPU Load</span>
                        <span class="status-value">${status.system.cpu_load}</span>
                    </div>
                    <div class="status-item">
                        <span>Uptime</span>
                        <span class="status-value">${status.system.uptime}</span>
                    </div>
                `;
            }
            
            container.innerHTML = html;
            
            // Update main status indicator
            const mainStatus = document.getElementById('main-status');
            const allActive = Object.values(services).every(s => s === 'active');
            mainStatus.style.background = allActive ? 'var(--success)' : 'var(--warning)';
        }
        
        function updateAndroidStatus(status) {
            const container = document.getElementById('android-status');
            const android = status.android || {};
            
            const connectionClass = android.connected ? 'status-online' : 'status-offline';
            const connectionText = android.connected ? 'Connected' : 'Disconnected';
            
            let html = `
                <div class="status-item">
                    <span>Phone IP</span>
                    <span class="status-value">${android.ip || 'N/A'}</span>
                </div>
                <div class="status-item">
                    <span>Status</span>
                    <span class="status-value ${connectionClass}">${connectionText}</span>
                </div>
            `;
            
            if (android.imu_data) {
                html += `
                    <div class="status-item">
                        <span>IMU</span>
                        <span class="status-value status-online">Active</span>
                    </div>
                `;
            }
            
            if (android.faces && android.faces.faces && android.faces.faces.length > 0) {
                html += `
                    <div class="status-item">
                        <span>Faces Detected</span>
                        <span class="status-value status-warning">${android.faces.faces.length}</span>
                    </div>
                `;
            }
            
            container.innerHTML = html;
        }
        
        function updateNetworkStatus(status) {
            const container = document.getElementById('network-status');
            const network = status.network || {};
            
            let html = '';
            Object.entries(network).forEach(([iface, info]) => {
                html += `
                    <div class="status-item">
                        <span>${iface}</span>
                        <span class="status-value">${info.ip}</span>
                    </div>
                `;
            });
            
            if (status.viam) {
                const viamClass = status.viam.listening ? 'status-online' : 'status-offline';
                html += `
                    <div class="status-item">
                        <span>Viam Port</span>
                        <span class="status-value ${viamClass}">${status.viam.port || 'Not listening'}</span>
                    </div>
                `;
            }
            
            container.innerHTML = html || '<div class="status-item"><span>No network info</span></div>';
        }
        
        // Android controls
        async function discoverPhone() {
            logOutput('Discovering Android phone...');
            try {
                const ip = await apiCall('/api/android/discover');
                document.getElementById('phone-ip').value = ip;
                logOutput(`Found phone at: ${ip}`);
                showToast('Phone discovered successfully', 'success');
                refreshStatus();
            } catch (error) {
                logOutput('Phone discovery failed');
            }
        }
        
        async function checkPhone() {
            const ip = document.getElementById('phone-ip').value;
            if (!ip) {
                showToast('Enter phone IP first', 'warning');
                return;
            }
            
            logOutput(`Checking phone at ${ip}...`);
            try {
                const health = await apiCall(`/api/android/check?ip=${ip}`);
                logOutput(`Phone health: ${health}`);
                showToast('Phone is responding', 'success');
            } catch (error) {
                logOutput('Phone check failed');
            }
        }
        
        async function sendEyes(type, emotion) {
            const ip = document.getElementById('phone-ip').value;
            if (!ip) {
                showToast('Enter phone IP first', 'warning');
                return;
            }
            
            logOutput(`Sending eyes command: ${type}/${emotion}`);
            try {
                await apiCall(`/api/android/eyes`, 'POST', { ip, type, emotion });
                showToast(`Eyes command sent: ${emotion}`, 'success');
            } catch (error) {
                logOutput('Eyes command failed');
            }
        }
        
        // Viam controls
        async function viamAction(action) {
            logOutput(`Viam action: ${action}`);
            try {
                const result = await apiCall(`/api/viam/${action}`);
                logOutput(`Viam ${action}: ${result}`);
                showToast(`Viam ${action} completed`, 'success');
                refreshStatus();
            } catch (error) {
                logOutput(`Viam ${action} failed`);
            }
        }
        
        async function wanderAction(action) {
            logOutput(`Wander ${action}`);
            try {
                const result = await apiCall(`/api/wander/${action}`);
                logOutput(`Wander ${action}: ${result}`);
                showToast(`Wander ${action} completed`, 'success');
            } catch (error) {
                logOutput(`Wander ${action} failed`);
            }
        }
        
        async function saveMap() {
            const tag = document.getElementById('map-tag').value;
            logOutput(`Saving map: ${tag || 'auto'}`);
            try {
                const result = await apiCall(`/api/save_map?tag=${encodeURIComponent(tag)}`);
                logOutput(`Map saved: ${result}`);
                showToast('Map saved successfully', 'success');
            } catch (error) {
                logOutput('Map save failed');
            }
        }
        
        // Personality controls
        async function personalityAction(action) {
            logOutput(`Personality ${action}`);
            try {
                const result = await apiCall(`/api/personality?action=${action}`);
                logOutput(`Personality ${action}: ${result}`);
                showToast(`Personality ${action} completed`, 'success');
                refreshStatus();
            } catch (error) {
                logOutput(`Personality ${action} failed`);
            }
        }
        
        async function updateSnarkLevel() {
            const value = document.getElementById('snark-level').value;
            document.getElementById('snark-value').textContent = value;
            
            try {
                await apiCall('/api/config', 'POST', { snark_level: parseInt(value) });
                showToast('Snark level updated', 'success');
            } catch (error) {
                logOutput('Snark level update failed');
            }
        }
        
        async function updateWakeWords() {
            const words = document.getElementById('wake-words').value;
            if (!words) return;
            
            const wakeWords = words.split(',').map(w => w.trim()).filter(w => w);
            
            try {
                await apiCall('/api/config', 'POST', { wake_words: wakeWords });
                showToast('Wake words updated', 'success');
            } catch (error) {
                logOutput('Wake words update failed');
            }
        }
        
        // Utility functions
        function clearOutput() {
            document.getElementById('output').textContent = 'Ready...';
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            refreshStatus();
            
            // Auto-refresh every 10 seconds
            autoRefresh = setInterval(refreshStatus, 10000);
            
            // Load config values
            apiCall('/api/config').then(data => {
                const config = JSON.parse(data);
                document.getElementById('snark-level').value = config.snark_level || 2;
                document.getElementById('snark-value').textContent = config.snark_level || 2;
                document.getElementById('wake-words').value = (config.wake_words || []).join(', ');
                document.getElementById('phone-ip').value = config.android_phone_ip || '10.10.10.1';
            });
        });
        
        // Cleanup on page unload
        window.addEventListener('beforeunload', function() {
            if (autoRefresh) clearInterval(autoRefresh);
        });
    </script>
</body>
</html>'''

class KiloRequestHandler(BaseHTTPRequestHandler):
    """Modern HTTP request handler"""
    
    def _send(self, code, body, ct="text/html"):
        b = body if isinstance(body, (bytes, bytearray)) else body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ct)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Content-Length", str(len(b)))
        self.end_headers()
        self.wfile.write(b)
    
    def do_OPTIONS(self):
        """Handle preflight requests"""
        self._send(200, "")
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == "/":
            return self._send(200, HTML_TEMPLATE)
        
        if self.path == "/api/status":
            status = status_monitor.get_status()
            return self._send(200, json.dumps(status), "application/json")
        
        if self.path == "/api/config":
            config = system_manager.cfg_get()
            return self._send(200, json.dumps(config), "application/json")
        
        if self.path == "/api/android/discover":
            ip = android_manager.discover_phone()
            return self._send(200, ip or "not found", "text/plain")
        
        if self.path.startswith("/api/android/check"):
            qs = urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            ip = (qs.get("ip") or ["10.10.10.1"])[0]
            health = android_manager.check_phone_health(ip)
            return self._send(200, health or "not responding", "text/plain")
        
        return self._send(404, "Not found", "text/plain")
    
    def do_POST(self):
        """Handle POST requests"""
        content_length = int(self.headers.get("content-length", "0"))
        body = self.rfile.read(content_length).decode() if content_length else ""
        
        if self.path == "/api/config":
            try:
                config_data = json.loads(body)
                current_config = system_manager.cfg_get()
                current_config.update(config_data)
                system_manager.cfg_set(current_config)
                return self._send(200, "Configuration saved", "text/plain")
            except Exception as e:
                return self._send(500, f"Config save error: {e}", "text/plain")
        
        if self.path == "/api/android/eyes":
            try:
                data = json.loads(body)
                ip = data.get("ip", "10.10.10.1")
                emotion_type = data.get("type", "emotion")
                emotion = data.get("emotion", "happy")
                
                result = android_manager.send_eyes_command(ip, emotion_type, emotion)
                return self._send(200, result or "Command sent", "text/plain")
            except Exception as e:
                return self._send(500, f"Eyes command error: {e}", "text/plain")
        
        # Viam actions
        if self.path.startswith("/api/viam/"):
            action = self.path.split("/")[-1]
            if action == "status":
                code, out, err = system_manager.sh(["systemctl", "status", "viam-agent", "--no-pager", "-l"], True)
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
            
            elif action == "restart":
                system_manager.sh(["systemctl", "restart", "viam-agent"], True)
                time.sleep(2)
                code, out, err = system_manager.sh(["systemctl", "status", "viam-agent", "--no-pager", "-l"], True)
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
            
            elif action == "detect_addr":
                status = status_monitor.get_status(force_refresh=True)
                addr = "Not found"
                if status["viam"]["listening"] and status["viam"]["port"]:
                    addr = f"127.0.0.1:{status['viam']['port']}"
                return self._send(200, addr, "text/plain")
        
        # Wander actions
        if self.path.startswith("/api/wander/"):
            action = self.path.split("/")[-1]
            if action == "start":
                code, out, err = system_manager.sh(["kilo-wander", "start"])
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
            
            elif action == "stop":
                code, out, err = system_manager.sh(["kilo-wander", "stop"])
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
        
        # Personality actions
        if self.path.startswith("/api/personality"):
            qs = urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            action = (qs.get("action") or ["status"])[0]
            
            if action in ["start", "stop", "restart"]:
                unit = f"kilo-personality@{USER}.service"
                code, out, err = system_manager.sh(["systemctl", action, unit], True)
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
        
        # Map save
        if self.path == "/api/save_map":
            qs = urllib.parse.parse_qs(urllib.parse.urlsplit(self.path).query)
            tag = (qs.get("tag") or [""])[0].strip() or datetime.now().strftime("map-%Y%m%d-%H%M%S")
            
            # Get Viam address
            status = status_monitor.get_status(force_refresh=True)
            if not status["viam"]["listening"] or not status["viam"]["port"]:
                return self._send(500, "Viam agent not listening", "text/plain")
            
            addr = f"127.0.0.1:{status['viam']['port']}"
            out_path = f"/opt/viam/maps/{tag}.pbstream"
            
            try:
                # Create maps directory
                Path("/opt/viam/maps").mkdir(parents=True, exist_ok=True)
                
                # SLAM save script
                py_code = f'''
import asyncio, pathlib
from viam.robot.client import RobotClient
from viam.rpc.dial import DialOptions
from viam.services.slam import SLAMClient

addr = "{addr}"
out_path = pathlib.Path("{out_path}")

async def main():
    robot = await RobotClient.at_address(addr, RobotClient.Options(dial_options=DialOptions(insecure=True)))
    slam = SLAMClient.from_robot(robot, "slam")
    data = await slam.get_internal_state()
    out_path.write_bytes(bytes(data))
    await robot.close()
    print(f"[OK] Saved map to {{out_path}}")

asyncio.run(main())
'''
                
                code, out, err = system_manager.sh(["/opt/kilo/venv/bin/python3", "-c", py_code], timeout=60)
                return self._send(200, (out + "\n" + err).strip(), "text/plain")
                
            except Exception as e:
                return self._send(500, f"Map save error: {e}", "text/plain")
        
        return self._send(404, "Not found", "text/plain")
    
    def log_message(self, format, *args):
        """Suppress default logging"""
        pass

def main():
    """Main server entry point"""
    # Ensure required directories exist
    SNAPS.mkdir(parents=True, exist_ok=True)
    DOCS.mkdir(parents=True, exist_ok=True)
    
    # Create default files if they don't exist
    if not MANUAL.exists():
        MANUAL.write_text("# Kilo Truck - Modern UI Manual\n\nModern web-based control interface for Kilo Truck.\n")
    
    if not LEDGER.exists():
        LEDGER.write_text("# Kilo Truck - Project Ledger\n\nProject milestones and notes.\n")
    
    if not REMEMBER.exists():
        REMEMBER.write_text('Use the "Kilo Project Memory" canvas as context. Modern UI system deployed.\n')
    
    print(f"🚀 Kilo Truck Modern UI starting on port {PORT}")
    print(f"📱 Android integration enabled")
    print(f"🌐 Remote access: http://0.0.0.0:{PORT}")
    
    try:
        with HTTPServer(("0.0.0.0", PORT), KiloRequestHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")

if __name__ == "__main__":
    main()