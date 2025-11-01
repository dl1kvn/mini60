import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({Key? key, required this.nextPage}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _explosionController;
  late AnimationController _starfieldController;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _explosionAnimation;

  @override
  void initState() {
    super.initState();

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _textScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Explosion animation controller
    _explosionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _explosionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeOut),
    );

    // Starfield animation controller
    _starfieldController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // Start animations
    _textController.forward();
    _explosionController.forward();
    _starfieldController.repeat();

    // Navigate to next page after delay
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => widget.nextPage, transition: Transition.fadeIn);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _explosionController.dispose();
    _starfieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0e27),
      body: Stack(
        children: [
          // Animated starfield background
          AnimatedBuilder(
            animation: _starfieldController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarfieldPainter(_starfieldController.value),
                size: Size.infinite,
              );
            },
          ),

          // Starships
          AnimatedBuilder(
            animation: _starfieldController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarshipPainter(_starfieldController.value),
                size: Size.infinite,
              );
            },
          ),

          // Explosion particles
          AnimatedBuilder(
            animation: _explosionController,
            builder: (context, child) {
              return CustomPaint(
                painter: ExplosionPainter(_explosionAnimation.value),
                size: Size.infinite,
              );
            },
          ),

          // Main text
          Center(
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _textScaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.purple,
                              Colors.pink,
                              Colors.orange,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'DL1KVN',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.cyan,
                              Colors.blue,
                              Colors.indigo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'MINI60 APP',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Starfield painter for animated stars
class StarfieldPainter extends CustomPainter {
  final double animation;

  StarfieldPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate stars
    for (int i = 0; i < 150; i++) {
      final random = Random(i);
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animation * 100) %
          size.height;
      final starSize = random.nextDouble() * 2 + 0.5;
      final opacity = (sin(animation * 2 * pi + i) + 1) / 2;

      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}

// Starship painter
class StarshipPainter extends CustomPainter {
  final double animation;

  StarshipPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    // Draw multiple starships
    for (int i = 0; i < 5; i++) {
      final random = Random(i + 100);
      final startX = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animation * 300) %
          (size.height + 100);
      final shipSize = random.nextDouble() * 15 + 10;
      final speed = random.nextDouble() * 0.5 + 0.5;

      // Starship body (triangle)
      final path = Path();
      path.moveTo(startX, y);
      path.lineTo(startX - shipSize / 3, y + shipSize);
      path.lineTo(startX + shipSize / 3, y + shipSize);
      path.close();

      paint.color = Color.lerp(
        Colors.cyan,
        Colors.blue,
        random.nextDouble(),
      )!
          .withOpacity(0.7);
      canvas.drawPath(path, paint);

      // Engine glow
      final glowPaint = Paint()
        ..color = Colors.orange.withOpacity(0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(startX, y + shipSize), shipSize / 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(StarshipPainter oldDelegate) => true;
}

// Explosion particles painter
class ExplosionPainter extends CustomPainter {
  final double animation;

  ExplosionPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw explosion particles
    for (int i = 0; i < 100; i++) {
      final random = Random(i + 200);
      final angle = random.nextDouble() * 2 * pi;
      final speed = random.nextDouble() * 200 + 50;
      final distance = animation * speed;

      final x = centerX + cos(angle) * distance;
      final y = centerY + sin(angle) * distance;

      final particleSize = random.nextDouble() * 4 + 2;
      final opacity = max(0.0, 1.0 - animation);

      final paint = Paint()
        ..color = Color.lerp(
          Colors.yellow,
          Colors.red,
          random.nextDouble(),
        )!
            .withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ExplosionPainter oldDelegate) => true;
}
