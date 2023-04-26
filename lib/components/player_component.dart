import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_lancer/components/audio_player_component.dart';

import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/explosion_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/space_lancer_game.dart';

class PlayerComponent extends SpriteAnimationComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  Vector2 moveDirection = Vector2.zero();
  late TimerComponent bulletCreator;
  static double speed = 250;
  int _health = 100;

  int get health => _health;
  bool _shootMultipleBullets = false;
  late Timer _powerUpTimer;
  late Timer _bulletTimer;

  PlayerComponent() : super() {
    _powerUpTimer = Timer(6, onTick: () {
      _shootMultipleBullets = false;
    });
    _bulletTimer = Timer(2, onTick: _createBullet, repeat: true);
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    /*add(
      bulletCreator = TimerComponent(
        period: 2,
        repeat: true,
        onTick: _createBullet,
      ),
    );*/
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('player.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(32, 48),
        stepTime: 0.2,
      ),
    ); /*await gameRef.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(32, 48),
      ),
    );*/
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
    game.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
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
      /*_superBulletAngles.map((angle) {
        BulletComponent bullet = BulletComponent(
          position: position + Vector2(-5, -size.y / 2),
          angle: angle,
        );
        gameRef.add(bullet);
      });*/
    }

    /*gameRef.addAll(
      _superBulletAngles.map(
        (angle) => BulletComponent(
          position: position + Vector2(-5, -size.y / 2),
          angle: angle,
        ),
      ),
    );*/
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
    this.position += moveDirection.normalized() * speed * dt;

    position.clamp(
      Vector2.zero() + size / 2,
      gameRef.size - size / 2,
    );

    int currentLevel = GameUtils.getCurrentLevel(gameRef.score);
    double timeShot = 2;
    switch (currentLevel) {
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
    position = gameRef.size / 2;
    _health = 100;
  }

  /*void beginFire() {
    bulletCreator.timer.start();
  }*/

  void stopFire() {
    bulletCreator.timer.pause();
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

    // If other entity is an Enemy, reduce player's health by 10.
    if (other is EnemyComponent) {
      // Make the camera shake, with custom intensity.
      // TODO: Investigate how camera shake should be implemented in new camera system.
      // game.primaryCamera.viewfinder.add(
      //   MoveByEffect(
      //     Vector2.all(10),
      //     PerlinNoiseEffectController(duration: 1),
      //   ),
      // );
      gameRef.camera.shake(intensity: 20);
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

/*  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is EnemyComponent) {
      other.takeHit();
      gameRef.camera.shake(intensity: 20);

      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }*/

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }
}
