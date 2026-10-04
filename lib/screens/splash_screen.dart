import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const WelcomeScreen(),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToWelcome() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060919),
      body: GestureDetector(
        onTap: _navigateToWelcome,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Ambient glow backgrounds
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.18),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withOpacity(0.15),
                      blurRadius: 120,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Custom Wave Background Painter
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundWavePainter(),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // ── Central Logo Graphic ──
                    ZoomIn(
                      duration: const Duration(milliseconds: 800),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ambient glow
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.4),
                                  blurRadius: 50,
                                  spreadRadius: 15,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                                  blurRadius: 70,
                                  spreadRadius: 25,
                                ),
                              ],
                            ),
                          ),
                          // App Logo Container
                          Container(
                            width: 150,
                            height: 150,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFA855F7), // Purple
                                  Color(0xFF38BDF8), // Light Cyan
                                  Color(0xFF6366F1), // Indigo
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Title & Subtitle ──
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'AI Interview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 600),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFC084FC)],
                        ).createShader(bounds),
                        child: const Text(
                          'Simulator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'Practice  •  Improve  •  Get Hired',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Bottom Equalizer Loading Indicator ──
                    FadeIn(
                      delay: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _AnimatedSoundBar(heights: [6, 16, 8, 22, 10]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSoundBar extends StatefulWidget {
  final List<double> heights;
  const _AnimatedSoundBar({required this.heights});

  @override
  State<_AnimatedSoundBar> createState() => _AnimatedSoundBarState();
}

class _AnimatedSoundBarState extends State<_AnimatedSoundBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final value = (index % 2 == 0) ? _controller.value : (1.0 - _controller.value);
            final h = 6 + (widget.heights[index] - 6) * value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: h,
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class BackgroundWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();

    // Top wave lines
    path.moveTo(0, size.height * 0.15);
    path.cubicTo(
      size.width * 0.3, size.height * 0.05,
      size.width * 0.7, size.height * 0.22,
      size.width, size.height * 0.12,
    );

    // Bottom wave lines
    path.moveTo(0, size.height * 0.82);
    path.cubicTo(
      size.width * 0.4, size.height * 0.75,
      size.width * 0.6, size.height * 0.92,
      size.width, size.height * 0.85,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
