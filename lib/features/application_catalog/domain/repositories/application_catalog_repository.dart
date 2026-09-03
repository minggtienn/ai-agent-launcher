import 'package:ai_agent_launcher/core/result/result.dart';
import 'package:ai_agent_launcher/features/application_catalog/domain/entities/managed_application.dart';

abstract interface class ApplicationCatalogRepository {
  Future<Result<List<ManagedApplication>>> getApplications();
}
