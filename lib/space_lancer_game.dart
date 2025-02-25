import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/boss_bullet.dart';
import 'package:space_lancer/components/boss_component.dart';
import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/enemy_creator.dart';
import 'package:space_lancer/components/force_field_component.dart';
import 'package:space_lancer/components/health_bar.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/components/power_up_manager.dart';
import 'package:space_lancer/components/power_ups.dart';
import 'package:space_lancer/components/progress_indicator.dart';
import 'package:space_lancer/components/star_background_creator.dart';
import 'package:space_lancer/screens/widgets/game_over.dart';
import 'package:space_lancer/screens/widgets/game_win.dart';
import 'package:space_lancer/screens/widgets/pause_button.dart';

class SpaceLancerGame extends FlameGame with PanDetector, HasCollisionDetection {
  late final PlayerComponent player;
  late final TextComponent componentCounter;
  late final TextComponent scoreText;
  late final TextComponent levelText;

  late TextComponent _playerHealth;
  late EnemyCreator _enemyCreator;
  late PowerUpManager _powerUpManager;
  late AudioPlayerComponent audioPlayerComponent;
  late BossComponent _boss;
  late ForceFieldComponent forceField;
  Rect boundaries = Rect.zero;
  late Timer timerWinGame;
  late Timer timerLoseGame;

  double timer = 0;
  double timeLimit = 120;

  /*late PowerUpManager _powerUpManager;*/
  Offset? pointerStarPosition;
  Offset? pointerCurrentPosition;
  final double joystickRadius = 80;
  final double deadZoneRadius = 0;
  late TimerProgressBar _progressBar;

  /*Vector2 fixedResolution = Vector2(540, 960);*/
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  int score = 0;
  bool bossSpawn = false;

  SpaceLancerGame() : super() {
    timerWinGame = Timer(2, onTick: () {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameWin.id);
    }, autoStart: false);
    timerLoseGame = Timer(2, onTick: () {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameOverMenu.id);
    }, autoStart: false);
  }

  @override
  Future<void> onLoad() async {
    boundaries = Rect.fromLTWH(10, 0, size.x - 20, size.y);
    _boss = BossComponent();
    await images.loadAll([
      'bullet.png',
      'enemy.png',
      'explosion.png',
      'player.png',
      'stars.png',
      'freeze.png',
      'icon_plusSmall.png',
      'multi_shot.png',
      'boss_ship.png',
      'force_field.png',
      'shield.png',
      'power.png'
    ]);

    final joystick = JoystickComponent(
      anchor: Anchor.bottomRight,
      position: Vector2(size.x -40, size.y -40),
      background: CircleComponent(
        radius: 70,
        paint: Paint()..color = Colors.grey.withAlpha(100),
      ),
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white.withAlpha(100)),
    );
    add(joystick);

    add(
      scoreText = TextComponent(
        text: 'Опыт: 0',
        position: Vector2(size.x - 10, 10),
        anchor: Anchor.topRight,
        priority: 1,
      ),
    );
    add(
      levelText = TextComponent(
        text: 'Уровень: 1',
        position: Vector2(10, 10),
        anchor: Anchor.topLeft,
        priority: 1,
      ),
    );

    add(audioPlayerComponent = AudioPlayerComponent());

    add(_enemyCreator = EnemyCreator());
    add(_powerUpManager = PowerUpManager());
    add(StarBackGroundCreator());

    add(player = PlayerComponent(joystick: joystick));
    _playerHealth = TextComponent(
        text: 'Прочность: 100%',
        position: Vector2(size.x / 2, size.y - 5),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'BungeeInline',
          ),
        ),
        priority: 1);

    _playerHealth.anchor = Anchor.bottomCenter;

    _playerHealth.positionType = PositionType.viewport;

    add(_playerHealth);

    add(_progressBar = TimerProgressBar(size, timer, timeLimit));

    add(
      HealthBar(
        player: player,
        position: Vector2(size.x / 2, size.y - 15),
        anchor: Anchor.bottomCenter,
        priority: 0,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    timerLoseGame.update(dt);
    timerWinGame.update(dt);
    timer += dt;
    _progressBar.timer = timer;
    if (timer > timeLimit && !bossSpawn) {
      add(_boss);
      bossSpawn = !bossSpawn;
    }

    if (timer > timeLimit) {
      _enemyCreator.timer.stop();
    }

    for (var command in _commandList) {
      for (var component in children) {
        command.run(component);
      }
    }

    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    if (player.isMounted) {
      score = player.score;
      levelText.text = 'Уровень: ${player.level}';

      scoreText.text = 'Опыт: ${player.score}';
      _playerHealth.text = 'Прочность: ${player.health}%';
      if (player.health <= 0) {
        timerLoseGame.start();
      }
    }

    if (_boss.isMounted) {
      if (_boss.hitPoints <= 0) {
        player.stopFire();
        timerWinGame.start();
      }
    }
    timerLoseGame.update(dt);
    timerWinGame.update(dt);
  }

  @override
  void onAttach() {
    audioPlayerComponent.playBgm('background.mp3');
    super.onAttach();
  }

  @override
  void onDetach() {
    audioPlayerComponent.stopBgm();
    super.onDetach();
  }

  /* @override
  void handlePanStart(DragStartDetails details) {
    onPanStart(DragStartInfo.fromDetails(this, details));
    pointerStarPosition = details.globalPosition;
    pointerCurrentPosition = details.globalPosition;
  }

  @override
  void handlePanUpdate(DragUpdateDetails details) {
    onPanUpdate(DragUpdateInfo.fromDetails(this, details));
    pointerCurrentPosition = details.globalPosition;

    var delta = pointerCurrentPosition! - pointerStarPosition!;
    if (delta.distance > deadZoneRadius) {
      player.setMoveDirection(Vector2(delta.dx, delta.dy));
    } else {
      player.setMoveDirection(Vector2.zero());
    }
  }

  @override
  void handlePanEnd(DragEndDetails details) {
    onPanEnd(DragEndInfo.fromDetails(this, details));
    pointerStarPosition = null;
    pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
  }

  @override
  void onPanCancel() {
    pointerCurrentPosition = null;
    pointerStarPosition = null;
    player.setMoveDirection(Vector2.zero());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (pointerStarPosition != null) {
      canvas.drawCircle(pointerStarPosition!, joystickRadius, Paint()..color = Colors.grey.withAlpha(100));
    }
    if (pointerCurrentPosition != null) {
      var delta = pointerCurrentPosition! - pointerStarPosition!;
      if (delta.distance > joystickRadius) {
        delta = pointerStarPosition! + (Vector2(delta.dx, delta.dy).normalized() * joystickRadius).toOffset();
      } else {
        delta = pointerCurrentPosition!;
      }
      canvas.drawCircle(delta, 20, Paint()..color = Colors.white.withAlpha(100));
    }
  }*/

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void restoreHealth() {
    if (player.isRemoved) {
      add(player);
      player.changeHealth = 100;
    }
  }

  void reset() {
    if (player.isRemoved) {
      add(player);
    }
    audioPlayerComponent.stopBgm();
    player.reset();
    /* if(_enemyCreator.isRemoved){
      add(_enemyCreator = EnemyCreator(timer: timer, timeLimit: timeLimit));
    } else{
      _enemyCreator.reset();
    }*/
    timer = 0;
    _enemyCreator.reset();
    _powerUpManager.reset();

    bossSpawn = false;
    _boss.reset();
    add(_progressBar = TimerProgressBar(size, timer, timeLimit));
    children.whereType<EnemyComponent>().forEach((enemy) {
      enemy.removeFromParent();
    });

    children.whereType<BulletComponent>().forEach((bullet) {
      bullet.removeFromParent();
    });

    children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
    children.whereType<TimerProgressBar>().forEach((progress) {
      progress.removeFromParent();
    });
    children.whereType<BossComponent>().forEach((boss) {
      boss.removeFromParent();
    });
    children.whereType<BossBullet>().forEach((bossBullet) {
      bossBullet.removeFromParent();
    });
    audioPlayerComponent.playBgm('background.mp3');
  }

/*void increaseScore([int? point]) {
    point == null ? score++ : score += point;
  }*/
}
