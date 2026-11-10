import 'package:dio/dio.dart';
import 'package:eggbrella/core/clip/clip_encoder.dart';
import 'package:eggbrella/core/haptics/haptic_manager.dart';
import 'package:eggbrella/core/managers/auth_cache_manager.dart';
import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/core/network/dio_client.dart';
import 'package:eggbrella/core/network/network_manager.dart';
import 'package:eggbrella/core/share/clip_share.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/core/utils/constants/string_constants.dart';
import 'package:eggbrella/data/model/player/game_result.dart';
import 'package:eggbrella/domain/auth/auth_repository.dart';
import 'package:eggbrella/domain/clip/clip_repository.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/settings/settings_repository.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:eggbrella/domain/store/coin_store.dart';
import 'package:eggbrella/presentation/game/bloc/game_bloc.dart';
import 'package:eggbrella/presentation/home/bloc/home_bloc.dart';
import 'package:eggbrella/presentation/result/bloc/result_bloc.dart';
import 'package:eggbrella/presentation/settings/bloc/settings_bloc.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_bloc.dart';
import 'package:eggbrella/presentation/store/bloc/store_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Manager / Network / Repository -> registerLazySingleton
/// Ekran BLoC'ları -> registerFactory
void configureDependencies() {
  const remote = !StringConstants.offline;
  getIt
    ..registerLazySingleton<AuthCacheManager>(
      () => AuthCacheManager(const FlutterSecureStorage()),
    )
    ..registerLazySingleton<SharedPrefManager>(() => SharedPrefManager.instance)
    ..registerLazySingleton<Dio>(
      () => DioClient.create(authCacheManager: getIt()),
    )
    ..registerLazySingleton<NetworkManager>(() => NetworkManager(getIt()))
    ..registerLazySingleton<SoundManager>(() => SoundManager(getIt()))
    ..registerLazySingleton<HapticManager>(() => HapticManager(getIt()))
    ..registerLazySingleton<ClipEncoder>(ClipEncoder.new)
    ..registerLazySingleton<ClipShare>(ClipShare.new)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt(), getIt(), enabled: remote),
    )
    ..registerLazySingleton<PlayerRepository>(
      () => PlayerRepository(getIt(), remote ? getIt<NetworkManager>() : null),
    )
    ..registerLazySingleton<PurchaseRepository>(PurchaseRepository.new)
    ..registerLazySingleton<SkinRepository>(
      () => SkinRepository(getIt(), getIt()),
    )
    ..registerLazySingleton<CoinStore>(() => CoinStore(getIt(), getIt()))
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(getIt(), getIt()),
    )
    ..registerLazySingleton<ClipRepository>(
      () => ClipRepository(getIt(), getIt(), uploadEnabled: remote),
    )
    ..registerFactory<SplashBloc>(
      () => SplashBloc(
        getIt(),
        getIt(),
        getIt(),
        purchases: getIt(),
        skins: getIt(),
      ),
    )
    ..registerFactory<HomeBloc>(() => HomeBloc(getIt(), getIt()))
    ..registerFactory<GameBloc>(
      () => GameBloc(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        skins: getIt<SkinRepository>().selection,
      ),
    )
    ..registerFactoryParam<ResultBloc, GameResult, void>(
      (result, _) => ResultBloc(result, getIt(), getIt()),
    )
    ..registerFactory<SettingsBloc>(() => SettingsBloc(getIt()))
    ..registerFactory<StoreBloc>(() => StoreBloc(getIt(), getIt()));
}
