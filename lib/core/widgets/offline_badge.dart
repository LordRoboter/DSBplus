import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:planner/l10n/l10extension.dart';

class OfflineBadge extends StatefulWidget {
  const OfflineBadge({super.key});

  @override
  State<OfflineBadge> createState() => _OfflineBadgeState();
}

class _OfflineBadgeState extends State<OfflineBadge> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _hideTimer;

  bool _isOffline = false;
  bool _isVisible = false;
  bool _hasInitialStatus = false;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();

      if (!mounted || _hasInitialStatus) return;

      _hasInitialStatus = true;
      _isOffline = _isDisconnected(results);
      _isVisible = _isOffline;

      setState(() {});
    } catch (_) {
      // Keep the badge hidden if the initial check fails.
    }
  }

  bool _isDisconnected(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (!mounted) return;

    final offline = _isDisconnected(results);
    _hideTimer?.cancel();

    if (!_hasInitialStatus) {
      _hasInitialStatus = true;
      _isOffline = offline;
      _isVisible = offline;
      setState(() {});
      return;
    }

    if (offline == _isOffline) return;

    setState(() {
      _isOffline = offline;
      _isVisible = true;
    });

    if (!offline) {
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() {
          _isVisible = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = _isOffline
        ? colorScheme.errorContainer
        : Colors.blue.shade700;

    final foreground = _isOffline ? colorScheme.onErrorContainer : Colors.white;

    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedSlide(
            offset: _isVisible ? Offset.zero : const Offset(0, -1.5),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Row(
                    key: ValueKey(_isOffline),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOffline
                            ? Icons.wifi_off_rounded
                            : Icons.wifi_rounded,
                        color: foreground,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOffline
                            ? context.l10n.noConnection
                            : context.l10n.backOnline,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
