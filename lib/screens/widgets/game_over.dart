import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:space_lancer/screens/main_screen.dart';
import 'package:space_lancer/screens/widgets/pause_menu.dart';
import 'package:space_lancer/space_lancer_game.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'pause_button.dart';

class GameOverMenu extends StatefulWidget {
  static const String id = 'GameOverMenu';
  final SpaceLancerGame gameRef;

  const GameOverMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  State<GameOverMenu> createState() => _GameOverMenuState();
}

class _GameOverMenuState extends State<GameOverMenu> {
  bool isLoading = false;
  late RewardedAd? _ad;

  Future<void> showRewardedAd() async {
    _ad = await RewardedAd.create(
      adUnitId: "demo-rewarded-yandex" /*Platform.isAndroid ? 'R-M-2405775-1' : "R-M-2405832-1"*/,
      onAdLoaded: () {
        print('загружена');
        setState(() => isLoading = true);
      },
      onAdShown: () {
        widget.gameRef.overlays.remove(PauseMenu.id);
      },
      onAdDismissed: () {
        setState(() => isLoading = false);
        print('скрыл');
        _ad = null;
        /*  gameRef.overlays.remove(GameOverMenu.id);
        gameRef.reset();

        Get.to(() => MainScreen());*/
      },
      onAdFailedToLoad: (error) {
        setState(() => isLoading = false);
        widget.gameRef.overlays.remove(GameOverMenu.id);
        widget.gameRef.reset();

        Get.to(() => MainScreen());
      },
    );

    final ad = _ad;

    if (ad != null) {
      await ad.load(adRequest: AdRequest());
      await ad.show();
      final reward = await ad.waitForDismiss();

      debugPrint('got ${reward?.amount} of ${reward?.type}');
      setState(() => isLoading = false);
      if (reward != null) {
        widget.gameRef.overlays.add(PauseButton.id);
        widget.gameRef.restoreHealth();
        widget.gameRef.overlays.remove(GameOverMenu.id);

        widget.gameRef.resumeEngine();
      } else {
        widget.gameRef.overlays.remove(GameOverMenu.id);
        widget.gameRef.reset();

        Get.to(() => MainScreen());
      }
    } else {
      widget.gameRef.overlays.remove(GameOverMenu.id);
      widget.gameRef.reset();

      Get.to(() => MainScreen());
    }
  }

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
          if (isLoading) ...[
            CircularProgressIndicator()
          ] else ...[
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await showRewardedAd();
                },
                child: const Text('Запас прочности +100'),
              ),
            ),

            // Restart button.
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  widget.gameRef.overlays.remove(GameOverMenu.id);
                  widget.gameRef.overlays.add(PauseButton.id);
                  widget.gameRef.reset();
                  widget.gameRef.resumeEngine();
                },
                child: const Text('Перезапустить'),
              ),
            ),

            // Exit button.
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  widget.gameRef.overlays.remove(GameOverMenu.id);
                  widget.gameRef.reset();

                  Get.to(() => MainScreen());
                },
                child: const Text('Выход'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
