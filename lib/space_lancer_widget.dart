import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:space_lancer/screens/widgets/game_over.dart';
import 'package:space_lancer/screens/widgets/game_win.dart';
import 'package:space_lancer/screens/widgets/pause_button.dart';
import 'package:space_lancer/screens/widgets/pause_menu.dart';
import 'package:space_lancer/space_lancer_game.dart';

class SpaceLancerWidget extends StatelessWidget {
  const SpaceLancerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: SpaceLancerGame(),
      initialActiveOverlays: const [PauseButton.id],
      overlayBuilderMap: {
        GameWin.id: (BuildContext context, SpaceLancerGame gameRef) => GameWin(gameRef: gameRef),
        PauseButton.id: (BuildContext context, SpaceLancerGame gameRef) => PauseButton(
              gameRef: gameRef,
            ),
        PauseMenu.id: (BuildContext context, SpaceLancerGame gameRef) => PauseMenu(
              gameRef: gameRef,
            ),
        GameOverMenu.id: (BuildContext context, SpaceLancerGame gameRef) => GameOverMenu(
              gameRef: gameRef,
            ),
      },
    );
  }
}
