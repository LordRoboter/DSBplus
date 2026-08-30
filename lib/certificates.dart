//TODO: Fix this, find the issue with the certificate on some devices...
import 'dart:io';

import 'package:crypto/crypto.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client
        .badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (host == "dsbmobile.de") {
        final fingerprint = certificateSha256(cert);

        return fingerprint ==
            "8C54C334B66BA4E426772AF4A3F9136C19A1AEC729FDB28C535C07A5A4EF22E0";
      }

      return false;
    };

    return client;
  }
}

String certificateSha256(X509Certificate cert) {
  return sha256.convert(cert.der).toString().toUpperCase();
}
