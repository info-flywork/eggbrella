part of '../settings_view.dart';

mixin SettingsViewMixin on State<SettingsView> {
  SettingsBloc get _bloc => context.read<SettingsBloc>();

  String get languageName => 'language.${context.locale.languageCode}'.tr();

  void onSoundChanged(bool value) =>
      _bloc.add(SettingsSoundToggled(enabled: value));

  void onMusicChanged(bool value) =>
      _bloc.add(SettingsMusicToggled(enabled: value));

  void onHapticChanged(bool value) =>
      _bloc.add(SettingsHapticToggled(enabled: value));

  void onControlChanged(ControlMode mode) =>
      _bloc.add(SettingsControlChanged(mode));

  Future<void> onLanguageTapped() async {
    final locale = await showSettingsLanguagePicker(context);
    if (locale == null || !mounted) return;
    await context.setLocale(locale);
  }

  Future<void> _openLegalUrl(String url) => launchUrl(
    Uri.parse(url),
    mode: LaunchMode.inAppBrowserView,
  );

  Future<void> onPrivacyTapped() =>
      _openLegalUrl(StringConstants.privacyPolicyUrl);

  /// Skin satın alımlarını RevenueCat'ten geri yükler; sunucuda
  /// yüklenmemiş coin işlemi varsa yükler.
  Future<void> onRestoreTapped() async {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      final skins = await getIt<SkinRepository>().restore();
      final coins = await getIt<CoinStore>().sync();
      message = skins + coins > 0
          ? LocaleKeys.store_restore_done.tr()
          : LocaleKeys.store_restore_none.tr();
    } on Object {
      message = LocaleKeys.store_error_network.tr();
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void onCloseTapped() => context.pop();
}
