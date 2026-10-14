import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/core/providers/shared_preferences_provider.dart';
import 'package:planner/features/settings/errors/model/error_state.dart';

final errorProvider = AsyncNotifierProvider<ErrorNotifier, ErrorState>(
  ErrorNotifier.new,
);

class ErrorNotifier extends AsyncNotifier<ErrorState> {
  late dynamic prefs;

  static const _lastFailedFingerprintKey =
      'last_failed_certificate_fingerprint';

  static const _trustedFingerprintKey = 'trusted_certificate_fingerprint';

  static const _autoTrustCertificatesKey = 'auto_trust_certificates';

  @override
  Future<ErrorState> build() async {
    prefs = ref.read(sharedPreferencesProvider);

    return ErrorState(
      lastFailedFingerprint: prefs.getString(_lastFailedFingerprintKey),
      trustedFingerprint: prefs.getString(_trustedFingerprintKey),
      autoTrustCertificates: prefs.getBool(_autoTrustCertificatesKey) ?? false,
    );
  }

  Future<void> setLastFailedFingerprint(String fingerprint) async {
    await prefs.setString(_lastFailedFingerprintKey, fingerprint);

    _updateState((state) => state.copyWith(lastFailedFingerprint: fingerprint));
  }

  Future<void> trustFingerprint(String fingerprint) async {
    await prefs.setString(_trustedFingerprintKey, fingerprint);

    _updateState((state) => state.copyWith(trustedFingerprint: fingerprint));
  }

  Future<void> clearTrustedFingerprint() async {
    await prefs.remove(_trustedFingerprintKey);

    _updateState((state) => state.copyWith(trustedFingerprint: null));
  }

  Future<void> setAutoTrustCertificates(bool enabled) async {
    await prefs.setBool(_autoTrustCertificatesKey, enabled);

    _updateState((state) => state.copyWith(autoTrustCertificates: enabled));
  }

  void _updateState(ErrorState Function(ErrorState state) update) {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = AsyncData(update(currentState));
  }

  Future<bool> isTrusted(String fingerprint) async {
    final currentState = state.asData?.value;

    if (currentState == null) return false;

    return currentState.trustedFingerprint == fingerprint;
  }

  Future<void> clear() async {
    await prefs.remove(_lastFailedFingerprintKey);
    await prefs.remove(_trustedFingerprintKey);
    await prefs.remove(_autoTrustCertificatesKey);

    state = const AsyncData(ErrorState());
  }
}
