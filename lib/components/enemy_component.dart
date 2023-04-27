import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/models/enemy_model.dart';
import 'package:space_lancer/space_lancer_game.dart';

class EnemyComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  double _speed = 150;

   static Vector2 initialSize = Vector2.all(25);
  late Timer _freezeTimer;
  Vector2 moveDirection = Vector2(0, 1);
  final _random = Random();

  // The data required to create this enemy.
  final EnemyData enemyData;
  int _hitPoints = 10;

  final _hpText = TextComponent(
    text: '10 HP',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'BungeeInline',
      ),
    ),
  );

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  // Returns a random direction vector with slight angle to +ve y axis.
  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1)).normalized();
  }

  EnemyComponent({
    required Vector2 position,
    required Vector2 size,
    required this.enemyData,
  }) : super(position: position, size: size) {
    _speed = enemyData.speed;
    _hitPoints = enemyData.level * 10;
    _hpText.text = '$_hitPoints HP';

    _freezeTimer = Timer(2, onTick: () {
      _speed = enemyData.speed;
    });
    if (enemyData.hMove) {
      moveDirection = getRandomDirection();
    }
  }

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2.all(16),
      ),
    );
    add(CircleHitbox()..collisionType = CollisionType.passive);
    _hpText.position = Vector2(0, -20);

    // Add as child of current component.
    add(_hpText);
  }

  /* @override
  void update(double dt) {
    super.update(dt);
    y += _speed * dt;
    if (y >= gameRef.size.y) {
      removeFromParent();
    }
    _freezeTimer.update(dt);
  }*/

  @override
  void update(double dt) {
    super.update(dt);

    // Sync-up text component and value of hitPoints.
    _hpText.text = '$_hitPoints HP';

    // If hitPoints have reduced to zero,
    // destroy this enemy.
    if (_hitPoints <= 0) {
      destroy();
      gameRef.increaseScore();
    }

    _freezeTimer.update(dt);

    // Update the position of this enemy using its speed and delta time.
    position += moveDirection * _speed * dt;

    // If the enemy leaves the screen, destroy it.
    if (position.y > gameRef.size.y) {
      removeFromParent();
    } else if ((position.x < size.x / 2) || (position.x > (gameRef.size.x - size.x / 2))) {
      // Enemy is going outside vertical screen bounds, flip its x direction.
      moveDirection.x *= -1;
    }
  }

  void destroy() {
    // Ask audio player to play enemy destroy effect.
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.ogg');
    }));

    removeFromParent();


  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is BulletComponent) {
      // If the other Collidable is a Bullet,
      // reduce health by level of bullet times 10.
      _hitPoints -= 10;
      gameRef.add(ExplosionComponent(position: position));
    } else if (other is PlayerComponent) {
      // If the other Collidable is Player, destroy.
      gameRef.add(ExplosionComponent(position: position));
      destroy();
    }
  }

  /* void takeHit() {

    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.ogg');
    }));
    _hitPoints -= other.level * 10;
   */ /* removeFromParent();
    gameRef.add(ExplosionComponent(position: position));
    gameRef.increaseScore();*/ /*
  }*/

  void freeze() {
    _speed = 50;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
