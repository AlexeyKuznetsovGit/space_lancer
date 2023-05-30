import 'dart:developer';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:provider/provider.dart';
import 'package:space_lancer/space_lancer_game.dart';

import '../models/settings.dart';

class AudioPlayerComponent extends Component with HasGameRef<SpaceLancerGame> {
  @override
  Future<void>? onLoad() async {
    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache.loadAll(['explosion.wav', 'selection.wav', 'laserSmall_001.wav', 'shot.wav']);

    try {
      await FlameAudio.audioCache.load(
        'background.mp3',
      );
    } catch (e) {
      print(e.toString());
    }

    return super.onLoad();
  }

  void playBgm(String filename) {
/*log(FlameAudio.audioCache.loadedFiles.toString(),name: "BACKGROUND");*/
    /*if (!FlameAudio.audioCache.loadedFiles.containsKey(filename)) return;*/
      if (Provider.of<Settings>(gameRef.buildContext!, listen: false).backgroundMusic) {
        FlameAudio.bgm.play(filename);
      }

  }

  void playSfx(String filename) {
    if (gameRef.buildContext != null) {
      if (Provider.of<Settings>(gameRef.buildContext!, listen: false).soundEffects) {
        FlameAudio.play(filename);
      }
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  void pauseBgm() {
    FlameAudio.bgm.pause();
  }
  void resumeBgm() {
    if (Provider.of<Settings>(gameRef.buildContext!, listen: false).backgroundMusic) {
      FlameAudio.bgm.resume();
    }

  }

}
