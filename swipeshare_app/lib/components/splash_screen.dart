import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';

/// Splash screen with animated stripes forming an S shape
/// Blue stripe comes from bottom-left, purple stripe from top-right
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Progress for stripes coming together (0.0 to 1.0 through full animation)
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Fade out animation at the end (starts fading at 80%)
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    // Start animation
    _controller.forward();
    
    // Wait for animation completion and navigate
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AuthGate(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _StripesPainter(
              progress: _progress.value,
              fadeProgress: _fade.value,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for the animated S-shaped stripes
class _StripesPainter extends CustomPainter {
  final double progress;
  final double fadeProgress;
  
  _StripesPainter({required this.progress, required this.fadeProgress});

  // Stripe colors (matching "Hi, {name}" gradient from home screen)
  final Color c1 = const Color(0xFF98D2EB); // light blue
  final Color c2 = const Color(0xFFA2A0DD); // light purple

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.5;
    final centerY = h * 0.5;

    // Calculate opacity based on fade progress (fade out at end)
    final opacity = 1.0 - fadeProgress;

    // Ribbon width (thicker)
    final strokeWidth = 60.0;

    // Animate progress
    final t = Curves.easeInOut.transform(progress);

    // Define the ribbon path - straight lines from bottom-left (offscreen) to top-right with switchback (down then up)
    // Start point (bottom-left, offscreen)
    final start = Offset(-w * 0.1, h * 1.1);
    
    // First segment goes up and to the right toward center
    final point1 = Offset(centerX - w * 0.1, centerY - h * 0.05);
    
    // Switchback - goes DOWN (gentler angle)
    final point2 = Offset(centerX, centerY + h * 0.08);
    
    // Then goes back UP and continues to the right (gentler angle)
    final point3 = Offset(centerX + w * 0.1, centerY - h * 0.05);
    
    // End point (top-right, offscreen)
    final end = Offset(w * 1.1, -h * 0.1);

    // Create the full ribbon path using straight lines
    final fullPath = Path();
    fullPath.moveTo(start.dx, start.dy);
    fullPath.lineTo(point1.dx, point1.dy);
    fullPath.lineTo(point2.dx, point2.dy);
    fullPath.lineTo(point3.dx, point3.dy);
    fullPath.lineTo(end.dx, end.dy);

    // Calculate the total length and create animated path
    final metrics = fullPath.computeMetrics().first;
    final totalLength = metrics.length;
    final currentLength = totalLength * t;

    // Extract the visible portion of the path
    final animatedPath = metrics.extractPath(0, currentLength);

    final bounds = Rect.fromLTWH(0, 0, w, h);

    // Paint with gradient from blue to purple (butt cap for square edges)
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt  // Square edges instead of rounded
      ..strokeJoin = StrokeJoin.round  // Rounded corners at the switchback
      ..shader = LinearGradient(
        colors: [
          c1.withOpacity(opacity),
          c2.withOpacity(opacity),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(bounds);

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _StripesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.fadeProgress != fadeProgress;
}
