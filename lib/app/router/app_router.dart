import 'package:ai_agent_launcher/features/application_catalog/presentation/pages/catalog_page.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/pages/login_page.dart';
import 'package:ai_agent_launcher/features/updater/presentation/pages/startup_update_page.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const catalog = '/catalog';
  static const update = '/update';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.update,
  routes: [
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
    GoRoute(path: AppRoutes.catalog, builder: (_, _) => const CatalogPage()),
    GoRoute(
      path: AppRoutes.update,
      builder: (_, _) => const StartupUpdatePage(),
    ),
  ],
);
