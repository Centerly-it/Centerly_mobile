class UpdateManifest {
  const UpdateManifest({
    required this.environment,
    required this.packageId,
    required this.latestBuild,
    required this.minimumBuild,
    required this.version,
    required this.url,
    required this.sha256,
    required this.size,
    required this.minSdk,
  });
  final String environment, packageId, version, sha256;
  final int latestBuild, minimumBuild, size, minSdk;
  final Uri url;
  bool requiredFor(int installed) => installed < minimumBuild;
  bool availableFor(int installed) => installed < latestBuild;
  Map<String, dynamic> toJson() => {
    'schema': 1,
    'enabled': true,
    'environment': environment,
    'package_id': packageId,
    'latest_build': latestBuild,
    'minimum_build': minimumBuild,
    'version': version,
    'url': url.toString(),
    'sha256': sha256,
    'size': size,
    'min_sdk': minSdk,
  };
  static UpdateManifest? parse(
    Map<String, dynamic> j, {
    required String environment,
    required String packageId,
  }) {
    if (j['schema'] != 1 ||
        j['environment'] != environment ||
        j['package_id'] != packageId) {
      throw const FormatException('UPDATE_INVALID');
    }
    if (j['enabled'] == false) return null;
    final latest = j['latest_build'],
        minimum = j['minimum_build'],
        size = j['size'],
        sdk = j['min_sdk'];
    final url = Uri.tryParse(j['url'] is String ? j['url'] as String : '');
    final hash = j['sha256'], version = j['version'];
    if (j['enabled'] != true ||
        latest is! int ||
        latest < 1 ||
        minimum is! int ||
        minimum < 0 ||
        minimum > latest ||
        size is! int ||
        size < 1 ||
        size > 300 * 1024 * 1024 ||
        sdk is! int ||
        sdk < 24 ||
        sdk > 100 ||
        version is! String ||
        !RegExp(r'^\d+\.\d+\.\d+(?:[+.-][a-zA-Z0-9.-]+)?$').hasMatch(version) ||
        hash is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        url == null ||
        url.scheme != 'https' ||
        url.userInfo.isNotEmpty ||
        url.hasFragment ||
        url.hasQuery ||
        (url.hasPort && url.port != 443) ||
        url.host != 'github.com' ||
        !RegExp(
          r'^/Centerly-it/Centerly-releases/releases/download/[a-zA-Z0-9._+-]+/[a-zA-Z0-9._+-]+\.apk$',
        ).hasMatch(url.path)) {
      throw const FormatException('UPDATE_INVALID');
    }
    return UpdateManifest(
      environment: environment,
      packageId: packageId,
      latestBuild: latest,
      minimumBuild: minimum,
      version: version,
      url: url,
      sha256: hash,
      size: size,
      minSdk: sdk,
    );
  }
}
