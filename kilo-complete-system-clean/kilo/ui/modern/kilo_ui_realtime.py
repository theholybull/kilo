#!/usr/bin/env python3
"""
Real-time WebSocket extension for Kilo Truck Modern UI
Provides live updates for IMU data, face detection, and system status
"""

import asyncio
import websockets
import json
import time
import threading
from pathlib import Path
import urllib.request
from kilo_ui_modern import AndroidManager, StatusMonitor, SystemManager

class RealtimeServer:
    """WebSocket server for real-time updates"""
    
    def __init__(self, host="0.0.0.0", port=8081):
        self.host = host
        self.port = port
        self.clients = set()
        self.android_manager = AndroidManager()
        self.status_monitor = StatusMonitor()
        self.system_manager = SystemManager()
        self.running = False
        
    async def register_client(self, websocket):
        """Register a new WebSocket client"""
        self.clients.add(websocket)
        print(f"📱 Client connected: {websocket.remote_address}")
        
        # Send initial status
        await self.send_to_client(websocket, {
            "type": "initial_status",
            "data": self.status_monitor.get_status()
        })
    
    async def unregister_client(self, websocket):
        """Unregister a WebSocket client"""
        self.clients.discard(websocket)
        print(f"📱 Client disconnected: {websocket.remote_address}")
    
    async def send_to_client(self, websocket, message):
        """Send message to specific client"""
        try:
            await websocket.send(json.dumps(message))
        except websockets.exceptions.ConnectionClosed:
            await self.unregister_client(websocket)
        except Exception as e:
            print(f"❌ Error sending to client: {e}")
            await self.unregister_client(websocket)
    
    async def broadcast(self, message):
        """Broadcast message to all connected clients"""
        if not self.clients:
            return
        
        # Create a copy of clients to avoid modification during iteration
        clients_copy = self.clients.copy()
        
        for client in clients_copy:
            await self.send_to_client(client, message)
    
    async def android_imu_stream(self):
        """Stream IMU data from Android phone"""
        cfg = self.system_manager.cfg_get()
        phone_ip = cfg.get("android_phone_ip", "10.10.10.1")
        
        while self.running:
            try:
                imu_data = self.android_manager.get_phone_imu(phone_ip)
                if imu_data:
                    await self.broadcast({
                        "type": "imu_data",
                        "data": imu_data,
                        "timestamp": time.time()
                    })
                await asyncio.sleep(0.1)  # 10Hz IMU updates
                
            except Exception as e:
                print(f"❌ IMU stream error: {e}")
                await asyncio.sleep(1)
    
    async def android_faces_stream(self):
        """Stream face detection data from Android phone"""
        cfg = self.system_manager.cfg_get()
        phone_ip = cfg.get("android_phone_ip", "10.10.10.1")
        
        while self.running:
            try:
                faces_data = self.android_manager.get_phone_faces(phone_ip)
                if faces_data and faces_data.get("faces"):
                    await self.broadcast({
                        "type": "faces_detected",
                        "data": faces_data,
                        "timestamp": time.time()
                    })
                await asyncio.sleep(0.5)  # 2Hz face detection updates
                
            except Exception as e:
                print(f"❌ Face detection stream error: {e}")
                await asyncio.sleep(2)
    
    async def system_status_stream(self):
        """Stream system status updates"""
        while self.running:
            try:
                status = self.status_monitor.get_status()
                await self.broadcast({
                    "type": "system_status",
                    "data": status,
                    "timestamp": time.time()
                })
                await asyncio.sleep(5)  # 5Hz status updates
                
            except Exception as e:
                print(f"❌ Status stream error: {e}")
                await asyncio.sleep(10)
    
    async def phone_health_monitor(self):
        """Monitor phone connection health"""
        cfg = self.system_manager.cfg_get()
        phone_ip = cfg.get("android_phone_ip", "10.10.10.1")
        
        while self.running:
            try:
                health = self.android_manager.check_phone_health(phone_ip)
                connected = health is not None
                
                await self.broadcast({
                    "type": "phone_health",
                    "data": {
                        "connected": connected,
                        "ip": phone_ip,
                        "health": health if health else "No response"
                    },
                    "timestamp": time.time()
                })
                
                await asyncio.sleep(10)  # Check every 10 seconds
                
            except Exception as e:
                print(f"❌ Phone health monitor error: {e}")
                await asyncio.sleep(15)
    
    async def handle_client_message(self, websocket, message):
        """Handle incoming messages from clients"""
        try:
            data = json.loads(message)
            
            if data.get("type") == "eyes_command":
                # Forward eyes command to phone
                cfg = self.system_manager.cfg_get()
                phone_ip = cfg.get("android_phone_ip", "10.10.10.1")
                
                result = self.android_manager.send_eyes_command(
                    phone_ip,
                    data.get("emotion_type", "emotion"),
                    data.get("emotion", "happy")
                )
                
                await self.send_to_client(websocket, {
                    "type": "eyes_response",
                    "data": {"success": result is not None, "result": result},
                    "timestamp": time.time()
                })
            
            elif data.get("type") == "update_config":
                # Update configuration
                config_data = data.get("data", {})
                current_config = self.system_manager.cfg_get()
                current_config.update(config_data)
                self.system_manager.cfg_set(current_config)
                
                await self.send_to_client(websocket, {
                    "type": "config_updated",
                    "data": current_config,
                    "timestamp": time.time()
                })
            
            elif data.get("type") == "discover_phone":
                # Discover Android phone
                ip = self.android_manager.discover_phone()
                
                await self.send_to_client(websocket, {
                    "type": "phone_discovered",
                    "data": {"ip": ip or "not found"},
                    "timestamp": time.time()
                })
                
                if ip:
                    # Update configuration with discovered IP
                    current_config = self.system_manager.cfg_get()
                    current_config["android_phone_ip"] = ip
                    self.system_manager.cfg_set(current_config)
        
        except Exception as e:
            print(f"❌ Client message handling error: {e}")
            await self.send_to_client(websocket, {
                "type": "error",
                "data": {"message": str(e)},
                "timestamp": time.time()
            })
    
    async def client_handler(self, websocket, path):
        """Handle WebSocket client connection"""
        await self.register_client(websocket)
        
        try:
            async for message in websocket:
                await self.handle_client_message(websocket, message)
        
        except websockets.exceptions.ConnectionClosed:
            pass
        except Exception as e:
            print(f"❌ Client handler error: {e}")
        finally:
            await self.unregister_client(websocket)
    
    async def start_background_tasks(self):
        """Start all background streaming tasks"""
        tasks = [
            asyncio.create_task(self.android_imu_stream()),
            asyncio.create_task(self.android_faces_stream()),
            asyncio.create_task(self.system_status_stream()),
            asyncio.create_task(self.phone_health_monitor())
        ]
        
        # Wait for all tasks to complete (they run indefinitely)
        await asyncio.gather(*tasks, return_exceptions=True)
    
    async def run_server(self):
        """Run the WebSocket server"""
        print(f"🚀 Starting realtime server on {self.host}:{self.port}")
        self.running = True
        
        # Start the WebSocket server
        server = await websockets.serve(self.client_handler, self.host, self.port)
        
        # Start background tasks
        background_task = asyncio.create_task(self.start_background_tasks())
        
        try:
            print(f"📡 Realtime server running on ws://{self.host}:{self.port}")
            await server.wait_closed()
        except KeyboardInterrupt:
            print("\n🛑 Server stopped by user")
        finally:
            self.running = False
            background_task.cancel()
            server.close()
            await server.wait_closed()

def main():
    """Main entry point"""
    print("📡 Kilo Truck Realtime Server")
    print("Provides WebSocket-based real-time updates for:")
    print("  • Android IMU data (10Hz)")
    print("  • Face detection (2Hz)")
    print("  • System status (0.2Hz)")
    print("  • Phone health monitoring")
    print("")
    
    server = RealtimeServer()
    
    try:
        asyncio.run(server.run_server())
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
    except Exception as e:
        print(f"❌ Server error: {e}")

if __name__ == "__main__":
    main()