import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static SensorService? _instance;
  static SensorService get instance => _instance ??= SensorService._internal();
  SensorService._internal();

  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Current sensor values
  GyroscopeData _currentGyroscope = GyroscopeData(x: 0, y: 0, z: 0);
  AccelerometerData _currentAccelerometer = AccelerometerData(x: 0, y: 0, z: 0);

  // Stream controllers for broadcasting sensor data
  final StreamController<GyroscopeData> _gyroscopeController =
      StreamController<GyroscopeData>.broadcast();
  final StreamController<AccelerometerData> _accelerometerController =
      StreamController<AccelerometerData>.broadcast();
  final StreamController<DeviceOrientation> _orientationController =
      StreamController<DeviceOrientation>.broadcast();
  final StreamController<MotionEvent> _motionController =
      StreamController<MotionEvent>.broadcast();

  // Getters for streams
  Stream<GyroscopeData> get gyroscopeStream => _gyroscopeController.stream;
  Stream<AccelerometerData> get accelerometerStream =>
      _accelerometerController.stream;
  Stream<DeviceOrientation> get orientationStream =>
      _orientationController.stream;
  Stream<MotionEvent> get motionStream => _motionController.stream;

  // Current values getters
  GyroscopeData get currentGyroscope => _currentGyroscope;
  AccelerometerData get currentAccelerometer => _currentAccelerometer;

  /// Initialize sensor listeners
  Future<void> initializeSensors() async {
    try {
      await startGyroscope();
      await startAccelerometer();
    } catch (e) {
      print('Error initializing sensors: $e');
    }
  }

  /// Start gyroscope monitoring
  Future<void> startGyroscope() async {
    try {
      _gyroscopeSubscription?.cancel();

      _gyroscopeSubscription = gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _currentGyroscope = GyroscopeData(
            x: event.x,
            y: event.y,
            z: event.z,
            timestamp: DateTime.now(),
          );

          _gyroscopeController.add(_currentGyroscope);
          _processMotionData();
        },
        onError: (error) {
          print('Gyroscope error: $error');
        },
      );
    } catch (e) {
      print('Error starting gyroscope: $e');
    }
  }

  /// Start accelerometer monitoring
  Future<void> startAccelerometer() async {
    try {
      _accelerometerSubscription?.cancel();

      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _currentAccelerometer = AccelerometerData(
            x: event.x,
            y: event.y,
            z: event.z,
            timestamp: DateTime.now(),
          );

          _accelerometerController.add(_currentAccelerometer);
          _processOrientationData();
          _processMotionData();
        },
        onError: (error) {
          print('Accelerometer error: $error');
        },
      );
    } catch (e) {
      print('Error starting accelerometer: $e');
    }
  }

  /// Process orientation data from accelerometer
  void _processOrientationData() {
    try {
      double x = _currentAccelerometer.x;
      double y = _currentAccelerometer.y;
      double z = _currentAccelerometer.z;

      // Calculate tilt angles in degrees
      double roll = math.atan2(y, z) * (180 / math.pi);
      double pitch = math.atan2(-x, math.sqrt(y * y + z * z)) * (180 / math.pi);

      DeviceOrientation orientation = DeviceOrientation(
        roll: roll,
        pitch: pitch,
        timestamp: DateTime.now(),
      );

      _orientationController.add(orientation);
    } catch (e) {
      print('Error processing orientation: $e');
    }
  }

  /// Process motion data from both sensors
  void _processMotionData() {
    try {
      // Calculate rotation intensity from gyroscope
      double rotationIntensity = math.sqrt(
          _currentGyroscope.x * _currentGyroscope.x +
              _currentGyroscope.y * _currentGyroscope.y +
              _currentGyroscope.z * _currentGyroscope.z);

      // Calculate acceleration intensity
      double accelerationIntensity = math.sqrt(
          _currentAccelerometer.x * _currentAccelerometer.x +
              _currentAccelerometer.y * _currentAccelerometer.y +
              _currentAccelerometer.z * _currentAccelerometer.z);

      // Determine motion type
      MotionType motionType =
          _determineMotionType(rotationIntensity, accelerationIntensity);

      MotionEvent motionEvent = MotionEvent(
        rotationIntensity: rotationIntensity,
        accelerationIntensity: accelerationIntensity,
        motionType: motionType,
        timestamp: DateTime.now(),
      );

      _motionController.add(motionEvent);
    } catch (e) {
      print('Error processing motion: $e');
    }
  }

  /// Determine motion type based on sensor values
  MotionType _determineMotionType(
      double rotationIntensity, double accelerationIntensity) {
    // Thresholds for motion detection
    const double rotationThreshold = 1.0;
    const double accelerationThreshold =
        12.0; // Gravity is ~9.8, so movement above this

    if (rotationIntensity > rotationThreshold) {
      return MotionType.rotating;
    } else if (accelerationIntensity > accelerationThreshold) {
      return MotionType.moving;
    } else {
      return MotionType.stationary;
    }
  }

  /// Stop all sensor monitoring
  void stopSensors() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription = null;
    _accelerometerSubscription = null;
  }

  /// Check if sensors are available
  Future<bool> areSensorsAvailable() async {
    try {
      // Try to get a single reading to test availability
      await gyroscopeEvents.first.timeout(Duration(seconds: 2));
      await accelerometerEvents.first.timeout(Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get device shake detection
  Stream<bool> get shakeDetection {
    return accelerometerStream.map((data) {
      double intensity =
          math.sqrt(data.x * data.x + data.y * data.y + data.z * data.z);
      return intensity > 15.0; // Shake threshold
    });
  }

  /// Dispose all resources
  void dispose() {
    stopSensors();
    _gyroscopeController.close();
    _accelerometerController.close();
    _orientationController.close();
    _motionController.close();
  }
}

/// Data models

class GyroscopeData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'Gyro(x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)})';
}

class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'Accel(x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)})';
}

class DeviceOrientation {
  final double roll;
  final double pitch;
  final DateTime timestamp;

  DeviceOrientation({
    required this.roll,
    required this.pitch,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get rollDirection {
    if (roll > 30) return 'Miring Kiri';
    if (roll < -30) return 'Miring Kanan';
    return 'Seimbang';
  }

  String get pitchDirection {
    if (pitch > 30) return 'Miring Depan';
    if (pitch < -30) return 'Miring Belakang';
    return 'Datar';
  }

  @override
  String toString() =>
      'Orientation(roll: ${roll.toStringAsFixed(1)}°, pitch: ${pitch.toStringAsFixed(1)}°)';
}

class MotionEvent {
  final double rotationIntensity;
  final double accelerationIntensity;
  final MotionType motionType;
  final DateTime timestamp;

  MotionEvent({
    required this.rotationIntensity,
    required this.accelerationIntensity,
    required this.motionType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'Motion(${motionType.name}, rot: ${rotationIntensity.toStringAsFixed(2)}, accel: ${accelerationIntensity.toStringAsFixed(2)})';
}

enum MotionType {
  stationary,
  moving,
  rotating,
}

extension MotionTypeExtension on MotionType {
  String get displayName {
    switch (this) {
      case MotionType.stationary:
        return 'Diam';
      case MotionType.moving:
        return 'Bergerak';
      case MotionType.rotating:
        return 'Berputar';
    }
  }

  String get description {
    switch (this) {
      case MotionType.stationary:
        return 'Perangkat dalam posisi diam';
      case MotionType.moving:
        return 'Perangkat sedang bergerak';
      case MotionType.rotating:
        return 'Perangkat sedang berputar';
    }
  }
}
