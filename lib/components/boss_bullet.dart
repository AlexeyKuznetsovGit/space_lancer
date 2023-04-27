import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_lancer/components/boss_component.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/space_lancer_game.dart';

class BossBullet extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  static const speed = 350.0;

  late final Vector2 velocity;
  Vector2 direction = Vector2(0, 1);

  BossBullet({required super.position, super.angle}) : super(size: Vector2(16, 32)){
    /*angle = pi;*/
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    animation = await gameRef.loadSpriteAnimation(
      'bullet_rev.png',
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
    if (other is PlayerComponent) {
      /*  other.takeHit();*/
      gameRef.add(ExplosionComponent(position: position.clone()));
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    direction
      ..setFrom(velocity)
      ..scale(dt);
    position -= direction;

    if (position.y >= gameRef.size.y || position.x > gameRef.size.x || position.x + size.x < 0) {
      print('da');
      removeFromParent();
    }
  }
}
