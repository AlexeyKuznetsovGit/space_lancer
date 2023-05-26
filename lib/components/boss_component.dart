import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/boss_bullet.dart';
import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/models/enemy_model.dart';
import 'package:space_lancer/space_lancer_game.dart';

class BossComponent extends SpriteComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  double speed = 150;
  double _currentSpeed = 150;
  double _xDirection = 1.0;
  double _yDirection = 1.0;
  double _yPosition = 0;
  static const double minY = 0;
  static const double maxY = 0.5; // Максимальная высота - половина экрана
  Random random = Random();
  double timeBullet = 2;
  late Timer _bulletTimer;
  late Timer _freezeTimer;
  late Timer _changeDirectionTimer;

  int hitPoints = 1000;

  final _hpText = TextComponent(
    text: '1000 HP',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'BungeeInline',
      ),
    ),
  );

  BossComponent() : super() {
    _hpText.text = '$hitPoints HP';
    _freezeTimer = Timer(4, onTick: () {
      speed = _currentSpeed;
    });

    _bulletTimer = Timer(timeBullet, onTick: _createBullet, repeat: true);

    anchor = Anchor.topCenter;

    size = Vector2(128, 128);
    _changeDirectionTimer = Timer(1, onTick: () {
      _xDirection = Random().nextBool() ? 1 : -1;
    }, repeat: true);
  }

  final _superBulletAngles = [0.5, 0.3, 0.0, -0.5, -0.3];

  void _createBullet() {
    /* BossBullet bullet = BossBullet(position: position - Vector2(size.x / 4, -size.y), angle: 0.0);
    gameRef.add(bullet);*/
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laserSmall_001.wav');
    }));
    gameRef.addAll(
      _superBulletAngles.map(
        (angle) => BossBullet(
          position: position - Vector2(size.x / 4, -size.y),
          angle: angle,
        ),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 4);
    sprite = Sprite(gameRef.images.fromCache('boss_ship.png'), srcSize: Vector2(128, 128));
    add(CircleHitbox()..collisionType = CollisionType.passive);

    _hpText.position = Vector2(20, -20);

    // Add as child of current component.
    add(_hpText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Sync-up text component and value of hitPoints.
    _hpText.text = '$hitPoints HP';
    if (hitPoints <= hitPoints / 2) {
      _currentSpeed = 250;
      speed = _currentSpeed;
      timeBullet = 1;
    }
    // If hitPoints have reduced to zero,
    // destroy this enemy.
    if (hitPoints <= 0) {
      destroy();
    }
    _bulletTimer.update(dt);

    _freezeTimer.update(dt);
    _changeDirectionTimer.update(dt);



    position.x += speed * _xDirection * dt;
   /* x = x.clamp(boundaries.left, boundaries.right - width);*/
    if (position.x - size.x/2<= gameRef.boundaries.left) {
      _xDirection = 1;
    } else if (position.x >= gameRef.boundaries.right) {
      _xDirection = -1;
    }

    position.y += speed * _yDirection * dt;

    if (position.y + size.y / 2 >= gameRef.size.y / 2) {
      _yDirection = -1;
    }

    if (position.y <= _yPosition) {
      _yDirection = 1;
    }
  }


  void reset() {
    hitPoints = 1000;
    speed = 150;
    timeBullet = 2;
    _currentSpeed = 150;
  }

  void destroy() {
    // Ask audio player to play enemy destroy effect.
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.wav');
    }));

    final command = Command<PlayerComponent>(action: (player) {
      // Use the correct killPoint to increase player's score.
      player.addToScore(100);
    });
    gameRef.addCommand(command);

    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is BulletComponent) {
      hitPoints -= BulletComponent.damage;
      gameRef.add(ExplosionComponent(position: position));
    }
  }

  void freeze() {
    speed = 50;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
