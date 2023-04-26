import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/space_lancer_game.dart';

class BulletComponent extends SpriteAnimationComponent
    with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  static const  speed = 350.0;
  late final Vector2 velocity;
  final Vector2 deltaPosition = Vector2.zero();

  BulletComponent({required super.position, super.angle})
      : super(size: Vector2(16, 32));

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    animation = await gameRef.loadSpriteAnimation(
      'bullet.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(8, 16),
      ),
    );
    velocity = Vector2(0, -1)
      ..rotate(angle)
      ..scale(speed);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is EnemyComponent) {
    /*  other.takeHit();*/
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    deltaPosition
      ..setFrom(velocity)
      ..scale(dt);
    position += deltaPosition;

    if (position.y < 0 ||
        position.x > gameRef.size.x ||
        position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
