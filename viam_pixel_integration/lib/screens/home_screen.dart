import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/camera_provider.dart';
import '../providers/viam_provider.dart';
import '../providers/pi_connection_provider.dart';
import '../providers/emotion_display_provider.dart';
import '../providers/face_detection_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/audio_controls.dart';
import '../widgets/camera_preview.dart';
import '../widgets/viam_connection.dart';
import '../widgets/device_info_card.dart';
import '../widgets/pi_connection_widget.dart';
import '../widgets/emotion_display.dart';
import '../widgets/face_detection_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }
  
  Future<void> _initializeProviders() async {
    // Initialize all providers
    await Provider.of<SensorProvider>(context, listen: false).initialize();
    await Provider.of<AudioProvider>(context, listen: false).initialize();
    await Provider.of<CameraProvider>(context, listen: false).initialize();
    await Provider.of<PiConnectionProvider>(context, listen: false).initialize();
    await Provider.of<EmotionDisplayProvider>(context, listen: false).initialize();
    await Provider.of<FaceDetectionProvider>(context, listen: false).initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viam Pi Integration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<PiConnectionProvider>(
            builder: (context, piProvider, child) {
              return IconButton(
                icon: Icon(
                  piProvider.connectionStatus.isConnected 
                    ? Icons.usb 
                    : Icons.usb_off,
                  color: piProvider.connectionStatus.isConnected 
                    ? Colors.green 
                    : Colors.red,
                ),
                onPressed: () => _showPiConnectionDialog(context),
              );
            },
          ),
          Consumer<ViamProvider>(
            builder: (context, viamProvider, child) {
              return IconButton(
                icon: Icon(
                  viamProvider.isConnected 
                    ? Icons.cloud_done 
                    : Icons.cloud_off,
                  color: viamProvider.isConnected 
                    ? Colors.blue 
                    : Colors.grey,
                ),
                onPressed: () => _showViamConnectionDialog(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            const DeviceInfoCard(),
            const SizedBox(height: 16),
            
            // Pi Connection Status
            const PiConnectionWidget(),
            const SizedBox(height: 16),
            
            // Emotion Display
            const EmotionDisplay(),
            const SizedBox(height: 16),
            
            // Face Detection Controls
            const FaceDetectionControls(),
            const SizedBox(height: 16),
            
            // Viam Connection Status (now for local Pi connection)
            Consumer<ViamProvider>(
              builder: (context, viamProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              viamProvider.isConnected 
                                ? Icons.cloud_done 
                                : Icons.cloud_off,
                              color: viamProvider.isConnected 
                                ? Colors.green 
                                : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Viam Connection',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viamProvider.isConnected 
                            ? 'Connected to ${viamProvider.robotAddress}'
                            : 'Not connected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (viamProvider.connectionStatus.error != null)
                          Text(
                            'Error: ${viamProvider.connectionStatus.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Sensor Controls
            Consumer<SensorProvider>(
              builder: (context, sensorProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sensors',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Switch(
                              value: sensorProvider.isMonitoring,
                              onChanged: (value) {
                                if (value) {
                                  sensorProvider.startMonitoring();
                                } else {
                                  sensorProvider.stopMonitoring();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SensorCard(),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Audio Controls
            Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        AudioControls(),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Camera Preview
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const CameraPreview(),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testAllComponents(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test All'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogs(context),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Logs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showViamConnectionDialog(context),
        child: const Icon(Icons.settings),
      ),
    );
  }
  
  void _showViamConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ViamConnectionDialog(),
    );
  }
  
  void _showPiConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pi Connection Settings'),
        content: const Text('Use the Pi Connection widget to manage USB connection to the Raspberry Pi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _testAllComponents(BuildContext context) async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing all components...')),
    );
    
    try {
      // Test sensors
      sensorProvider.startMonitoring();
      await Future.delayed(const Duration(seconds: 2));
      sensorProvider.stopMonitoring();
      
      // Test audio
      await audioProvider.testSpeakers();
      
      // Test camera
      await cameraProvider.testCameras();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All tests completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test failed: $e')),
      );
    }
  }
  
  void _showLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Logs'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Text(
            'Logs would be displayed here.\n'
            'In a production app, you would implement proper logging '
            'with filtering and search capabilities.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}