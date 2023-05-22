import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:space_lancer/main.dart';
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
    FlutterNativeSplash.remove();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PlayerData>(
          future: getPlayerData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                    ),
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              // Обрабатываем ошибку, если произошла
              return Center(
                child: Column(
                  children: [
                    Text(
                      'Что-то пошло не так!',
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            FlutterExitApp.exitApp();
                          } else if (Platform.isIOS) {
                            FlutterExitApp.exitApp(iosForceExit: true);
                          }
                        },
                        child: const Text('Exit'),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Лучший результат: ${snapshot.data!.highScore}',
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
                    Spacer(),
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
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => GameScreen());
                        },
                        child: const Text('Play'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => SettingsMenu());
                        },
                        child: const Text('Settings'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            FlutterExitApp.exitApp();
                          } else if (Platform.isIOS) {
                            FlutterExitApp.exitApp(iosForceExit: true);
                          }
                        },
                        child: const Text('Exit'),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              );
            }
          }),
    );
  }
}
