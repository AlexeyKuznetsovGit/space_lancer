import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:space_lancer/components/boss_component.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/enemy_creator.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/space_lancer_game.dart';

import 'command.dart';
import 'power_up_manager.dart';
import 'audio_player_component.dart';

// An abstract class which represents power ups in this game.
/// See [Freeze], [Health], [MultiFire] and for example.
abstract class PowerUp extends SpriteComponent
    with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  // Controls how long the power up should be visible
  // before getting destroyed if not picked.
  late Timer _timer;

  // Abstract method which child classes should override
  /// and return a [Sprite] for the power up.
  Sprite getSprite();

  // Abstract method which child classes should override
  // and perform any activation event necessary.
  void onActivated();

  PowerUp({
    Vector2? position,
    Vector2? size,
    Sprite? sprite,
  }) : super(position: position, size: size, sprite: sprite) {
    // Power ups will be displayed only for 3 seconds
    // before getting destroyed.
    _timer = Timer(3, onTick: removeFromParent);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onMount() {
    // Add a circular hit box for this power up.
    final shape = CircleHitbox.relative(
      0.5,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);

    // Set the correct sprite by calling overriden getSprite method.
    sprite = getSprite();

    // Start the timer.
    _timer.start();
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // If the other entity is Player, call the overriden
    // onActivated method and mark this component to be removed.
    if (other is PlayerComponent) {
      // Ask audio player to play power up activation effect.
      gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
        audioPlayer.playSfx('powerUp6.ogg');
      }));
      onActivated();
      removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
}


// This power up increases player health by 10.
class Health extends PowerUp {
  Health({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.healthSprite;
  }

  @override
  void onActivated() {
    // Register a command to increase player health.
    final command = Command<PlayerComponent>(action: (player) {
      player.increaseHealthBy(10);
    });
    gameRef.addCommand(command);
  }
}

class PowerBullet extends PowerUp {
  PowerBullet({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.powerBullet;
  }

  @override
  void onActivated() {
    // Register a command to increase player health.
    final command = Command<PlayerComponent>(action: (player) {
      player.powerBullet();
    });
    gameRef.addCommand(command);
  }
}

class ForceField extends PowerUp {
  ForceField({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.forceField;
  }

  @override
  void onActivated() {
    // Register a command to increase player health.
    final command = Command<PlayerComponent>(action: (player) {
      player.forceField();
    });
    gameRef.addCommand(command);
  }
}


// This power up freezes all enemies for some time.
class Freeze extends PowerUp {
  Freeze({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.freezeSprite;
  }

  @override
  void onActivated() {
    // Register a command to freeze all enemies.
    final command1 = Command<EnemyComponent>(action: (enemy) {
      enemy.freeze();
    });
    gameRef.addCommand(command1);

    /// Register a command to freeze [EnemyManager].
    final command2 = Command<EnemyCreator>(action: (enemyManager) {
      enemyManager.freeze();
    });
    gameRef.addCommand(command2);

    /// Register a command to freeze [PowerUpManager].
    final command3 = Command<PowerUpManager>(action: (powerUpManager) {
      powerUpManager.freeze();
    });
    gameRef.addCommand(command3);

    final command4 = Command<BossComponent>(action: (boss) {
      boss.freeze();
    });
    gameRef.addCommand(command4);
  }
}

// This power up activate multi-fire for some time.
class MultiFire extends PowerUp {
  MultiFire({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.multiFireSprite;
  }

  @override
  void onActivated() {
    // Register a command to allow multiple bullets.
    final command = Command<PlayerComponent>(action: (player) {
      player.shootMultipleBullets();
    });
    gameRef.addCommand(command);
  }
}