import 'dart:math';

import 'package:flame/components.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/models/enemy_model.dart';
import 'package:space_lancer/space_lancer_game.dart';

class EnemyCreator extends Component with HasGameRef<SpaceLancerGame> {
  final Random random = Random();
  final _halfWidth = EnemyComponent.initialSize.x / 2;
   double timer;
  final double timeLimit;
  late Timer _timer;
  late Timer _freezeTimer;

/*period: 2, repeat: true*/
  EnemyCreator({required this.timer, required this.timeLimit}) : super() {
    _timer = Timer(2, onTick: _spawnEnemy, repeat: true);

    // Sets freeze time to 2 seconds. After 2 seconds spawn timer will start again.
    _freezeTimer = Timer(4, onTick: () {
      _timer.start();
    });
  }

  void _spawnEnemy() {
    late int countEnemy;
    int currentLevel = GameUtils.getCurrentLevel(gameRef.score);
    /* Vector2 initialSize = Vector2(32, 32);*/
    /*  Vector2 position = Vector2(random.nextDouble() * gameRef.size.x, 0);*/

    switch (currentLevel) {
      case 1:
        {
          countEnemy = 3;
          break;
        }
      case 2:
        {
          countEnemy = 4;
          break;
        }
      case 3:
        {
          countEnemy = 5;
          break;
        }
      case 4:
        {
          countEnemy = 5;
          break;
        }
    }
    gameRef.addAll(
      List.generate(countEnemy, (index) {
        Vector2 position = Vector2(
          _halfWidth + (gameRef.size.x - _halfWidth) * random.nextDouble(),
          0,
        );

        position.clamp(
          Vector2.zero() + EnemyComponent.initialSize / 2,
          gameRef.size - EnemyComponent.initialSize / 2,
        );
        final enemyData = _enemyDataList.elementAt(currentLevel <= 2 ? 0 : 1);
        return EnemyComponent(size: EnemyComponent.initialSize, position: position, enemyData: enemyData);
      }),
    );
  }

  @override
  void onMount() {
    super.onMount();
    // Start the timer as soon as current enemy manager get prepared
    // and added to the game instance.
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    // Stop the timer if current enemy manager is getting removed from the
    // game instance.
    _timer.stop();
  }

  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  void reset() {
    _timer.stop();
    _timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (timer > timeLimit) {
      removeFromParent();
    }
    // Update timers with delta time to make them tick.
    _timer.update(dt);
    _freezeTimer.update(dt);
  }

  static const List<EnemyData> _enemyDataList = [
    EnemyData(
      killPoint: 1,
      speed: 150,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 1,
      speed: 250,
      level: 2,
      hMove: true,
    ),
  ];
}
