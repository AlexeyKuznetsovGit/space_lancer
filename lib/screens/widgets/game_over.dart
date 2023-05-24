import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:space_lancer/screens/main_screen.dart';
import 'package:space_lancer/space_lancer_game.dart';

import 'pause_button.dart';

class GameOverMenu extends StatelessWidget {
  /*Future<void> showRewardedAd() async {
    final ad = await RewardedAd.create(
      adUnitId: 'demo-rewarded-yandex',
      onAdShown: () {
        gameRef.restoreHealth();
        gameRef.overlays.remove(GameOverMenu.id);
        */ /*gameRef.reset();*/ /*
        gameRef.resumeEngine();
      },
      onAdFailedToLoad: (error) {
        gameRef.overlays.remove(GameOverMenu.id);
        gameRef.reset();

        Get.to(() => MainScreen());
      },
    );
    await ad.load(adRequest: AdRequest());
    await ad.show();
    final reward = await ad.waitForDismiss();
    if (reward != null) debugPrint('got ${reward.amount} of ${reward.type}');
  }*/

  static const String id = 'GameOverMenu';
  final SpaceLancerGame gameRef;

  const GameOverMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause menu title.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Game Over',
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                /*showRewardedAd();*/
              },
              child: const Text('Запас прочности +100'),
            ),
          ),

          // Restart button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameOverMenu.id);
                gameRef.overlays.add(PauseButton.id);
                gameRef.reset();
                gameRef.resumeEngine();
              },
              child: const Text('Перезапустить'),
            ),
          ),

          // Exit button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameOverMenu.id);
                gameRef.reset();

                Get.to(() => MainScreen());
              },
              child: const Text('Выход'),
            ),
          ),
        ],
      ),
    );
  }
}
