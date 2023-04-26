import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/cache.dart';
import 'package:space_lancer/components/star_component.dart';
import 'package:space_lancer/space_lancer_game.dart';

class StarBackGroundCreator extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame> {
  final gapSize = 12;
  late Timer _timer;
  late final SpriteSheet spriteSheet;
  Random random = Random();

  StarBackGroundCreator({super.animation, super.position}) : super() {
    /*add(
      TimerComponent(
        period: starGapTime,
        repeat: true,
        onTick: () => _createRowOfStars(0),
      ),
    );*/
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update timers with delta time to make them tick.
    final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;
    _timer.limit = starGapTime;
    _timer.update(dt);
  }

  @override
  Future<void> onLoad() async {
    /*spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: await gameRef.images.load('stars.png'),
      rows: 4,
      columns: 4,
    );*/
    /*var x = Random().nextInt((gameRef.size.toRect().width - size).toInt()).toDouble();
    var y = Random().nextInt((gameRef.size.toRect().height - size).toInt()).toDouble();*/
    spriteSheet = SpriteSheet(image: await Images().load("stars.png"), srcSize: Vector2(9.0, 9.0));
    final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;
    _timer = Timer(starGapTime, onTick: () => _createRowOfStars(0), repeat: true);
    /*final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;

    add(
      TimerComponent(
        period: starGapTime,
        repeat: true,
        onTick: () => _createRowOfStars(0),
      ),
    );*/

    _createInitialStars();
  }

  void _createStarAt(double x, double y) {
    /*final animation = spriteSheet.createAnimation(
      row: random.nextInt(3),
      to: 4,
      stepTime: 0.1,
    )..variableStepTimes = [max(20, 100 * random.nextDouble()), 0.1, 0.1, 0.1];*/
    animation = spriteSheet.createAnimation(row: Random().nextInt(3) + 1, stepTime: (Random().nextInt(50) / 10) + 0.2);
    add(StarComponent(animation: animation, position: Vector2(x, y)));
    /*gameRef.add(StarComponent(animation: animation, position: Vector2(x, y)));*/
  }

  void _createRowOfStars(double y) {
    var size = Random().nextInt(10).toDouble() + 10;
    int gapSize = Random().nextInt(5) + 1;
    final starGap = gameRef.size.x / gapSize;
    for (var i = 0; i < gapSize; i++) {
      _createStarAt(
        starGap * i + (random.nextDouble() * starGap),
        y + (random.nextDouble() * 20),
      );
    }
  }

  void _createInitialStars() {
    final rows = gameRef.size.y / gapSize;

    for (var i = 0; i < gapSize; i++) {
      _createRowOfStars(i * rows);
    }
  }
}
