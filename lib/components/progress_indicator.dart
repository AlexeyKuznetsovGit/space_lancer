import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/space_lancer_game.dart';

class TimerProgressBar extends Component {
  double timer;
  final double timeLimit;
  Vector2 screenSize;

  TimerProgressBar(this.screenSize, this.timer, this.timeLimit);

  @override
  void render(Canvas canvas) {
    final progress = timer / timeLimit;
    final progressBarWidth = screenSize.x * 0.8;
    final progressBarHeight = 20.0;
    final progressBarX = (screenSize.x - progressBarWidth) / 2;
    final progressBarY = 50.0;

    // Рисование границ
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final borderRect = Rect.fromLTWH(
      progressBarX,
      progressBarY,
      progressBarWidth,
      progressBarHeight,
    );
    canvas.drawRect(borderRect, borderPaint);

    // Рисование индикатора прогресса
    final progressBarRect = Rect.fromLTWH(
      progressBarX,
      progressBarY,
      progressBarWidth * progress,
      progressBarHeight,
    );
    final progressBarPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawRect(progressBarRect, progressBarPaint);

    // Рисование процентов
    final progressPercentage = (progress * 100).toStringAsFixed(0) + '%';
    final progressTextSpan = TextSpan(
      text: progressPercentage,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
    final progressTextPainter = TextPainter(
      text: progressTextSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    progressTextPainter.layout();
    final progressTextX = progressBarX + (progressBarWidth - progressTextPainter.width) / 2;
    final progressTextY = progressBarY + (progressBarHeight - progressTextPainter.height) / 2;
    progressTextPainter.paint(canvas, Offset(progressTextX, progressTextY));
  }

  @override
  void update(double dt) {
    /*timer += dt;*/
    if (timer > timeLimit) {
      removeFromParent();
    }
  }
}

/*class TimerProgressBar extends Component {
  double _timer = 0;
  double _timeLimit = 120;
  Vector2 screenSize;

  TimerProgressBar(this.screenSize);

  @override
  void render(Canvas canvas) {
    final progress = _timer / _timeLimit;
    final progressBarWidth = screenSize.x * 0.8; // Ширина индикатора прогресса на 80% экрана
    final progressBarHeight = 20.0;
    final progressBarX = (screenSize.x - progressBarWidth) / 2; // Центрирование по X
    final progressBarY = 50.0; // Отступ от верхней границы экрана
    final progressBarRect = Rect.fromLTWH(
      progressBarX,
      progressBarY,
      progressBarWidth * progress,
      progressBarHeight,
    );
    final progressBarPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawRect(progressBarRect, progressBarPaint);

    final progressBarBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(progressBarRect, progressBarBorderPaint);

    // Отрисовка процента заполненности в центре индикатора прогресса
    final progressPercentage = (progress * 100).toStringAsFixed(0) + '%';
    final progressTextSpan = TextSpan(
      text: progressPercentage,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
    final progressTextPainter = TextPainter(
      text: progressTextSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    progressTextPainter.layout();
    final progressTextX = progressBarX + (progressBarWidth * progress) / 2;
    final progressTextY = progressBarY + (progressBarHeight - progressTextPainter.height) / 2;
    progressTextPainter.paint(canvas, Offset(progressTextX, progressTextY));
  }

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer > _timeLimit) {
      _timer = _timeLimit;
    }
  }
}*/
