import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _mainLottieController;
  late final AnimationController _dotsController;
  late final AnimationController _loadingLottieController;

  late final Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();

    _mainLottieController = AnimationController(vsync: this);
    _loadingLottieController = AnimationController(vsync: this);

    _dotsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _dotAnimation = IntTween(begin: 0, end: 3).animate(_dotsController);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.go('/auth-login');
    });
  }

  @override
  void dispose() {
    _mainLottieController.dispose();
    _loadingLottieController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidth = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 29, 38),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 50),
                      child: SizedBox(
                        height: 200,
                        child: Lottie.asset(
                          'assets/animations/profile-password-unlock.json',
                          controller: _mainLottieController,
                          onLoaded: (composition) {
                            _mainLottieController
                              ..duration = composition.duration
                              ..repeat();
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Image.asset(
                        'assets/images/gatewise-logo.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -120),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Mais que acesso. ',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'É confiança',
                              style: TextStyle(
                                color: Color(0xFF4D9EF6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' digital.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                height: 50,
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  controller: _loadingLottieController,
                  onLoaded: (composition) {
                    _loadingLottieController
                      ..duration = composition.duration
                      ..repeat();
                  },
                ),
              ),

              AnimatedBuilder(
                animation: _dotAnimation,
                builder: (context, child) {
                  final dots = '.' * _dotAnimation.value;
                  return Text(
                    'Loading$dots',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
