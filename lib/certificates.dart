//TODO: Fix this, find the issue with the certificate on some devices...
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    client
        .badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (host == "dsbmobile.de") {
        final fingerprint = certificateSha256(cert);
        debugPrint("Bad Certificate");
        debugPrint(fingerprint);

        return fingerprint ==
            "69025C66C06548B82D32F876F6F4E801454606B9335852173B65BE2A2E2AEB60";
      }

      return false;
    };

    return client;
  }
}

String certificateSha256(X509Certificate cert) {
  return sha256.convert(cert.der).toString().toUpperCase();
}
