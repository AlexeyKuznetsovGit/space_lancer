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
    highScore = Provider.of<PlayerData>(context).highScore;
    topPadding = MediaQuery.of(context).size.height * 0.05;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Space Lancer',
                style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.orange,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Text(
                'Лучший результат: $highScore',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.orange,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: highScore < 0
                    ? () {}
                    : () {
                        Get.to(() => GameScreen(
                              topPadding: topPadding,
                            ));
                      },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Image.asset(
                      'assets/images/giphy.gif',
                      height: 422,
                      width: 423,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Играть',
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.orange,
                            offset: Offset(0, 0),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Get.to(() => SettingsMenu());
                },
                child: Container(

                  padding: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.black,border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(10), boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.7),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ]),
                    width: MediaQuery.of(context).size.width / 3,
                    child: const Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    )),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
