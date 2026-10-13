import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

typedef FailedFingerprintCallback = Future<void> Function(String fingerprint);

typedef TrustFingerprintCallback = Future<void> Function(String fingerprint);

class MyHttpOverrides extends HttpOverrides {
  MyHttpOverrides({
    required this.onFailedFingerprint,
    required this.onTrustFingerprint,
    required this.autoTrustCertificates,
    String? trustedFingerprint,
  }) : _trustedFingerprint = trustedFingerprint;

  final FailedFingerprintCallback onFailedFingerprint;
  final TrustFingerprintCallback onTrustFingerprint;
  bool autoTrustCertificates;

  String? _trustedFingerprint;

  void updateTrustedFingerprint(String? fingerprint) {
    _trustedFingerprint = fingerprint;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client.badCertificateCallback = (cert, host, port) {
      if (host != 'dsbmobile.de') return false;

      final fingerprint = certificateSha256(cert);

      if (_trustedFingerprint == fingerprint) {
        return true;
      }

      onFailedFingerprint(fingerprint).catchError((Object error) {
        debugPrint('Failed to save certificate error: $error');
      });

      if (autoTrustCertificates) {
        onTrustFingerprint(fingerprint).catchError((Object error) {
          debugPrint('Failed to save trusted fingerprint: $error');
        });

        //We basically just allow every fingerprint
        return true;
      }

      return false;
    };

    return client;
  }
}

String certificateSha256(X509Certificate cert) {
  return sha256.convert(cert.der).toString().toUpperCase();
}
