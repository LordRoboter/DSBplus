enum Kaomoji { worried, dancing, crying }

enum KaomojiEffect { noEffect, dance, rain }

class KaomojiDefinition {
  const KaomojiDefinition({required this.face, this.effect});

  final String face;
  final KaomojiEffect? effect;
}

const kaomojis = <Kaomoji, KaomojiDefinition>{
  Kaomoji.worried: KaomojiDefinition(
    face: '(｡•́︿•̀｡)',
    effect: KaomojiEffect.noEffect,
  ),
  Kaomoji.dancing: KaomojiDefinition(
    face: '٩(ᵔᴗᵔ )و',
    effect: KaomojiEffect.dance,
  ),
  Kaomoji.crying: KaomojiDefinition(face: '(ಥ﹏ಥ)', effect: KaomojiEffect.rain),
};
