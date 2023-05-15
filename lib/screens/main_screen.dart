import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/screens/game_screen.dart';
import 'package:space_lancer/screens/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Consumer<PlayerData>(
              builder: (context, playerData, child) {
                return Text(
                  'Лучший результат: ${playerData.highScore}',
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
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
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
                onPressed: () {},
                child: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
