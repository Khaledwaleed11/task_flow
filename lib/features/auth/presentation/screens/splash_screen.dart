import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _lineController;
  late final AnimationController _orbController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.45, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.3, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _titleOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );

    _footerOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.7, 1, curve: Curves.easeOut),
    );

    _introController.forward();

    Timer(const Duration(milliseconds: 2800), _goToAuthGate);
  }

  void _goToAuthGate() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AuthGate();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _lineController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _GradientBackground(),
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return _FloatingShapes(animationValue: _orbController.value);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: const _BrandMark(),
                          ),
                        ),
                        const SizedBox(height: 42),
                        SlideTransition(
                          position: _titleSlide,
                          child: FadeTransition(
                            opacity: _titleOpacity,
                            child: const _BrandTitle(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SlideTransition(
                          position: _subtitleSlide,
                          child: FadeTransition(
                            opacity: _subtitleOpacity,
                            child: const _BrandSubtitle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
                    child: FadeTransition(
                      opacity: _footerOpacity,
                      child: _LoadingIndicator(controller: _lineController),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
    );
  }
}

class _FloatingShapes extends StatelessWidget {
  final double animationValue;

  const _FloatingShapes({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    final firstOffset = Offset(35 * animationValue, 20 * animationValue);

    final secondOffset = Offset(-30 * animationValue, 25 * animationValue);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 80 + firstOffset.dy,
            right: -100 + firstOffset.dx,
            child: const _GlowCircle(size: 280, opacity: 0.08),
          ),
          Positioned(
            bottom: 90 + secondOffset.dy,
            left: -130 + secondOffset.dx,
            child: const _GlowCircle(size: 330, opacity: 0.06),
          ),
          const Positioned(top: 240, left: 30, child: _DotPattern()),
          const Positioned(bottom: 230, right: 35, child: _DotPattern()),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _DotPattern extends StatelessWidget {
  const _DotPattern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 25,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
        ),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 35,
                spreadRadius: 2,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      ],
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TaskFlow',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 46,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1,
      ),
    );
  }
}

class _BrandSubtitle extends StatelessWidget {
  const _BrandSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Turn your work into flow.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.72),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final AnimationController controller;

  const _LoadingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: controller.value,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Organize. Focus. Deliver.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.48),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
