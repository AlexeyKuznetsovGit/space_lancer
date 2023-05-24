import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/boss_bullet.dart';
import 'package:space_lancer/components/boss_component.dart';

import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/force_field_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/screens/widgets/game_over.dart';
import 'package:space_lancer/screens/widgets/pause_button.dart';
import 'package:space_lancer/space_lancer_game.dart';

class PlayerComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  Vector2 moveDirection = Vector2.zero();
  static double _speed = 250;
  static double _timeShot = 2;
  int _health = 100;
  late ForceFieldComponent forceFieldSprite;
  double _currentSpeed = 250;

  set changeHealth(int v) => _health = v;

  int get health => _health;
  bool _shootMultipleBullets = false;
  late Timer _powerUpShieldTimer;
  late Timer _powerUpMultiTimer;
  late Timer _powerUpForceTimer;
  late Timer _bulletTimer;
  late PlayerData _playerData;
  late BulletComponent bullet;

  int get score => _playerData.currentScore;
  int level = 1;

  PlayerComponent() : super() {
    _powerUpMultiTimer = Timer(6, onTick: () {
      _shootMultipleBullets = false;
    });
    _powerUpShieldTimer = Timer(6, onTick: () {
      _speed = _currentSpeed;
      forceFieldSprite.removeFromParent();
    });
    _powerUpForceTimer = Timer(6, onTick: () {
      bullet.changeDamage = 10;
      bullet.changeSpeed = 350;
    });
    _bulletTimer = Timer(2, onTick: _createBullet, repeat: true);
  }

  void addToScore(int points) {
    _playerData.currentScore += points;
    // Saves player data to disk.
    _playerData.save();
  }

  @override
  void onMount() {
    super.onMount();
    forceFieldSprite = ForceFieldComponent(position: position.clone());
    /* forceFieldSprite = SpriteComponent.fromImage(
      gameRef.images.fromCache('force_field.png'),
      srcSize: Vector2(1024,1024),
      anchor: Anchor.center,
      position: position.clone(), // Set your position here
      size: Vector2(100, 100), // Set your size here (by default it is 0),
    );*/
    _playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);
  }

  @override
  Future<void> onLoad() async {
/*    gameRef.add(ForceFieldComponent(position: position));*/

    add(CircleHitbox());
    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('player.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(32, 48),
        stepTime: 0.2,
      ),
    );
    position = gameRef.size / 2;
    width = 64;
    height = 96;
    anchor = Anchor.center;
  }

  final _superBulletAngles = [0.5, 0.3, 0.0, -0.5, -0.3];
  final _bulletAngles = 0.0;

  void _createBullet() {
    log(_speed.toString(), name: "СКОРОСТЬ");

    if (_shootMultipleBullets) {
      gameRef.addAll(
        _superBulletAngles.map(
          (angle) => BulletComponent(
            position: position + Vector2(-5, -size.y / 2),
            angle: angle,
          ),
        ),
      );
    } else {
      bullet = BulletComponent(position: position + Vector2(-8, -size.y / 2), angle: _bulletAngles);
      gameRef.add(bullet);
    }
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laserSmall_001.mp3');
    }));
  }

  void increaseHealthBy(int points) {
    _health += points;
    // Clamps health to 100.
    if (_health > 100) {
      _health = 100;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    forceFieldSprite.position = position.clone();
    _powerUpForceTimer.update(dt);
    _powerUpShieldTimer.update(dt);
    _powerUpMultiTimer.update(dt);
    _bulletTimer.update(dt);
    position += moveDirection.normalized() * _speed * dt;

    position.clamp(
      Vector2.zero() + size / 2,
      gameRef.size - size / 2,
    );

    level = GameUtils.getCurrentLevel(score);
    if (forceFieldSprite.isMounted) {
      _speed = 500;
    } else {
      switch (level) {
        case 1:
          {
            _timeShot = 2;
            _currentSpeed = 250;
            _speed = _currentSpeed;
            break;
          }
        case 2:
          {
            _timeShot = 1.5;
            _currentSpeed = 300;
            _speed = _currentSpeed;
            break;
          }
        case 3:
          {
            _timeShot = 1;
            _currentSpeed = 350;
            _speed = _currentSpeed;
            break;
          }
        case 4:
          {
            _timeShot = 0.5;
            _currentSpeed = 400;
            _speed = _currentSpeed;
            break;
          }
      }
    }

    _bulletTimer.limit = _timeShot;
  }

  void reset() {
    forceFieldSprite.removeFromParent();
    _playerData.currentScore = 0;
    position = gameRef.size / 2;
    _health = 100;
    _currentSpeed = 250;
    _speed = 250;
    _timeShot = 2;
    beginFire();
  }

  void beginFire() {
    _bulletTimer.start();
  }

  void stopFire() {
    _bulletTimer.pause();
  }

  void takeHit() {
    gameRef.add(ExplosionComponent(position: position));
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    moveDirection = newMoveDirection;
  }

  void destroy() {
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.ogg');
    }));
    gameRef.add(ExplosionComponent(position: position));
    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyComponent) {
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
        destroy();
      }
    }
    if (other is BossComponent) {
      gameRef.add(ExplosionComponent(position: position));
      position.y += 50;
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
        destroy();
      }
    }
    if (other is BossBullet) {
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
        destroy();
      }
    }
  }

  void powerBullet() {
    bullet.changeDamage = 20;
    bullet.changeSpeed = 500;
    _powerUpForceTimer.stop();
    _powerUpForceTimer.start();
  }

  void forceField() {
    if (forceFieldSprite.isMounted) {
      forceFieldSprite.removeFromParent();
      forceFieldSprite = ForceFieldComponent(position: position.clone());
    }
    /*gameRef.add(forceFieldSprite);*/

    gameRef.add(forceFieldSprite);
    _powerUpShieldTimer.stop();
    _powerUpShieldTimer.start();
  }

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpMultiTimer.stop();
    _powerUpMultiTimer.start();
  }
}
