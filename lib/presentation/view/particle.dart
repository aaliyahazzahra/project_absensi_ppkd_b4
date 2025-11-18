import 'dart:math';

import 'package:flutter/material.dart';

class Particle {
  final Random random;
  late Offset position;
  late Offset velocity;
  late double radius;
  late double opacity;
  late Color color;
  late double rotation;
  late double rotationSpeed;

  Particle(this.random) {
    _reset();
  }

  void _reset() {
    position = const Offset(0, 0);
    velocity = Offset(
      (random.nextDouble() - 0.5) * 4,
      (random.nextDouble() - 0.5) * 4,
    );
    radius = random.nextDouble() * 15 + 5;
    opacity = random.nextDouble() * 0.5 + 0.3;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.1;
  }

  void update(Size size) {
    position += velocity;

    rotation += rotationSpeed;

    opacity -= 0.005;

    if (opacity <= 0 ||
        position.dx.abs() > size.width / 1.5 ||
        position.dy.abs() > size.height / 1.5) {
      _reset();
    }
  }
}

// Custom Painter yang menggambar partikel
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Random random;
  final Color accent1;
  final Color accent2;

  ParticlePainter({
    required this.particles,
    required this.random,
    required this.accent1,
    required this.accent2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    for (var particle in particles) {
      particle.update(size);

      // Pilih warna acak dari palet
      final color = random.nextBool() ? accent1 : accent2;

      final paint = Paint()
        ..color = color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // Simpan kondisi canvas
      canvas.save();

      // Terapkan transformasi (posisi, rotasi)
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      // Gambar bentuk (persegi panjang tipis untuk "fragmentasi")
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.radius * 2,
          height: particle.radius / 2,
        ),
        paint,
      );

      // Kembalikan kondisi canvas
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Selalu repaint karena controller animasi yang memintanya
    return true;
  }
}
