import 'package:flame/components.dart';
import 'package:space_lancer/space_lancer_game.dart';

class ExplosionComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame> {
  ExplosionComponent({super.position})
      : super(
          size: Vector2.all(50),
          anchor: Anchor.center,
          removeOnFinish: true,
        );

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.1,
        amount: 6,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
