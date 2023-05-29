import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/models/settings.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                'Настройки',
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
            Selector<Settings, bool>(
              selector: (context, settings) => settings.soundEffects,
              builder: (context, value, child) {
                return SwitchListTile(
                  title: const Text(
                    'Звуковые эффекты',
                    style: TextStyle(
                      fontSize: 20.0,
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
                  value: value,
                  onChanged: (newValue) {
                    Provider.of<Settings>(context, listen: false).soundEffects = newValue;
                  },
                );
              },
            ),
            Selector<Settings, bool>(
              selector: (context, settings) => settings.backgroundMusic,
              builder: (context, value, child) {
                return SwitchListTile(
                  title: const Text(
                    'Музыка на заднем фоне',
                    style: TextStyle(
                      fontSize: 20.0,
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
                  value: value,
                  onChanged: (newValue) {
                    Provider.of<Settings>(context, listen: false).backgroundMusic = newValue;
                  },
                );
              },
            ),
            SizedBox(height: 30,),
            GestureDetector(
              onTap: () {
                Get.back();
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
                  width: MediaQuery.of(context).size.width / 3,
                  child: const Text(
                    'Назад',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
