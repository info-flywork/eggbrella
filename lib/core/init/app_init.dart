import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uygulama başlangıç sırası.
abstract final class AppInit {
  /// Gökyüzü / bina arka planları üzerinde açık renkli durum çubuğu ikonları.
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Desteklenen diller. Cihaz dili listede yoksa [fallbackLocale] (İngilizce).
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('ar'),
    Locale('hi'),
    Locale('nl'),
    Locale('pl'),
    Locale('sv'),
    Locale('da'),
    Locale('no'),
    Locale('fi'),
    Locale('cs'),
    Locale('hu'),
    Locale('ro'),
    Locale('uk'),
    Locale('el'),
    Locale('th'),
    Locale('vi'),
    Locale('id'),
    Locale('ms'),
    Locale('he'),
    Locale('bn'),
    Locale('sk'),
    Locale('hr'),
    Locale('bg'),
    Locale('ca'),
    Locale('fil'),
    Locale('fa'),
    Locale('ur'),
    Locale('sr'),
    Locale('lt'),
    Locale('lv'),
  ];

  static const Locale fallbackLocale = Locale('en');
  static const String translationsPath = 'assets/translations';

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await EasyLocalization.ensureInitialized();
    await SharedPrefManager.instance.init();
  }
}
