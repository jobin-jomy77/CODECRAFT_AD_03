import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(StopwatchApp());

class StopwatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elegant Stopwatch',
      debugShowCheckedModeBanner: false,
      home: StopwatchHomePage(),
    );
  }
}

class StopwatchHomePage extends StatefulWidget {
  @override
  _StopwatchHomePageState createState() => _StopwatchHomePageState();
}

class _StopwatchHomePageState extends State<StopwatchHomePage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _milliseconds = 0;
  bool _isRunning = false;

  void _toggleStartPause() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 10), (_) {
      setState(() {
        _milliseconds += 10;
      });
    });
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    if (_isRunning) _timer.cancel();
    setState(() {
      _milliseconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate();

    return "${minutes.toString().padLeft(2, '0')}:"
           "${seconds.toString().padLeft(2, '0')}:"
           "${hundreds.toString().padLeft(2, '0')}";
  }

  double _progressPercent() {
    return (_milliseconds % 60000) / 60000; // % of a minute
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(_milliseconds);

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌫️ Blur Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4)
                ],
                radius: 0.85,
                center: Alignment.center,
              ),
            ),
          ),

          // ⏱ Stopwatch UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Stopwatch with Progress
                CustomPaint(
                  painter: CircleProgressPainter(progress: _progressPercent()),
                  child: Container(
                    width: 260,
                    height: 260,
                    alignment: Alignment.center,
                    child: Text(
                      formattedTime,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 40,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(
                      icon: _isRunning ? Icons.pause : Icons.play_arrow,
                      label: _isRunning ? 'Pause' : 'Start',
                      color: _isRunning ? Colors.orange : Colors.greenAccent,
                      onPressed: _toggleStartPause,
                    ),
                    SizedBox(width: 30),
                    _buildButton(
                      icon: Icons.replay,
                      label: 'Reset',
                      color: Colors.redAccent,
                      onPressed: _resetTimer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        elevation: 10,
        shadowColor: Colors.black87,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}

// 🎨 Custom Painter for Progress Ring
class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()
      ..color = Colors.white24
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.greenAccent, Colors.yellow, Colors.orange],
        startAngle: 0.0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
