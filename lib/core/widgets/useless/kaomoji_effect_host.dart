import 'package:material_ui/material_ui.dart';
import 'package:planner/core/widgets/useless/kaomoji_definiton.dart';
import 'package:planner/core/widgets/useless/kaomoji_effect_register.dart';
import 'package:planner/core/widgets/useless/effects/no_effect.dart';

class KaomojiEffectHost extends StatelessWidget {
  const KaomojiEffectHost({
    super.key,
    required this.definition,
    required this.onTap,
  });

  final KaomojiDefinition definition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effect = definition.effect;
    debugPrint(effect?.name);

    final builder = effect == null ? null : effectRegistry[effect];

    if (builder == null) {
      return Positioned.fill(
        child: NoEffect(face: definition.face, onKaomojiTap: onTap),
      );
    }

    return Positioned.fill(child: builder(context, definition.face, onTap));
  }
}
