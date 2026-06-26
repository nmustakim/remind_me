import 'package:flutter/material.dart';

class VisualTheme {
  final String id;
  final String name;
  final List<Color> palette;
  final IconData icon;

  const VisualTheme({
    required this.id,
    required this.name,
    required this.palette,
    required this.icon,
  });
}

class VisualThemeRegistry {
  static const List<VisualTheme> all = [
    VisualTheme(
      id: 'aurora',
      name: 'Aurora waves',
      palette: [Color(0xFF0D2B4E), Color(0xFF0A3D28), Color(0xFF1A0A3D)],
      icon: Icons.waves,
    ),
    VisualTheme(
      id: 'glowingOrb',
      name: 'Glowing orb',
      palette: [Color(0xFF7C6FFF), Color(0xFF534AB7), Color(0xFF9B8FFF)],
      icon: Icons.lens,
    ),
    VisualTheme(
      id: 'rippleWater',
      name: 'Ripple water',
      palette: [Color(0xFF3DD9A4), Color(0xFF1D9E75), Color(0xFF0F6E56)],
      icon: Icons.water,
    ),
    VisualTheme(
      id: 'particleField',
      name: 'Particle field',
      palette: [Color(0xFF378ADD), Color(0xFF185FA5), Color(0xFF85B7EB)],
      icon: Icons.scatter_plot,
    ),
    VisualTheme(
      id: 'geometric',
      name: 'Geometric motion',
      palette: [Color(0xFF7C6FFF), Color(0xFF9B8FFF), Color(0xFF534AB7)],
      icon: Icons.hexagon_outlined,
    ),
    VisualTheme(
      id: 'sunrise',
      name: 'Sunrise gradient',
      palette: [Color(0xFFFF8840), Color(0xFFCC5520), Color(0xFF8A3010)],
      icon: Icons.wb_twilight,
    ),
    VisualTheme(
      id: 'floatingCrystal',
      name: 'Floating crystal',
      palette: [Color(0xFF85B7EB), Color(0xFF378ADD), Color(0xFFB5D4F4)],
      icon: Icons.diamond_outlined,
    ),
    VisualTheme(
      id: 'neonRings',
      name: 'Soft neon rings',
      palette: [Color(0xFFFF6BBD), Color(0xFF7C6FFF), Color(0xFF3DD9A4)],
      icon: Icons.radio_button_unchecked,
    ),
    VisualTheme(
      id: 'sandFlow',
      name: 'Hourglass sand',
      palette: [Color(0xFFEF9F27), Color(0xFFBA7517), Color(0xFF854F0B)],
      icon: Icons.hourglass_empty,
    ),
    VisualTheme(
      id: 'driftingClouds',
      name: 'Drifting clouds',
      palette: [Color(0xFFB5D4F4), Color(0xFF85B7EB), Color(0xFF6A7FCC)],
      icon: Icons.cloud_outlined,
    ),
  ];

  static VisualTheme byId(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }
}
