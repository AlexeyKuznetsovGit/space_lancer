import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/models/player_data.dart';
import 'package:space_lancer/models/settings.dart';
import 'package:space_lancer/screens/main_screen.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.setPortraitUpOnly();
  Flame.device.fullScreen();
  MobileAds.initialize();

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
      home: MainScreen(),
    ),
  ));
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(SettingsAdapter());
}

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  final playerData = box.get(PlayerData.playerDataKey);


  if (playerData == null) {
    box.put(
      PlayerData.playerDataKey,
      PlayerData.fromMap(PlayerData.defaultData),
    );
  }
   Future.delayed(Duration(seconds: 2));
  return box.get(PlayerData.playerDataKey)!;
}

Future<Settings> getSettings() async {

  final box = await Hive.openBox<Settings>(Settings.settingsBox);
  final settings = box.get(Settings.settingsKey);


  if (settings == null) {
    box.put(Settings.settingsKey, Settings(soundEffects: true, backgroundMusic: true));
  }

  return box.get(Settings.settingsKey)!;
}
