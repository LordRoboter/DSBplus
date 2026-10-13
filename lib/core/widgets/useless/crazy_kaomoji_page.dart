import 'package:material_ui/material_ui.dart';
import 'package:planner/core/widgets/useless/kaomoji_definiton.dart';
import 'package:planner/core/widgets/useless/kaomoji_effect_host.dart';
import 'package:planner/l10n/l10extension.dart';

class CrazyKaomojiPage extends StatefulWidget {
  const CrazyKaomojiPage({super.key});

  @override
  State<CrazyKaomojiPage> createState() => _CrazyKaomojiPageState();
}

class _CrazyKaomojiPageState extends State<CrazyKaomojiPage> {
  Kaomoji _kaomoji = Kaomoji.worried;
  bool _effectActive = false;

  void _onKaomojiTap() {
    setState(() {
      final options = Kaomoji.values
          .where((k) => k != _kaomoji && kaomojis.containsKey(k))
          .toList();

      if (options.isEmpty) return;

      options.shuffle();
      _kaomoji = options.first;

      final definition = kaomojis[_kaomoji];
      _effectActive = definition?.effect != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final definition = kaomojis[_kaomoji]!;
    debugPrint(definition.face);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              KaomojiEffectHost(
                key: ValueKey(_kaomoji),
                definition: definition,
                onTap: _onKaomojiTap,
              ),
            ],
          ),
        );
      },
    );
  }
}
