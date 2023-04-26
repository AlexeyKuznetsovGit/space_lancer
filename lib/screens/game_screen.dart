import 'package:flutter/material.dart';
import 'package:space_lancer/space_lancer_game.dart';
import 'package:space_lancer/space_lancer_widget.dart';

class GameScreen extends StatelessWidget {
  GameScreen({Key? key}) : super(key: key);
  SpaceLancerGame gameApp = SpaceLancerGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: const SpaceLancerWidget()
      ),
    );
  }
}
