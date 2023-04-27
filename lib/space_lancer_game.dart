import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/boss_component.dart';
import 'package:space_lancer/components/bullet_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/enemy_creator.dart';
import 'package:space_lancer/components/health_bar.dart';
import 'package:space_lancer/components/player_component.dart';
import 'package:space_lancer/components/power_up_manager.dart';
import 'package:space_lancer/components/power_ups.dart';
import 'package:space_lancer/components/progress_indicator.dart';
import 'package:space_lancer/components/star_background_creator.dart';
import 'package:space_lancer/screens/widgets/game_over.dart';
import 'package:space_lancer/screens/widgets/pause_button.dart';

class SpaceLancerGame extends FlameGame with PanDetector, HasCollisionDetection {
  late final PlayerComponent player;
  late final TextComponent componentCounter;
  late final TextComponent scoreText;
  late TextComponent _playerHealth;
  late EnemyCreator _enemyCreator;
  late PowerUpManager _powerUpManager;
  late AudioPlayerComponent _audioPlayerComponent;
   double timer = 0;
   double timeLimit = 1;

  /*late PowerUpManager _powerUpManager;*/
  Offset? pointerStarPosition;
  Offset? pointerCurrentPosition;
  final double joystickRadius = 60;
  final double deadZoneRadius = 15;
  late TimerProgressBar _progressBar;

  /*Vector2 fixedResolution = Vector2(540, 960);*/
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  int score = 0;
  bool bossSpawn = false;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'bullet.png',
      'enemy.png',
      'explosion.png',
      'player.png',
      'stars.png',
      'freeze.png',
      'icon_plusSmall.png',
      'multi_fire.png',
      'boss_ship.png'
    ]);

    add(
      scoreText = TextComponent(
        position: size - Vector2(0, size.y),
        anchor: Anchor.topRight,
        priority: 1,
      ),
    );

    add(_audioPlayerComponent = AudioPlayerComponent());

    add(_enemyCreator = EnemyCreator(timer: timer,timeLimit: timeLimit));
    add(_powerUpManager = PowerUpManager());
    add(StarBackGroundCreator());
    add(player = PlayerComponent());
    _playerHealth = TextComponent(
      text: 'Прочность: 100%',
      position: Vector2(size.x / 2, size.y),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'BungeeInline',
        ),
      ),
    );

    _playerHealth.anchor = Anchor.bottomCenter;

    _playerHealth.positionType = PositionType.viewport;

    add(_playerHealth);

    add(_progressBar = TimerProgressBar(size, timer, timeLimit));

    add(
      HealthBar(
        player: player,
        position: Vector2(size.x / 2, size.y - 10),
        anchor: Anchor.bottomCenter,
        priority: -1,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    _progressBar.timer = timer;
    _enemyCreator.timer = timer;
    if(timer> timeLimit && !bossSpawn){
      add(BossComponent());
      bossSpawn = !bossSpawn;
    }


    // Run each command from _commandList on each
    // component from components list. The run()
    // method of Command is no-op if the command is
    // not valid for given component.
    for (var command in _commandList) {
      for (var component in children) {
        command.run(component);
      }
    }

    // Remove all the commands that are processed and
    // add all new commands to be processed in next update.
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    scoreText.text = 'Опыт: $score';
    _playerHealth.text = 'Прочность: ${player.health}%';
    if (player.isMounted) {
      if (player.health <= 0 && (!camera.shaking)) {
        pauseEngine();
        overlays.remove(PauseButton.id);
        overlays.add(GameOverMenu.id);
      }
    }
  }

  @override
  void onAttach() {
    /*_audioPlayerComponent.playBgm('9. Space Invaders.wav');*/
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }

  @override
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
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    player.reset();
    _enemyCreator.reset();
    score = 0;
    _powerUpManager.reset();
    children.whereType<EnemyComponent>().forEach((enemy) {
      enemy.removeFromParent();
    });

    children.whereType<BulletComponent>().forEach((bullet) {
      bullet.removeFromParent();
    });

    children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
  }

  void increaseScore([int? point]) {
   point == null ? score++ : score += point;
  }
}
