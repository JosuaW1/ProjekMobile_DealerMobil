import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/sensor_service.dart';

class SensorDemoScreen extends StatefulWidget {
  @override
  _SensorDemoScreenState createState() => _SensorDemoScreenState();
}

class _SensorDemoScreenState extends State<SensorDemoScreen>
    with TickerProviderStateMixin {
  final SensorService _sensorService = SensorService.instance;

  StreamSubscription<GyroscopeData>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerData>? _accelerometerSubscription;
  StreamSubscription<DeviceOrientation>? _orientationSubscription;
  StreamSubscription<MotionEvent>? _motionSubscription;
  StreamSubscription<bool>? _shakeSubscription;

  late AnimationController _rotationController;
  late AnimationController _shakeController;

  GyroscopeData? _currentGyroscope;
  AccelerometerData? _currentAccelerometer;
  DeviceOrientation? _currentOrientation;
  MotionEvent? _currentMotion;
  bool _isShaking = false;
  bool _sensorsInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSensors();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Future<void> _initializeSensors() async {
    try {
      bool available = await _sensorService.areSensorsAvailable();
      if (!available) {
        setState(() {
          _errorMessage = 'Sensor tidak tersedia pada perangkat ini';
        });
        return;
      }

      await _sensorService.initializeSensors();

      _gyroscopeSubscription = _sensorService.gyroscopeStream.listen((data) {
        setState(() {
          _currentGyroscope = data;
        });
        _updateRotation(data);
      });

      _accelerometerSubscription =
          _sensorService.accelerometerStream.listen((data) {
        setState(() {
          _currentAccelerometer = data;
        });
      });

      _orientationSubscription =
          _sensorService.orientationStream.listen((data) {
        setState(() {
          _currentOrientation = data;
        });
      });

      _motionSubscription = _sensorService.motionStream.listen((data) {
        setState(() {
          _currentMotion = data;
        });
      });

      _shakeSubscription = _sensorService.shakeDetection.listen((isShaking) {
        setState(() {
          _isShaking = isShaking;
        });
        if (isShaking) {
          _triggerShakeAnimation();
        }
      });

      setState(() {
        _sensorsInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inisialisasi sensor: $e';
      });
    }
  }

  void _updateRotation(GyroscopeData data) {
    // Update rotation animation based on gyroscope data
    double intensity =
        math.sqrt(data.x * data.x + data.y * data.y + data.z * data.z);
    if (intensity > 0.5) {
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _orientationSubscription?.cancel();
    _motionSubscription?.cancel();
    _shakeSubscription?.cancel();
    _rotationController.dispose();
    _shakeController.dispose();
    _sensorService.stopSensors();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Demo Sensor'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeSensors,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_sensorsInitialized) {
      return _buildLoadingState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Demo Card
          _buildVisualDemoCard(),

          SizedBox(height: 16),

          // Gyroscope Data
          _buildSensorCard(
            title: 'Gyroscope (Rotasi)',
            icon: Icons.rotate_right,
            color: Colors.blue,
            data: _currentGyroscope?.toString() ?? 'Menunggu data...',
            child: _currentGyroscope != null
                ? _buildGyroscopeVisual(_currentGyroscope!)
                : null,
          ),

          SizedBox(height: 12),

          // Accelerometer Data
          _buildSensorCard(
            title: 'Accelerometer (Percepatan)',
            icon: Icons.speed,
            color: Colors.green,
            data: _currentAccelerometer?.toString() ?? 'Menunggu data...',
            child: _currentAccelerometer != null
                ? _buildAccelerometerVisual(_currentAccelerometer!)
                : null,
          ),

          SizedBox(height: 12),

          // Device Orientation
          _buildSensorCard(
            title: 'Orientasi Perangkat',
            icon: Icons.screen_rotation,
            color: Colors.orange,
            data: _currentOrientation != null
                ? '${_currentOrientation!.rollDirection} • ${_currentOrientation!.pitchDirection}'
                : 'Menunggu data...',
            child: _currentOrientation != null
                ? _buildOrientationVisual(_currentOrientation!)
                : null,
          ),

          SizedBox(height: 12),

          // Motion Detection
          _buildSensorCard(
            title: 'Deteksi Gerakan',
            icon: Icons.vibration,
            color: Colors.purple,
            data: _currentMotion?.motionType.displayName ?? 'Menunggu data...',
            child: _currentMotion != null
                ? _buildMotionVisual(_currentMotion!)
                : null,
          ),

          SizedBox(height: 16),

          // Instructions
          _buildInstructionsCard(),
        ],
      ),
    );
  }

  Widget _buildVisualDemoCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[600]!, Colors.purple[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _shakeController.value *
                              10 *
                              math.sin(_shakeController.value * 10),
                          0,
                        ),
                        child: Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _isShaking ? Colors.red : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.smartphone,
                              size: 40,
                              color: _isShaking
                                  ? Colors.white
                                  : Colors.purple[700],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Visual Sensor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Putar atau goyangkan perangkat',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (_isShaking)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SHAKE DETECTED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required Color color,
    required String data,
    Widget? child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        data,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[
              SizedBox(height: 12),
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGyroscopeVisual(GyroscopeData data) {
    return Row(
      children: [
        _buildAxisBar('X', data.x, Colors.red),
        SizedBox(width: 8),
        _buildAxisBar('Y', data.y, Colors.green),
        SizedBox(width: 8),
        _buildAxisBar('Z', data.z, Colors.blue),
      ],
    );
  }

  Widget _buildAccelerometerVisual(AccelerometerData data) {
    return Row(
      children: [
        _buildAxisBar('X', data.x, Colors.red),
        SizedBox(width: 8),
        _buildAxisBar('Y', data.y, Colors.green),
        SizedBox(width: 8),
        _buildAxisBar('Z', data.z, Colors.blue),
      ],
    );
  }

  Widget _buildAxisBar(String axis, double value, Color color) {
    double normalizedValue = (value / 10).clamp(-1.0, 1.0);

    return Expanded(
      child: Column(
        children: [
          Text(
            axis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: normalizedValue >= 0
                      ? 20
                      : 20 - (normalizedValue.abs() * 20),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: normalizedValue.abs() * 20,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationVisual(DeviceOrientation data) {
    return Container(
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Roll: ${data.roll.toStringAsFixed(1)}°',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  data.rollDirection,
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Pitch: ${data.pitch.toStringAsFixed(1)}°',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  data.pitchDirection,
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionVisual(MotionEvent data) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getMotionColor(data.motionType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getMotionIcon(data.motionType),
            color: _getMotionColor(data.motionType),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.motionType.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getMotionColor(data.motionType),
                  ),
                ),
                Text(
                  data.motionType.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMotionColor(MotionType type) {
    switch (type) {
      case MotionType.stationary:
        return Colors.grey;
      case MotionType.moving:
        return Colors.blue;
      case MotionType.rotating:
        return Colors.purple;
    }
  }

  IconData _getMotionIcon(MotionType type) {
    switch (type) {
      case MotionType.stationary:
        return Icons.pause_circle;
      case MotionType.moving:
        return Icons.directions_run;
      case MotionType.rotating:
        return Icons.rotate_right;
    }
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Instruksi Penggunaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInstruction(
                '🔄', 'Putar perangkat untuk melihat data gyroscope'),
            _buildInstruction('📱', 'Goyangkan perangkat untuk deteksi shake'),
            _buildInstruction(
                '⬅️➡️', 'Miringkan perangkat untuk melihat orientasi'),
            _buildInstruction('🏃', 'Gerakkan perangkat untuk deteksi motion'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Inisialisasi sensor...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors_off,
              size: 80,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              'Sensor Tidak Tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error tidak diketahui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initializeSensors,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
