import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:viam_pixel4a_sensors/main.dart';
import 'package:viam_pixel4a_sensors/providers/sensor_provider.dart';
import 'package:viam_pixel4a_sensors/providers/audio_provider.dart';
import 'package:viam_pixel4a_sensors/providers/camera_provider.dart';
import 'package:viam_pixel4a_sensors/providers/viam_provider.dart';

void main() {
  group('Viam Pixel 4a Sensors App Tests', () {
    testWidgets('App should initialize with all providers', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ViamPixel4aApp());

      // Verify that the app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('SensorProvider should initialize correctly', (WidgetTester tester) async {
      final sensorProvider = SensorProvider();
      
      // Test initial state
      expect(sensorProvider.isMonitoring, isFalse);
      expect(sensorProvider.accelerometerData, isNull);
      expect(sensorProvider.gyroscopeData, isNull);
      expect(sensorProvider.magnetometerData, isNull);
      expect(sensorProvider.barometerData, isNull);
    });

    testWidgets('AudioProvider should initialize correctly', (WidgetTester tester) async {
      final audioProvider = AudioProvider();
      
      // Test initial state
      expect(audioProvider.isRecording, isFalse);
      expect(audioProvider.isPlaying, isFalse);
      expect(audioProvider.currentRecordingPath, isNull);
      expect(audioProvider.recordingDuration, Duration.zero);
    });

    testWidgets('CameraProvider should initialize correctly', (WidgetTester tester) async {
      final cameraProvider = CameraProvider();
      
      // Test initial state
      expect(cameraProvider.isInitialized, isFalse);
      expect(cameraProvider.isRecording, isFalse);
      expect(cameraProvider.isCapturing, isFalse);
      expect(cameraProvider.currentLensDirection, CameraLensDirection.back);
    });

    testWidgets('ViamProvider should initialize correctly', (WidgetTester tester) async {
      final viamProvider = ViamProvider();
      
      // Test initial state
      expect(viamProvider.isConnected, isFalse);
      expect(viamProvider.robot, isNull);
      expect(viamProvider.autoReconnect, isTrue);
      expect(viamProvider.apiKeyId, isEmpty);
      expect(viamProvider.apiKey, isEmpty);
      expect(viamProvider.robotAddress, isEmpty);
    });

    testWidgets('HomeScreen should display all components', (WidgetTester tester) async {
      await tester.pumpWidget(const ViamPixel4aApp());
      await tester.pumpAndSettle();

      // Verify main components are present
      expect(find.text('Viam Pixel 4a Sensors'), findsOneWidget);
      expect(find.text('Device Information'), findsOneWidget);
      expect(find.text('Viam Connection'), findsOneWidget);
      expect(find.text('Sensors'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
    });

    testWidgets('Sensor monitoring toggle should work', (WidgetTester tester) async {
      await tester.pumpWidget(const ViamPixel4aApp());
      await tester.pumpAndSettle();

      // Find the sensor monitoring switch
      final sensorSwitch = find.byType(Switch).first;
      expect(sensorSwitch, findsOneWidget);

      // Verify initial state is off
      Switch switchWidget = tester.widget(sensorSwitch);
      expect(switchWidget.value, isFalse);

      // Toggle the switch
      await tester.tap(sensorSwitch);
      await tester.pumpAndSettle();

      // Verify the switch is now on
      switchWidget = tester.widget(sensorSwitch);
      expect(switchWidget.value, isTrue);
    });

    testWidgets('Viam connection dialog should open', (WidgetTester tester) async {
      await tester.pumpWidget(const ViamPixel4aApp());
      await tester.pumpAndSettle();

      // Find the settings floating action button
      final settingsFab = find.byType(FloatingActionButton);
      expect(settingsFab, findsOneWidget);

      // Tap the settings button
      await tester.tap(settingsFab);
      await tester.pumpAndSettle();

      // Verify the dialog is open
      expect(find.text('Viam Connection Settings'), findsOneWidget);
      expect(find.text('API Key ID'), findsOneWidget);
      expect(find.text('API Key'), findsOneWidget);
      expect(find.text('Robot Address'), findsOneWidget);
    });

    testWidgets('Test All button should be present', (WidgetTester tester) async {
      await tester.pumpWidget(const ViamPixel4aApp());
      await tester.pumpAndSettle();

      // Find the Test All button
      final testButton = find.text('Test All');
      expect(testButton, findsOneWidget);
    });
  });

  group('Sensor Data Tests', () {
    test('SensorData should serialize correctly', () {
      final timestamp = DateTime.now();
      final values = {'x': 1.0, 'y': 2.0, 'z': 3.0};
      final sensorData = SensorData(timestamp: timestamp, values: values);

      final json = sensorData.toJson();
      
      expect(json['timestamp'], equals(timestamp.toIso8601String()));
      expect(json['values'], equals(values));
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete sensor data flow should work', (WidgetTester tester) async {
      await tester.pumpWidget(const ViamPixel4aApp());
      await tester.pumpAndSettle();

      // Start sensor monitoring
      final sensorSwitch = find.byType(Switch).first;
      await tester.tap(sensorSwitch);
      await tester.pumpAndSettle();

      // Wait a bit for sensor data to be collected
      await tester.pump(const Duration(seconds: 2));

      // Stop sensor monitoring
      await tester.tap(sensorSwitch);
      await tester.pumpAndSettle();

      // Verify the switch is off again
      Switch switchWidget = tester.widget(sensorSwitch);
      expect(switchWidget.value, isFalse);
    });
  });
}