import 'package:flutter/material.dart';
import '../../theme.dart';

Widget glowingText(
  String text, {
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.white,
  double opacity = 1.0,
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color.withOpacity(opacity),
      shadows: [
        Shadow(
          color: color.withOpacity(0.5),
          blurRadius: 8,
          offset: const Offset(0, 0),
        ),
      ],
    ),
  );
}

Widget glassCard({
  required Widget child,
  EdgeInsetsGeometry? padding,
  double borderRadius = 16,
}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: child,
  );
}
