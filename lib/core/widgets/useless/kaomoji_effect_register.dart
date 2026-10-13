import 'package:material_ui/material_ui.dart';
import 'package:planner/core/widgets/useless/effects/dance_effect.dart';
import 'package:planner/core/widgets/useless/effects/no_effect.dart';
import 'package:planner/core/widgets/useless/effects/rain_effect.dart';
import 'package:planner/core/widgets/useless/kaomoji_definiton.dart';

typedef KaomojiEffectBuilder =
    Widget Function(
      BuildContext context,
      String face,
      VoidCallback onKaomojiTap,
    );

final Map<KaomojiEffect, KaomojiEffectBuilder> effectRegistry = {
  KaomojiEffect.noEffect: (context, face, onKaomojiTap) =>
      NoEffect(face: face, onKaomojiTap: onKaomojiTap),

  KaomojiEffect.dance: (context, face, onKaomojiTap) =>
      DanceEffect(face: face, onKaomojiTap: onKaomojiTap),

  KaomojiEffect.rain: (context, face, onKaomojiTap) =>
      RainEffect(face: face, onKaomojiTap: onKaomojiTap),
};
