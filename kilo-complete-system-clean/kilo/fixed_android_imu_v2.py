#!/usr/bin/env python3
"""
Fixed Android IMU Module for Viam
Corrected to use MovementSensor.API instead of SUBTYPE
"""

import asyncio
import json
import logging
import time
from typing import Any, Dict, Optional, Tuple

import requests
from viam.components.movement_sensor import MovementSensor
from viam.proto.app.robot import ComponentConfig
from viam.proto.common import GeoPoint, Orientation, Vector3
from viam.resource.base import ResourceBase
from viam.resource.registry import Registry, ResourceCreatorRegistration
from viam.resource.types import Model, ModelFamily

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AndroidIMU(MovementSensor):
    """Android IMU movement sensor that pulls data from Pixel 4a Flutter app"""
    
    MODEL: Model = Model(ModelFamily("kilo", "movement_sensor"), "android-imu")
    
    def __init__(self, name: str):
        super().__init__(name)
        self.phone_ip = None
        self.phone_port = 8080
        self.timeout = 5.0
        self.last_reading = None
        self.last_update = 0
        self.update_interval = 0.1  # 100 Hz target
        
    @classmethod
    def new(cls, config: ComponentConfig, dependencies: Dict[ResourceName, ResourceBase]) -> 'AndroidIMU':
        """Create new Android IMU instance"""
        imu = cls(config.name)
        
        # Parse configuration
        attrs = config.attributes.fields
        
        if "phone_ip" in attrs:
            imu.phone_ip = attrs["phone_ip"].string_value
        if "phone_port" in attrs:
            imu.phone_port = int(attrs["phone_port"].number_value)
        if "timeout" in attrs:
            imu.timeout = float(attrs["timeout"].number_value)
        if "update_interval" in attrs:
            imu.update_interval = float(attrs["update_interval"].number_value)
            
        logger.info(f"Android IMU configured: phone={imu.phone_ip}:{imu.phone_port}")
        return imu
    
    async def get_imu_data(self) -> Optional[Dict[str, Any]]:
        """Fetch IMU data from Android app"""
        if not self.phone_ip:
            return None
            
        url = f"http://{self.phone_ip}:{self.phone_port}/imu"
        
        try:
            response = requests.get(url, timeout=self.timeout)
            if response.status_code == 200:
                data = response.json()
                self.last_reading = data
                self.last_update = time.time()
                return data
            else:
                logger.warning(f"HTTP {response.status_code} from {url}")
        except requests.RequestException as e:
            logger.warning(f"Failed to get IMU data from {url}: {e}")
            
        return None
    
    async def get_position(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Tuple[GeoPoint, float]:
        """GPS not supported by Android IMU"""
        raise NotImplementedError("Position not supported by IMU")
    
    async def get_linear_velocity(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Vector3:
        """Get linear velocity (integrated from acceleration if needed)"""
        data = await self.get_imu_data()
        if data and "linear_velocity" in data:
            vel = data["linear_velocity"]
            return Vector3(x=vel.get("x", 0), y=vel.get("y", 0), z=vel.get("z", 0))
        
        # Default to zero if not available
        return Vector3(x=0, y=0, z=0)
    
    async def get_angular_velocity(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Vector3:
        """Get angular velocity from gyroscope"""
        data = await self.get_imu_data()
        if data and "angular_velocity" in data:
            gyro = data["angular_velocity"]
            return Vector3(x=gyro.get("x", 0), y=gyro.get("y", 0), z=gyro.get("z", 0))
        
        # Default to zero if not available
        return Vector3(x=0, y=0, z=0)
    
    async def get_linear_acceleration(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Vector3:
        """Get linear acceleration from accelerometer"""
        data = await self.get_imu_data()
        if data and "linear_acceleration" in data:
            accel = data["linear_acceleration"]
            return Vector3(x=accel.get("ax", 0), y=accel.get("ay", 0), z=accel.get("az", 0))
        
        # Default to zero if not available
        return Vector3(x=0, y=0, z=0)
    
    async def get_compass_heading(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> float:
        """Get compass heading from magnetometer"""
        data = await self.get_imu_data()
        if data and "compass_heading" in data:
            return float(data["compass_heading"])
        
        # Default to zero if not available
        return 0.0
    
    async def get_orientation(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Orientation:
        """Get orientation from sensor fusion"""
        data = await self.get_imu_data()
        if data and "orientation" in data:
            ori = data["orientation"]
            return Orientation(
                o_x=ori.get("ox", 0),
                o_y=ori.get("oy", 0), 
                o_z=ori.get("oz", 0),
                theta=ori.get("theta", 0)
            )
        
        # Default to neutral orientation
        return Orientation(o_x=0, o_y=0, o_z=0, theta=0)
    
    async def get_properties(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> MovementSensor.Properties:
        """Return supported properties"""
        return MovementSensor.Properties(
            linear_acceleration_supported=True,
            angular_velocity_supported=True,
            orientation_supported=True,
            position_supported=False,
            compass_heading_supported=True,
            linear_velocity_supported=False
        )
    
    async def get_accuracy(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> MovementSensor.Accuracy:
        """Get accuracy information"""
        data = await self.get_imu_data()
        if data and "accuracy" in data:
            acc = data["accuracy"]
            return MovementSensor.Accuracy(
                accuracy=acc.get("accuracy", 0.0),
                compass_heading_accuracy=acc.get("compass_heading_accuracy", 0.0),
                linear_acceleration_accuracy=acc.get("linear_acceleration_accuracy", 0.0),
                linear_velocity_accuracy=acc.get("linear_velocity_accuracy", 0.0),
                orientation_accuracy=acc.get("orientation_accuracy", 0.0),
                position_accuracy=acc.get("position_accuracy", 0.0)
            )
        
        # Default accuracy values
        return MovementSensor.Accuracy(
            accuracy=0.0,
            compass_heading_accuracy=0.0,
            linear_acceleration_accuracy=0.0,
            linear_velocity_accuracy=0.0,
            orientation_accuracy=0.0,
            position_accuracy=0.0
        )
    
    async def get_readings(self, *, extra: Optional[Dict[str, Any]] = None, timeout: Optional[float] = None) -> Dict[str, Any]:
        """Get raw sensor readings"""
        data = await self.get_imu_data()
        if data:
            return {
                "timestamp": data.get("timestamp", time.time()),
                "accelerometer": data.get("linear_acceleration", {}),
                "gyroscope": data.get("angular_velocity", {}),
                "orientation": data.get("orientation", {}),
                "compass_heading": data.get("compass_heading", 0.0),
                "accuracy": data.get("accuracy", {})
            }
        
        return {}
    
    async def close(self):
        """Clean up resources"""
        logger.info(f"Android IMU {self.name} closed")


async def main():
    """Main module entry point"""
    # Register the Android IMU module with the corrected API reference
    Registry.register_resource_creator(
        MovementSensor.API,  # Fixed: Use API instead of SUBTYPE
        AndroidIMU.MODEL,
        ResourceCreatorRegistration(AndroidIMU.new)
    )
    
    # Start the module
    from viam.module.module import Module
    
    module = Module.from_args()
    module.add_model_from_registry(MovementSensor.API, AndroidIMU.MODEL)
    await module.start()


if __name__ == "__main__":
    asyncio.run(main())