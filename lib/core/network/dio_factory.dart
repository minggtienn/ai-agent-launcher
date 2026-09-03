import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:dio/dio.dart';

abstract final class DioFactory {
  static Dio newClient(AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
      ),
    );
  }
}
