import 'package:shared_preferences/shared_preferences.dart';

class BackgroundErrorRepository {
  late SharedPreferences prefs;

  static const _lastFailedFingerprintKey =
      'last_failed_certificate_fingerprint';

  static const _trustedFingerprintKey = 'trusted_certificate_fingerprint';

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  String? get lastFailedFingerprint =>
      prefs.getString(_lastFailedFingerprintKey);

  Future<void> saveLastFailedFingerprint(String fingerprint) async {
    await prefs.setString(_lastFailedFingerprintKey, fingerprint);
  }

  String? get trustedFingerprint => prefs.getString(_trustedFingerprintKey);

  Future<void> saveTrustedFingerprint(String fingerprint) async {
    await prefs.setString(_trustedFingerprintKey, fingerprint);
  }

  Future<void> clearTrustedFingerprint() async {
    await prefs.remove(_trustedFingerprintKey);
  }

  static const _autoTrustCertificatesKey = 'auto_trust_certificates';

  bool get autoTrustCertificates =>
      prefs.getBool(_autoTrustCertificatesKey) ?? false;

  Future<void> setAutoTrustCertificates(bool enabled) async {
    await prefs.setBool(_autoTrustCertificatesKey, enabled);
  }
}
