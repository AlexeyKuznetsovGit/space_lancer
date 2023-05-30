import 'package:flutter/material.dart';
import 'package:space_lancer/components/audio_player_component.dart';
import 'package:space_lancer/components/command.dart';
import 'package:space_lancer/screens/widgets/pause_menu.dart';
import 'package:space_lancer/space_lancer_game.dart';

class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final SpaceLancerGame gameRef;

  const PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          gameRef.audioPlayerComponent.pauseBgm();
          gameRef.pauseEngine();
          gameRef.overlays.add(PauseMenu.id);
          gameRef.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
