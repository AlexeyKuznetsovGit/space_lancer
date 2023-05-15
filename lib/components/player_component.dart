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
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/space_lancer_game.dart';

class PlayerComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  Vector2 moveDirection = Vector2.zero();
  static double speed = 250;
 static double timeShot = 2;
  int _health = 100;

  int get health => _health;
  bool _shootMultipleBullets = false;
  late Timer _powerUpTimer;
  late Timer _bulletTimer;
  late PlayerData _playerData;
  int get score => _playerData.currentScore;
  int level = 1;

  PlayerComponent() : super() {
    _powerUpTimer = Timer(6, onTick: () {
      _shootMultipleBullets = false;
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

    _playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);
  }

  @override
  Future<void> onLoad() async {
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
    BulletComponent bullet = BulletComponent(position: position + Vector2(-8, -size.y / 2), angle: _bulletAngles);
    gameRef.add(bullet);
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laserSmall_001.ogg');
    }));
    if (_shootMultipleBullets) {
      gameRef.addAll(
        _superBulletAngles.map(
          (angle) => BulletComponent(
            position: position + Vector2(-5, -size.y / 2),
            angle: angle,
          ),
        ),
      );

    }


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
    _powerUpTimer.update(dt);
    _bulletTimer.update(dt);
    position += moveDirection.normalized() * speed * dt;

    position.clamp(
      Vector2.zero() + size / 2,
      gameRef.size - size / 2,
    );

    int level = GameUtils.getCurrentLevel(score);

    switch (level) {
      case 1:
        {
          timeShot = 2;
          speed = 250;
          break;
        }
      case 2:
        {
          timeShot = 1.5;
          speed = 300;
          break;
        }
      case 3:
        {
          timeShot = 1;
          speed = 350;
          break;
        }
      case 4:
        {
          timeShot = 0.5;
          speed = 400;
          break;
        }
    }
    _bulletTimer.limit = timeShot;
  }

  void reset() {
    _playerData.currentScore = 0;
    position = gameRef.size / 2;
    _health = 100;
    speed = 250;
    timeShot = 2;
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyComponent) {
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
    if(other is BossComponent){
      gameRef.add(ExplosionComponent(position: position));
      position.y += 50;
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }

    }
    if(other is BossBullet){
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }
}
