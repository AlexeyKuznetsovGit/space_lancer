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

abstract class PowerUp extends SpriteComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  late Timer _timer;

  Sprite getSprite();

  void onActivated();

  PowerUp({
    Vector2? position,
    Vector2? size,
    Sprite? sprite,
  }) : super(position: position, size: size, sprite: sprite) {
    _timer = Timer(3, onTick: removeFromParent);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onMount() {
    final shape = CircleHitbox.relative(
      0.5,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);

    sprite = getSprite();

    _timer.start();
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerComponent) {
      gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
        audioPlayer.playSfx('selection.wav');
      }));
      onActivated();
      removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
}

class Health extends PowerUp {
  Health({Vector2? position, Vector2? size}) : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.healthSprite;
  }

  @override
  void onActivated() {
    final command = Command<PlayerComponent>(action: (player) {
      player.increaseHealthBy(10);
    });
    gameRef.addCommand(command);
  }
}

class PowerBullet extends PowerUp {
  PowerBullet({Vector2? position, Vector2? size}) : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.powerBullet;
  }

  @override
  void onActivated() {
    final command = Command<PlayerComponent>(action: (player) {
      player.powerBullet();
    });
    gameRef.addCommand(command);
  }
}

class ForceField extends PowerUp {
  ForceField({Vector2? position, Vector2? size}) : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.forceField;
  }

  @override
  void onActivated() {
    final command = Command<PlayerComponent>(action: (player) {
      player.forceField();
    });
    gameRef.addCommand(command);
  }
}

class Freeze extends PowerUp {
  Freeze({Vector2? position, Vector2? size}) : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.freezeSprite;
  }

  @override
  void onActivated() {
    final command1 = Command<EnemyComponent>(action: (enemy) {
      enemy.freeze();
    });
    gameRef.addCommand(command1);

    final command2 = Command<EnemyCreator>(action: (enemyManager) {
      enemyManager.freeze();
    });
    gameRef.addCommand(command2);

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

class MultiFire extends PowerUp {
  MultiFire({Vector2? position, Vector2? size}) : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return PowerUpManager.multiFireSprite;
  }

  @override
  void onActivated() {
    final command = Command<PlayerComponent>(action: (player) {
      player.shootMultipleBullets();
    });
    gameRef.addCommand(command);
  }
}
