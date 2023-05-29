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
      adUnitId: Platform.isAndroid ? 'R-M-2405775-1' : "R-M-2405832-1",
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Игра окончена',
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 15.0,
                    color: Colors.orange,
                    offset: Offset(0, 0),
                  )
                ],
              ),
            ),
          ),
          Text(
            'Ваш счет: ${widget.gameRef.score}',
            style: const TextStyle(
              fontSize: 50.0,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 15.0,
                  color: Colors.orange,
                  offset: Offset(0, 0),
                )
              ],
            ),
          ),
          SizedBox(height: 50,),
          if (isLoading) ...[
            CircularProgressIndicator()
          ] else ...[
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                await showRewardedAd();
              },
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.7),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]),
                  child: const Text(
                    'Запас прочности +100',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                widget.gameRef.overlays.remove(GameOverMenu.id);
                widget.gameRef.overlays.add(PauseButton.id);
                widget.gameRef.reset();
                widget.gameRef.resumeEngine();
              },
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.7),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]),

                  child: const Text(
                    'Перезапустить',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                widget.gameRef.overlays.remove(GameOverMenu.id);
                widget.gameRef.reset();

                Get.offAll(() => MainScreen());
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.7),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ]),
                  child: const Text(
                    'Выход',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  )),
            ),
          ]
        ],
      ),
    );
  }
}
