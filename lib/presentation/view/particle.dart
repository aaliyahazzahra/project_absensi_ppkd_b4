// lib/particle_painter.dart
import 'dart:math';

import 'package:flutter/material.dart';

// Kelas untuk menampung status setiap partikel
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
    // Inisialisasi ulang partikel dengan nilai acak
    _reset();
  }

  // Mengatur ulang partikel ke status awal (dipakai saat partikel "mati")
  void _reset() {
    // Mulai dari tengah
    position = const Offset(0, 0);
    // Kecepatan acak ke arah luar
    velocity = Offset(
      (random.nextDouble() - 0.5) * 4,
      (random.nextDouble() - 0.5) * 4,
    );
    radius = random.nextDouble() * 15 + 5; // Ukuran
    opacity = random.nextDouble() * 0.5 + 0.3; // Opacity
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.1;
  }

  // Memperbarui status partikel di setiap frame
  void update(Size size) {
    // Gerakkan partikel
    position += velocity;

    // Perbarui rotasi
    rotation += rotationSpeed;

    // Kurangi opacity seiring waktu
    opacity -= 0.005;

    // Jika partikel tidak terlihat atau keluar layar, reset
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
    // Pindahkan titik 0,0 ke tengah layar
    canvas.translate(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Update posisi & status partikel
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
          height: particle.radius / 2, // Bentuk persegi panjang
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
