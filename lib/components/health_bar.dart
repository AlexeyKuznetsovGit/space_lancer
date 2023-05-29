import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/player_component.dart';

class HealthBar extends PositionComponent {
  final PlayerComponent player;

  HealthBar({
    required this.player,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    positionType = PositionType.viewport;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(-1, 0.5),
            width: 200,
            height: 20,
          ),
          Radius.circular(10),
        ),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas
      ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(-1, 0.5), width: player.health.toDouble() * 2, height: 20),
            Radius.circular(10),
          ),
          Paint()..color = Colors.white)
      ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(-1, 0.5), width: 200, height: 20),
            Radius.circular(10),
          ),
          Paint()..color = Colors.blue.withOpacity(0.8));

    super.render(canvas);
  }
}
