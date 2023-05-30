import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:space_lancer/space_lancer_game.dart';

import 'power_ups.dart';

typedef PowerUpMap = Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)>;

enum PowerUpTypes { health, freeze, multiFire, forceField, powerBullet }

class PowerUpManager extends Component with HasGameRef<SpaceLancerGame> {
  late Timer _spawnTimer;

  late Timer _freezeTimer;

  Random random = Random();

  static late Sprite healthSprite;
  static late Sprite freezeSprite;
  static late Sprite multiFireSprite;
  static late Sprite forceField;
  static late Sprite powerBullet;

  static final PowerUpMap _powerUpMap = {
    PowerUpTypes.powerBullet: (position, size) => PowerBullet(position: position, size: size),
    PowerUpTypes.forceField: (position, size) => ForceField(position: position, size: size),
    PowerUpTypes.health: (position, size) => Health(
          position: position,
          size: size,
        ),
    PowerUpTypes.freeze: (position, size) => Freeze(
          position: position,
          size: size,
        ),
    PowerUpTypes.multiFire: (position, size) => MultiFire(
          position: position,
          size: size,
        ),
  };

  PowerUpManager() : super() {
    _spawnTimer = Timer(5, onTick: _spawnPowerUp, repeat: true);

    _freezeTimer = Timer(2, onTick: () {
      _spawnTimer.start();
    });
  }

  void _spawnPowerUp() {
    Vector2 initialSize = Vector2(48, 48);
    Vector2 position = Vector2(
      random.nextDouble() * gameRef.size.x,
      random.nextDouble() * gameRef.size.y,
    );
    position.clamp(
      Vector2.zero() + initialSize / 2,
      gameRef.size - initialSize / 2,
    );
    int randomIndex = random.nextInt(PowerUpTypes.values.length);
    final fn = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];
    var powerUp = fn?.call(position, initialSize);
    powerUp?.anchor = Anchor.center;
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onMount() {
    _spawnTimer.start();

    healthSprite = Sprite(gameRef.images.fromCache('icon_plusSmall.png'));
    freezeSprite = Sprite(gameRef.images.fromCache('freeze.png'));
    multiFireSprite = Sprite(gameRef.images.fromCache('multi_shot.png'));
    forceField = Sprite(gameRef.images.fromCache('shield.png'));
    powerBullet = Sprite(gameRef.images.fromCache('power.png'));

    super.onMount();
  }

  @override
  void onRemove() {
    _spawnTimer.stop();
    super.onRemove();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
    super.update(dt);
  }

  void reset() {
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  void freeze() {
    _spawnTimer.stop();

    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
