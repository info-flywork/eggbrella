import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/app.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/init/app_init.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await AppInit.initialize();
  configureDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: AppInit.supportedLocales,
      fallbackLocale: AppInit.fallbackLocale,
      path: AppInit.translationsPath,
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      child: const App(),
    ),
  );
}
