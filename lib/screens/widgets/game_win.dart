import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:space_lancer/screens/main_screen.dart';
import 'package:space_lancer/space_lancer_game.dart';
import 'pause_button.dart';

class GameWin extends StatelessWidget {
  static const String id = 'GameWin';
  final SpaceLancerGame gameRef;

  const GameWin({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50.0, bottom: 20),
            child: Text(
              'You win',
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
          Text(
            'Your score: ${gameRef.score}',
            style: const TextStyle(
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

          SizedBox(
            height: 30,
          ),
          // Restart button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameWin.id);
                gameRef.overlays.add(PauseButton.id);
                gameRef.reset();
                gameRef.resumeEngine();
              },
              child: const Text('Restart'),
            ),
          ),

          // Exit button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameWin.id);
                gameRef.reset();

                Get.to(() => MainScreen());
              },
              child: const Text('Exit'),
            ),
          ),
        ],
      ),
    );
  }
}
