import 'package:easy_localization/easy_localization.dart';
import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/core/init/app_init.dart';
import 'package:eggbrella/core/router/app_router.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Arka plana geçince müzik susar, dönünce (ayar açıksa) devam eder.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getIt<SoundManager>().onLifecycleChanged(
      foreground: state == AppLifecycleState.resumed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppInit.systemUiOverlayStyle,
      child: MaterialApp.router(
        title: 'Eggbrella',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
