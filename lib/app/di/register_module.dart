import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/core/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(AppConfig config) => DioFactory.newClient(config);

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Talker get logger => Talker();
}
