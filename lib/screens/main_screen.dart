import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/screens/game_screen.dart';
import 'package:space_lancer/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  int highScore = -1;

  double topPadding = 0;

  @override
  Widget build(BuildContext context) {
    highScore = Provider
        .of<PlayerData>(context)
        .highScore;
    topPadding = MediaQuery
        .of(context)
        .size
        .height * 0.05;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Лучший результат: $highScore',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.grey,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
              ),
              Container(
                color: Colors.red,
                child: Column(children: [Image.asset(
                  'assets/images/giphy.gif',
                  height: 300,
                  width: 300,
                ), Text('Играть', style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.grey,
                      offset: Offset(0, 0),
                    )
                  ],
                ),)
                ],),
              ),


              /*  Consumer<PlayerData>(builder: (context, playerData, child) {
                return highScore < 0
                    ? Text(
                        'Лучший результат: $highScore',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 20.0,
                              color: Colors.grey,
                              offset: Offset(0, 0),
                            )
                          ],
                        ),
                      )
                    : Container();
              }),*/
              const Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: Text(
                  'Space Lancer',
                  style: TextStyle(
                    fontSize: 50.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.grey,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3,
                child: ElevatedButton(
                  onPressed: highScore < 0
                      ? () {}
                      : () {
                    Get.to(() =>
                        GameScreen(
                          topPadding: topPadding,
                        ));
                  },
                  child: const Text('Играть'),
                ),
              ),
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SettingsMenu());
                  },
                  child: const Text('Настройки'),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
