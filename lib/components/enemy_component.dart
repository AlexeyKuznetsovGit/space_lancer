import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/force_field_component.dart';
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

    _freezeTimer = Timer(4, onTick: () {
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

    add(_hpText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _hpText.text = '$_hitPoints HP';
    if (_hitPoints <= 0) {
      destroy();
    }
    _freezeTimer.update(dt);
    position += moveDirection.normalized() * _speed * dt;
    if(enemyData.hMove){
      if (position.x -size.x/2 <= gameRef.boundaries.left) {
        moveDirection.x = 1;
      } else if (position.x >= gameRef.boundaries.right-size.x) {
        moveDirection.x = -1;
      }
    } else{
       x = x.clamp(gameRef.boundaries.left, gameRef.boundaries.right - width);
    }




    if (position.y > gameRef.size.y) {
      removeFromParent();
    }



  }

  void destroy() {
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.wav');
    }));

    final command = Command<PlayerComponent>(action: (player) {
      // Use the correct killPoint to increase player's score.
      player.addToScore(enemyData.killPoint);
    });
    gameRef.addCommand(command);

    removeFromParent();


  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is BulletComponent) {
      _hitPoints -= BulletComponent.damage;
      gameRef.add(ExplosionComponent(position: position));
    } else if (other is PlayerComponent) {
      gameRef.add(ExplosionComponent(position: position));
      destroy();
    } else if(other is ForceFieldComponent){
      gameRef.add(ExplosionComponent(position: position));
      destroy();
    }
  }
  void freeze() {
    _speed = 50;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
