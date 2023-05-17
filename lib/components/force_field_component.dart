import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_lancer/space_lancer_game.dart';

class ForceFieldComponent extends SpriteComponent with HasGameRef<SpaceLancerGame>, CollisionCallbacks {
  ForceFieldComponent({required super.position}) : super();

  @override
  Future<void> onLoad() async {
    size = Vector2(110, 110);
    anchor = Anchor.center;
    sprite = Sprite(gameRef.images.fromCache('force_field.png'), srcSize: Vector2(1024, 1024));
    add(CircleHitbox());
  }

}
