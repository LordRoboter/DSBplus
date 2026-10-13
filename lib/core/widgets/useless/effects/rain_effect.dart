import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:planner/l10n/l10extension.dart';

class RainEffect extends StatefulWidget {
  const RainEffect({super.key, required this.face, required this.onKaomojiTap});

  final String face;
  final VoidCallback onKaomojiTap;

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _rainController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF152338),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final sway = math.sin(t * 2 * math.pi);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _RainPainter(_rainController.value)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_rounded,
                      color: Color(0xFFB6C8DA),
                      size: 76,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onKaomojiTap,
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: sway * 0.12,
                            child: Transform.translate(
                              offset: Offset(sway * 12, 0),
                              child: Text(
                                widget.face,
                                style: const TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "${context.l10n.noEntries} :(",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    for (var i = 0; i < 220; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final speed = (0.8 + random.nextDouble() * 1.8) * 3600;
      final length = 12 + random.nextDouble() * 22;

      final y = (startY + progress * size.height * speed) % size.height;

      final paint = Paint()
        ..color = const Color(0xFFB8D9F2).withValues(alpha: 0.45)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y), Offset(x - 4, y + length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
