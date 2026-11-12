class AdConfiguration {
  const AdConfiguration._(this.bannerId, this.interstitialId, this.rewardedId,
      this.requiresConsent, this.production);
  final String bannerId, interstitialId, rewardedId;
  final bool requiresConsent, production;

  static AdConfiguration? fromNative(Object? value) {
    if (value is! Map) return null;
    final package = value['packageName'];
    if (value['mode'] == 'test' && package == 'com.mehedi.puzzlemix.dev') {
      return AdConfiguration._(
          'ca-app-pub-3940256099942544/9214589741',
          'ca-app-pub-3940256099942544/1033173712',
          'ca-app-pub-3940256099942544/5224354917',
          value['requiresConsent'] == true,
          false);
    }
    if (value['mode'] != 'production' ||
        package != 'com.mehedi.puzzlemix' ||
        value['requiresConsent'] != true) return null;
    final ids = [
      value['bannerId'],
      value['interstitialId'],
      value['rewardedId']
    ];
    if (ids.any((id) =>
        id is! String ||
        !RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(id) ||
        id.startsWith('ca-app-pub-3940256099942544/'))) return null;
    if (ids.toSet().length != 3 ||
        ids.map((id) => (id as String).split('/').first).toSet().length != 1)
      return null;
    return AdConfiguration._(
        ids[0] as String, ids[1] as String, ids[2] as String, true, true);
  }
}
