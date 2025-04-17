import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final double height;
  final Color color;
  final BorderRadius borderRadius;

  const PlaceholderCard({
    super.key,
    required this.height,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      // You could add child widgets here later if needed
    );
  }
} 