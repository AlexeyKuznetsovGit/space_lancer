import 'dart:math';

import 'package:flame/components.dart';
import 'package:space_lancer/components/enemy_component.dart';
import 'package:space_lancer/components/getCurrentLevel.dart';
import 'package:space_lancer/models/enemy_model.dart';
import 'package:space_lancer/space_lancer_game.dart';

class EnemyCreator extends Component with HasGameRef<SpaceLancerGame> {
  final Random random = Random();
  final _halfWidth = EnemyComponent.initialSize.x / 2;
  late Timer timer;
  late Timer _freezeTimer;

  EnemyCreator() : super() {
    timer = Timer(2, onTick: _spawnEnemy, repeat: true);

    _freezeTimer = Timer(4, onTick: () {
      timer.start();
    });
  }

  List<Vector2> createPosition(int countEnemy) {
    final random = Random();
    final positions = <Vector2>[];

    for (int i = 0; i < countEnemy; i++) {
      Vector2 position;

      do {
        final x = random.nextDouble() * gameRef.size.x;
        position = Vector2(x, 0);
      } while (positions.any((p) => p.distanceTo(position) < EnemyComponent.initialSize.x));
      positions.add(position); // Убедитесь, что расстояние между компонентами не меньше 50
    }
    return positions;
  }

  void _spawnEnemy() {
    late int countEnemy;
    int currentLevel = GameUtils.getCurrentLevel(gameRef.score);

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
          countEnemy = 4;
          break;
        }
      case 4:
        {
          countEnemy = 5;
          break;
        }
      case 5:
        countEnemy = 6;
        break;
    }
    List<Vector2> positions = createPosition(countEnemy);
    print(positions.toString());
    gameRef.addAll(
      List.generate(countEnemy, (index) {
        /*positions[index] = Vector2(
          _halfWidth + (gameRef.size.x - _halfWidth) * random.nextDouble(),
          0,
        );*/

        /*position.clamp(
          Vector2.zero() + EnemyComponent.initialSize / 2,
          gameRef.size - EnemyComponent.initialSize / 2,
        );*/

        final enemyData = _enemyDataList.elementAt(currentLevel - 1);
        return EnemyComponent(size: EnemyComponent.initialSize, position: positions[index], enemyData: enemyData);
      }),
    );
  }

  @override
  void onMount() {
    super.onMount();
    // Start the timer as soon as current enemy manager get prepared
    // and added to the game instance.
    timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    // Stop the timer if current enemy manager is getting removed from the
    // game instance.
    timer.stop();
  }

  void freeze() {
    timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  void reset() {
    timer.stop();
    timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
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
      speed: 200,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 1,
      speed: 250,
      level: 1,
      hMove: true,
    ),
    EnemyData(
      killPoint: 2,
      speed: 300,
      level: 2,
      hMove: true,
    ),
    EnemyData(
      killPoint: 3,
      speed: 350,
      level: 3,
      hMove: true,
    ),
  ];
}
