class ErrorState {
  final String? lastFailedFingerprint;
  final String? trustedFingerprint;
  final bool autoTrustCertificates;

  const ErrorState({
    this.lastFailedFingerprint,
    this.trustedFingerprint,
    this.autoTrustCertificates = false,
  });

  bool get hasFailedFingerprint =>
      lastFailedFingerprint != null && lastFailedFingerprint!.isNotEmpty;

  bool get hasTrustedFingerprint =>
      trustedFingerprint != null && trustedFingerprint!.isNotEmpty;

  bool get lastFailedIsTrusted =>
      hasFailedFingerprint && lastFailedFingerprint == trustedFingerprint;

  static const _unset = Object();

  ErrorState copyWith({
    Object? lastFailedFingerprint = _unset,
    Object? trustedFingerprint = _unset,
    bool? autoTrustCertificates,
  }) {
    return ErrorState(
      lastFailedFingerprint: identical(lastFailedFingerprint, _unset)
          ? this.lastFailedFingerprint
          : lastFailedFingerprint as String?,
      trustedFingerprint: identical(trustedFingerprint, _unset)
          ? this.trustedFingerprint
          : trustedFingerprint as String?,
      autoTrustCertificates:
          autoTrustCertificates ?? this.autoTrustCertificates,
    );
  }
}
