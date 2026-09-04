// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:ai_agent_launcher/app/config/app_environment.dart' as _i350;
import 'package:ai_agent_launcher/app/di/register_module.dart' as _i669;
import 'package:ai_agent_launcher/core/security/secure_token_store.dart'
    as _i28;
import 'package:ai_agent_launcher/core/security/secure_token_store_impl.dart'
    as _i106;
import 'package:ai_agent_launcher/features/authentication/data/repositories/rest_auth_repository.dart'
    as _i403;
import 'package:ai_agent_launcher/features/authentication/domain/repositories/auth_repository.dart'
    as _i20;
import 'package:ai_agent_launcher/features/authentication/domain/usecases/restore_session.dart'
    as _i1048;
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_in.dart'
    as _i891;
import 'package:ai_agent_launcher/features/authentication/domain/usecases/sign_out.dart'
    as _i75;
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart'
    as _i1009;
import 'package:ai_agent_launcher/features/updater/data/repositories/rest_launcher_update_repository.dart'
    as _i852;
import 'package:ai_agent_launcher/features/updater/domain/repositories/launcher_update_repository.dart'
    as _i805;
import 'package:ai_agent_launcher/features/updater/infrastructure/launcher_update_applier.dart'
    as _i1066;
import 'package:ai_agent_launcher/features/updater/presentation/bloc/launcher_update_bloc.dart'
    as _i201;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker_flutter/talker_flutter.dart' as _i207;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i207.Talker>(() => registerModule.logger);
    gh.lazySingleton<_i1066.LauncherUpdateApplier>(
      () => const _i1066.LauncherUpdateApplier(),
    );
    gh.lazySingleton<_i28.SecureTokenStore>(
      () => _i106.SecureTokenStoreImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i350.AppConfig>()),
    );
    gh.lazySingleton<_i20.AuthRepository>(
      () => _i403.RestAuthRepository(
        gh<_i361.Dio>(),
        gh<_i28.SecureTokenStore>(),
      ),
    );
    gh.factory<_i1048.RestoreSession>(
      () => _i1048.RestoreSession(gh<_i20.AuthRepository>()),
    );
    gh.factory<_i891.SignIn>(() => _i891.SignIn(gh<_i20.AuthRepository>()));
    gh.factory<_i75.SignOut>(() => _i75.SignOut(gh<_i20.AuthRepository>()));
    gh.lazySingleton<_i805.LauncherUpdateRepository>(
      () => _i852.RestLauncherUpdateRepository(
        gh<_i361.Dio>(),
        gh<_i350.AppConfig>(),
        gh<_i1066.LauncherUpdateApplier>(),
      ),
    );
    gh.factory<_i1009.SessionBloc>(
      () => _i1009.SessionBloc(
        gh<_i891.SignIn>(),
        gh<_i1048.RestoreSession>(),
        gh<_i75.SignOut>(),
      ),
    );
    gh.factory<_i201.LauncherUpdateBloc>(
      () => _i201.LauncherUpdateBloc(gh<_i805.LauncherUpdateRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i669.RegisterModule {}
