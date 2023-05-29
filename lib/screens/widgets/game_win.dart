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
          SizedBox(height: 50,),
          Text(
            'Вы победили',
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
          Spacer(),
          Text(
            'Ваш счет: ${gameRef.score}',
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
          Spacer(),
          SizedBox(
            height: 30,
          ),

          GestureDetector(
            onTap: ()  {
              gameRef.overlays.remove(GameWin.id);
              gameRef.overlays.add(PauseButton.id);
              gameRef.reset();
              gameRef.resumeEngine();
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
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
                width: MediaQuery.of(context).size.width / 2,
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
            onTap: ()  {
              gameRef.overlays.remove(GameWin.id);
              gameRef.reset();

              Get.offAll(() => MainScreen());
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
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
                width: MediaQuery.of(context).size.width / 2,
                child: const Text(
                  'Выход',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                )),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
