import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:planner/l10n/l10extension.dart';

class DanceEffect extends StatefulWidget {
  const DanceEffect({
    super.key,
    required this.face,
    required this.onKaomojiTap,
  });

  final String face;
  final VoidCallback onKaomojiTap;

  @override
  State<DanceEffect> createState() => _DanceEffectState();
}

class _DanceEffectState extends State<DanceEffect>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        final bounce = math.sin(math.pi * t);

        // Sway from left to right and back.
        final sway = math.sin(2 * math.pi * t);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Confetti stays behind the character.
            CustomPaint(painter: _ConfettiPainter(_confettiController.value)),

            // Center the character in the available space.
            GestureDetector(
              onTap: widget.onKaomojiTap,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(sway * 24, -bounce * 20),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(sway * 0.22)
                          ..scale(sway >= 0 ? 1.0 : -1.0, 1.0),
                        child: Transform.scale(
                          scale: 1 + bounce * 0.12,
                          child: Text(
                            widget.face,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "${context.l10n.noEntries}!",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);

  final double progress;

  static const _colors = [
    Colors.pink,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.amber,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 70; i++) {
      // Stable particle positions across animation frames.
      final seedX = (i * 0.6180339) % 1.0;
      final seedY = (i * 0.7548776) % 1.0;

      final speed = (0.35 + (i % 5) * 0.12) * 3600;

      final x = seedX * size.width + math.sin(progress * 2 * math.pi + i) * 14;

      final y = ((seedY + progress * speed) % 1.0) * size.height;

      final paint = Paint()..color = _colors[i % _colors.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 4 * math.pi + i);

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 5, height: 9),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
