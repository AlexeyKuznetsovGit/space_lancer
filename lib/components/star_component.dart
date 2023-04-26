import 'package:flame/components.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/space_lancer_game.dart';

class StarComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame> {
  static int speed = 20;

  StarComponent({super.animation, super.position})
      : super(size: Vector2.all(20));

  @override
  void update(double dt) {
    super.update(dt);
    y += dt * speed;
    if (y >= gameRef.size.y) {
      removeFromParent();
    }

    int currentLevel = GameUtils.getCurrentLevel(gameRef.score);

    switch (currentLevel) {
      case 1:
        {
          speed = 20;
          break;
        }
      case 2:
        {
          speed = 40;
          break;
        }
      case 3:
        {
          speed = 60;
          break;
        }
      case 4:
        {
          speed = 80;
          break;
        }
    }

  }
}
