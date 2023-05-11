import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:space_lancer/space_lancer_game.dart';

import 'power_ups.dart';

typedef PowerUpMap
= Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)>;

// Represents the types of power up we have to offer.
enum PowerUpTypes { health, freeze, multiFire }

// This class/component is responsible for spawning random power ups
// at random locations in the game world.
class PowerUpManager extends Component with HasGameRef<SpaceLancerGame> {
  // Controls the frequency of spawning power ups.
  late Timer _spawnTimer;

  // Controls the amount of time for which this component
  /// should be freezed when [Freeze] power is activated.
  late Timer _freezeTimer;

  // A random number generator.
  Random random = Random();

  // Storing these static sprites so that
  // they stay alive across multiple restarts.
  static late Sprite healthSprite;
  static late Sprite freezeSprite;
  static late Sprite multiFireSprite;

  // A private static map which stores a generator function for each power up.
  static final PowerUpMap _powerUpMap = {
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
    // Makes sure that a new power up is spawned every 5 seconds.
    _spawnTimer = Timer(5, onTick: _spawnPowerUp, repeat: true);

    // Restarts the spawn timer after 2 seconds are
    // elapsed from start of freeze timer.
    _freezeTimer = Timer(2, onTick: () {
      _spawnTimer.start();
    });
  }

  // This method is responsible for generating a
  // random power up at random location on the screen.
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
    // Start the spawn timer as soon as this component is mounted.
    _spawnTimer.start();

    healthSprite = Sprite(gameRef.images.fromCache('icon_plusSmall.png'));
    freezeSprite = Sprite(gameRef.images.fromCache('freeze.png'));
    multiFireSprite = Sprite(gameRef.images.fromCache('multi_fire.png'));

    super.onMount();
  }

  @override
  void onRemove() {
    // Stop the spawn timer as soon as this component is removed.
    _spawnTimer.stop();
    super.onRemove();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
    super.update(dt);
  }

  // This method gets called when the game is being restarted.
  void reset() {
    // Stop all the timers.
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  // This method gets called when freeze power is activated.
  void freeze() {
    // Stop the spawn timer.
    _spawnTimer.stop();

    // Restart the freeze timer.
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}