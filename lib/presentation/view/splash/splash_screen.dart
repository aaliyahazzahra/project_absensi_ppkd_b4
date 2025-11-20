import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/constant/app_color.dart';
import 'package:project_absensi_ppkd_b4/core/utils/preference_handler.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/splash/particle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _glitchController;

  late List<Particle> _particles;
  final Random _random = Random();
  String _displayText = "";
  final String _fullText = "ADSUM";
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    _particles = List.generate(70, (index) => Particle(_random));

    _startTypewriter();

    _handleNavigation();
  }

  void _startTypewriter() {
    int index = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 120), (
      timer,
    ) {
      if (index < _fullText.length) {
        setState(() {
          if (_random.nextDouble() < 0.2) {
            _displayText =
                _fullText.substring(0, index) +
                String.fromCharCode(_random.nextInt(26) + 65);
          } else {
            index++;
            _displayText = _fullText.substring(0, index);
          }
        });
      } else {
        setState(() {
          _displayText = _fullText;
        });
        timer.cancel();
      }
    });
  }

  void _handleNavigation() {
    Timer(const Duration(seconds: 4), () async {
      if (mounted) {
        final isLoggedIn = await PreferenceHandler.getLoginStatus();

        final String targetRoute = isLoggedIn ? '/home' : '/login';

        Navigator.of(context).pushReplacementNamed(targetRoute);
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _glitchController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildGradientBackground(),
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  random: _random,
                  accent1: AppColor.colorAccent1,
                  accent2: AppColor.colorAccent2,
                ),
                size: Size.infinite,
              );
            },
          ),
          _buildLogoAndText(),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: const [
                AppColor.colorDarkBg,
                AppColor.colorMidBg,
                AppColor.colorDarkBg,
              ],
              stops: const [0.0, 0.5, 1.0],
              center: Alignment.center,
              transform: GradientRotation(_gradientController.value * 2 * pi),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoAndText() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final offset = (_random.nextDouble() - 0.5) * 4;
              final opacity = _random.nextDouble() > 0.1 ? 1.0 : 0.6;
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                ),
              );
            },
            // child: const Icon(
            //   Icons.fingerprint,
            //   size: 80,
            //   color: AppColor.colorAccent2,
            // ),
          ),
          const SizedBox(height: 20),
          Text(
            _displayText,
            style: const TextStyle(
              color: AppColor.colorAccent2,
              fontSize: 24,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
