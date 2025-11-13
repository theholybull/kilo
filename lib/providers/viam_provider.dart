import 'package:flutter/foundation.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:convert';

class ConnectionStatus {
  bool isConnected;
  String? robotId;
  String? error;
  DateTime? lastHeartbeat;
  String? message;
  
  ConnectionStatus({
    required this.isConnected,
    this.robotId,
    this.error,
    this.lastHeartbeat,
    this.message,
  });
}

class ViamProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  
  RobotClient? _robot;
  ConnectionStatus _connectionStatus = 
      ConnectionStatus(isConnected: false);
  
  // Connection parameters
  String _apiKeyId = '';
  String _apiKey = '';
  String _robotAddress = '';
  
  // Viam components that will be exposed
  Map<String, dynamic> _viamResources = {};
  
  // Stream controllers for data streaming
  final StreamController<Map<String, dynamic>> _sensorDataStream = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _audioDataStream = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _cameraDataStream = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Timer? _heartbeatTimer;
  bool _autoReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  // Getters
  RobotClient? get robot => _robot;
  ConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus.isConnected;
  String get apiKeyId => _apiKeyId;
  String get apiKey => _apiKey;
  String get robotAddress => _robotAddress;
  Map<String, dynamic> get viamResources => _viamResources;
  bool get autoReconnect => _autoReconnect;
  
  // Streams
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataStream.stream;
  Stream<Map<String, dynamic>> get audioDataStream => _audioDataStream.stream;
  Stream<Map<String, dynamic>> get cameraDataStream => _cameraDataStream.stream;
  
  Future<void> initialize({
    required String apiKeyId,
    required String apiKey,
    required String robotAddress,
    bool useDirectConnection = true,
  }) async {
    _logger.i('Initializing Viam provider...');
    
    _apiKeyId = apiKeyId;
    _apiKey = apiKey;
    _robotAddress = robotAddress;
    
    await connect(useDirectConnection: useDirectConnection);
  }
  
  Future<void> connect({
    bool useDirectConnection = true,
    String? directAddress,
  }) async {
    if (_robot != null) {
      await disconnect();
    }
    
    try {
      final address = directAddress ?? _robotAddress;
      _logger.i('Connecting to Viam robot: $address (direct: $useDirectConnection)');
      
      RobotClientOptions options;
      if (useDirectConnection) {
        // Connect directly to Pi without cloud authentication
        options = RobotClientOptions(
          // Use local connection options for direct Pi connection
          // insecure: true, // For local development - parameter removed in newer SDK
        );
      } else {
        // Use cloud authentication
        options = RobotClientOptions.withApiKey(_apiKeyId, _apiKey);
      }
      
      _robot = await RobotClient.atAddress(address, options);
      
      _connectionStatus = ConnectionStatus(
        isConnected: true,
        robotId: address,
        lastHeartbeat: DateTime.now(),
      );
      
      _reconnectAttempts = 0;
      _startHeartbeat();
      
      // Register our custom components
      await _registerComponents();
      
      notifyListeners();
      _logger.i('Successfully connected to Viam robot');
    } catch (e) {
      _connectionStatus = ConnectionStatus(
        isConnected: false,
        error: e.toString(),
        lastHeartbeat: DateTime.now(),
      );
      
      _logger.e('Error connecting to Viam robot: $e');
      
      if (_autoReconnect && _reconnectAttempts < _maxReconnectAttempts) {
        _reconnectAttempts++;
        _logger.i('Attempting to reconnect in 5 seconds... (attempt $_reconnectAttempts)');
        
        await Future.delayed(const Duration(seconds: 5));
        await connect(useDirectConnection: useDirectConnection, directAddress: directAddress);
      }
      
      notifyListeners();
    }
  }
  
  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      await _robot?.close();
      _robot = null;
      
      _connectionStatus = ConnectionStatus(isConnected: false);
      
      notifyListeners();
      _logger.i('Disconnected from Viam robot');
    } catch (e) {
      _logger.e('Error disconnecting from Viam robot: $e');
    }
  }
  
  Future<void> _registerComponents() async {
    if (_robot == null) return;
    
    _logger.i('Registering custom components...');
    
    // Register sensor components
    _viamResources['accelerometer'] = {
      'type': 'sensor',
      'name': 'pixel4a_accelerometer',
      'model': 'builtin',
      'attributes': {},
    };
    
    _viamResources['gyroscope'] = {
      'type': 'sensor',
      'name': 'pixel4a_gyroscope',
      'model': 'builtin',
      'attributes': {},
    };
    
    _viamResources['magnetometer'] = {
      'type': 'sensor',
      'name': 'pixel4a_magnetometer',
      'model': 'builtin',
      'attributes': {},
    };
    
    _viamResources['barometer'] = {
      'type': 'sensor',
      'name': 'pixel4a_barometer',
      'model': 'builtin',
      'attributes': {},
    };
    
    // Register audio components
    _viamResources['microphone'] = {
      'type': 'input',
      'name': 'pixel4a_microphone',
      'model': 'builtin',
      'attributes': {},
    };
    
    _viamResources['speaker'] = {
      'type': 'output',
      'name': 'pixel4a_speaker',
      'model': 'builtin',
      'attributes': {},
    };
    
    // Register camera components
    _viamResources['front_camera'] = {
      'type': 'camera',
      'name': 'pixel4a_front_camera',
      'model': 'builtin',
      'attributes': {},
    };
    
    _viamResources['back_camera'] = {
      'type': 'camera',
      'name': 'pixel4a_back_camera',
      'model': 'builtin',
      'attributes': {},
    };
    
    _logger.i('Registered ${_viamResources.length} components');
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });
  }
  
  Future<void> _sendHeartbeat() async {
    if (!isConnected) return;
    
    try {
      // Send a heartbeat to maintain connection
      final resourceNames = _robot?.resourceNames ?? [];
      _logger.d('Heartbeat - Connected resources: ${resourceNames.length}');
    } catch (e) {
      _logger.e('Heartbeat failed: $e');
      
      if (_autoReconnect) {
        _logger.i('Connection lost, attempting to reconnect...');
        await connect();
      }
    }
  }
  
  void streamSensorData(Map<String, dynamic> sensorData) {
    if (!isConnected) return;
    
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'sensor_data',
        'data': sensorData,
      };
      
      _sensorDataStream.add(data);
      _logger.d('Streaming sensor data: ${sensorData.keys}');
    } catch (e) {
      _logger.e('Error streaming sensor data: $e');
    }
  }
  
  void streamAudioData(Map<String, dynamic> audioData) {
    if (!isConnected) return;
    
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'audio_data',
        'data': audioData,
      };
      
      _audioDataStream.add(data);
      _logger.d('Streaming audio data');
    } catch (e) {
      _logger.e('Error streaming audio data: $e');
    }
  }
  
  void streamCameraData(Map<String, dynamic> cameraData) {
    if (!isConnected) return;
    
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'camera_data',
        'data': cameraData,
      };
      
      _cameraDataStream.add(data);
      _logger.d('Streaming camera data');
    } catch (e) {
      _logger.e('Error streaming camera data: $e');
    }
  }
  
  Future<Map<String, dynamic>?> executeCommand(String command, Map<String, dynamic> parameters) async {
    if (!isConnected) {
      _logger.w('Cannot execute command - not connected to Viam');
      return null;
    }
    
    try {
      _logger.i('Executing Viam command: $command with parameters: $parameters');
      
      switch (command) {
        case 'get_sensor_readings':
          return await _getSensorReadings(parameters);
        case 'start_audio_recording':
          return await _startAudioRecording(parameters);
        case 'stop_audio_recording':
          return await _stopAudioRecording();
        case 'play_audio':
          return await _playAudio(parameters);
        case 'capture_image':
          return await _captureImage(parameters);
        case 'start_video_recording':
          return await _startVideoRecording(parameters);
        case 'stop_video_recording':
          return await _stopVideoRecording();
        case 'switch_camera':
          return await _switchCamera();
        case 'set_flash_mode':
          return await _setFlashMode(parameters);
        case 'get_device_info':
          return await _getDeviceInfo();
        default:
          _logger.w('Unknown command: $command');
          return {'error': 'Unknown command: $command'};
      }
    } catch (e) {
      _logger.e('Error executing command $command: $e');
      return {'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> _getSensorReadings(Map<String, dynamic> parameters) async {
    // This would be implemented to get actual sensor readings
    // For now, return mock data
    return {
      'accelerometer': {'x': 0.0, 'y': 0.0, 'z': 9.8},
      'gyroscope': {'x': 0.0, 'y': 0.0, 'z': 0.0},
      'magnetometer': {'x': 0.0, 'y': 0.0, 'z': 0.0},
      'barometer': {'pressure': 1013.25},
    };
  }
  
  Future<Map<String, dynamic>> _startAudioRecording(Map<String, dynamic> parameters) async {
    // Implementation would start audio recording
    return {'status': 'recording_started'};
  }
  
  Future<Map<String, dynamic>> _stopAudioRecording() async {
    // Implementation would stop audio recording
    return {'status': 'recording_stopped'};
  }
  
  Future<Map<String, dynamic>> _playAudio(Map<String, dynamic> parameters) async {
    // Implementation would play audio
    return {'status': 'audio_playing'};
  }
  
  Future<Map<String, dynamic>> _captureImage(Map<String, dynamic> parameters) async {
    // Implementation would capture image
    return {'status': 'image_captured'};
  }
  
  Future<Map<String, dynamic>> _startVideoRecording(Map<String, dynamic> parameters) async {
    // Implementation would start video recording
    return {'status': 'video_recording_started'};
  }
  
  Future<Map<String, dynamic>> _stopVideoRecording() async {
    // Implementation would stop video recording
    return {'status': 'video_recording_stopped'};
  }
  
  Future<Map<String, dynamic>> _switchCamera() async {
    // Implementation would switch camera
    return {'status': 'camera_switched'};
  }
  
  Future<Map<String, dynamic>> _setFlashMode(Map<String, dynamic> parameters) async {
    // Implementation would set flash mode
    return {'status': 'flash_mode_set'};
  }
  
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Implementation would get device info
    return {
      'model': 'Google Pixel 4a',
      'manufacturer': 'Google',
      'sensors': ['accelerometer', 'gyroscope', 'magnetometer', 'barometer'],
      'cameras': ['front', 'back'],
      'audio': ['microphone', 'speaker'],
    };
  }
  
  void setAutoReconnect(bool enabled) {
    _autoReconnect = enabled;
    notifyListeners();
  }
  
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': isConnected,
      'robotAddress': _robotAddress,
      'robotId': _connectionStatus.robotId,
      'error': _connectionStatus.error,
      'autoReconnect': _autoReconnect,
      'reconnectAttempts': _reconnectAttempts,
      'resources': _viamResources,
    };
  }
  
  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _sensorDataStream.close();
    _audioDataStream.close();
    _cameraDataStream.close();
    disconnect();
    super.dispose();
  }
}

// Mock implementation for fallback when Viam SDK fails
class MockRobotClient implements RobotClient {
  bool _connected = false;
  List<ResourceName> _resourceNames = [];
  
  MockRobotClient() {
    _connected = true;
    _resourceNames = [
      ResourceName()
        ..namespace = 'rdk'
        ..type = 'component'
        ..subtype = 'imu'
        ..name = 'phone_imu',
      ResourceName()
        ..namespace = 'rdk'
        ..type = 'component'
        ..subtype = 'camera'
        ..name = 'phone_camera',
      ResourceName()
        ..namespace = 'rdk'
        ..type = 'component'
        ..subtype = 'input_controller'
        ..name = 'phone_audio',
      ResourceName()
        ..namespace = 'rdk'
        ..type = 'component'
        ..subtype = 'generic'
        ..name = 'phone_sensors',
    ];
  }
  
  @override
  List<ResourceName> get resourceNames => _resourceNames;
  
  @override
  List<ResourceName> resourceNames = [];
  
  @override
  String? get name => 'mock_robot';
  
  @override
  Future<void> refresh() async {
    // Mock implementation
  }
  
  @override
  Future<void> close() async {
    _connected = false;
  }
  
  @override
  T componentByName<T extends Component>(String name) {
    // Return mock components
    if (name.contains('imu')) {
      return MockIMU() as T;
    } else if (name.contains('camera')) {
      return MockCamera() as T;
    } else if (name.contains('audio')) {
      return MockAudio() as T;
    }
    throw UnimplementedError('Mock component not found: $name');
  }
  
  @override
  ResourceNamesClient get resourceNamesClient => throw UnimplementedError();
  
  @override
  LogClient get logClient => throw UnimplementedError();
  
  @override
  FrameSystemClient get frameSystemClient => throw UnimplementedError();
  
  @override
  Stream<MapEntry<ResourceName, Status>> get statusStream => 
    Stream.value(MapEntry(ResourceName()..name='mock', Status()));
  
  @override
  Stream<Operation> get operationStream => Stream.empty();
  
  @override
  Future<Operation> getOperationByName(String name) => 
    Future.value(Operation());
  
  @override
  Future<void> cancelOperation(Operation operation) async {
    // Mock implementation
  }
  
  @override
  Future<void> blockForOperation(Operation operation) async {
    // Mock implementation
  }
  
  @override
  Future<List<Operation>> getOperations() async => [];
  
  @override
  Future<Map<String, dynamic>> getMachineMetadata() async => {};
  
  @override
  Future<String> getLogEntries(Map<String, dynamic>? extra) async => '';
  
  @override
  Future<T> transformOrientation<T>(Pose pose, String destination, {String? source}) async {
    throw UnimplementedError();
  }
  
  @override
  Future<T> transformPose<T>(Pose pose, String destination, {String? source}) async {
    throw UnimplementedError();
  }
}

// Mock component implementations
class MockIMU implements IMU {
  @override
  Future<IMUReading> readReadings(Map<String, dynamic>? extra) async {
    return IMUReading(
      linAcc: Vector3(x: 0.0, y: 9.8, z: 0.0),
      angVel: Vector3(x: 0.0, y: 0.0, z: 0.0),
    );
  }
}

class MockCamera implements Camera {
  @override
  Future<Image> getImage(Map<String, dynamic>? extra) async {
    throw UnimplementedError();
  }
  
  @override
  Stream<Image> getImages(Map<String, dynamic>? extra) {
    return Stream.empty();
  }
  
  @override
  Map<String, dynamic>? get properties => null;
  
  @override
  Future<RawImage> getRawImage(Map<String, dynamic>? extra) async {
    throw UnimplementedError();
  }
  
  @override
  Future<PointCloud> getPointCloud(Map<String, dynamic>? extra) async {
    throw UnimplementedError();
  }
}

class MockAudio implements AudioInput {
  @override
  Stream<Chunk> getAudio(Map<String, dynamic>? extra) {
    return Stream.empty();
  }
}