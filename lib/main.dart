/*
import 'package:flutter/widgets.dart';
import 'package:space_lancer/space_lancer_widget.dart';

void main() async {
  runApp(const SpaceLancerWidget());
}
*/
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/models/settings.dart';
import 'package:space_lancer/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();

  // Initialize hive.
  await initHive();

  runApp(MultiProvider(
    providers: [
      FutureProvider<PlayerData>(
        create: (BuildContext context) => getPlayerData(),
        initialData: PlayerData.fromMap(PlayerData.defaultData),
      ),
      FutureProvider<Settings>(
        create: (BuildContext context) => getSettings(),
        initialData: Settings(soundEffects: false, backgroundMusic: false),
      ),
    ],
    builder: (context, child) {
      // We use .value constructor here because the required objects
      // are already created by upstream FutureProviders.
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<Settings>.value(
            value: Provider.of<Settings>(context),
          ),
        ],
        child: child,
      );
    },
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScreen(),
    ),
  ));
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(SettingsAdapter());
}

Future<PlayerData> getPlayerData() async {
  // Open the player data box and read player data from it.
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  final playerData = box.get(PlayerData.playerDataKey);

  // If player data is null, it means this is a fresh launch
  // of the game. In such case, we first store the default
  // player data in the player data box and then return the same.
  if (playerData == null) {
    box.put(
      PlayerData.playerDataKey,
      PlayerData.fromMap(PlayerData.defaultData),
    );
  }

  return box.get(PlayerData.playerDataKey)!;
}

Future<Settings> getSettings() async {
  // Open the settings box and read settings from it.
  final box = await Hive.openBox<Settings>(Settings.settingsBox);
  final settings = box.get(Settings.settingsKey);

  // If settings is null, it means this is a fresh launch
  // of the game. In such case, we first store the default
  // settings in the settings box and then return the same.
  if (settings == null) {
    box.put(Settings.settingsKey, Settings(soundEffects: true, backgroundMusic: true));
  }

  return box.get(Settings.settingsKey)!;
}
