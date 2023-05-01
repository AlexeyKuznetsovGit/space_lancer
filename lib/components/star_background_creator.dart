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

  StarBackGroundCreator({super.animation, super.position}) : super();

  @override
  void update(double dt) {
    super.update(dt);
    final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;
    _timer.limit = starGapTime;
    _timer.update(dt);
  }

  @override
  Future<void> onLoad() async {
    spriteSheet = SpriteSheet(image: await Images().load("stars.png"), srcSize: Vector2(9.0, 9.0));
    final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;
    _timer = Timer(starGapTime, onTick: () => _createRowOfStars(0), repeat: true);
    _createInitialStars();
  }

  void _createStarAt(double x, double y) {
    animation = spriteSheet.createAnimation(row: Random().nextInt(3) + 1, stepTime: (Random().nextInt(50) / 10) + 0.2);
    add(StarComponent(animation: animation, position: Vector2(x, y)));
  }

  void _createRowOfStars(double y) {
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
