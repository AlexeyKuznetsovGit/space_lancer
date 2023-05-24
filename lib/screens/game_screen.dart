import 'package:flutter/material.dart';
import 'package:space_lancer/space_lancer_game.dart';
import 'package:space_lancer/space_lancer_widget.dart';

class GameScreen extends StatelessWidget {
  GameScreen({Key? key, required this.topPadding}) : super(key: key);
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: WillPopScope(
          onWillPop: () async => false,
          child: SpaceLancerWidget()
        ),
      ),
    );
  }
}
