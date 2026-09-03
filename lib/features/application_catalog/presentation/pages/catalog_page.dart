import 'package:ai_agent_launcher/app/router/app_router.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionAnonymous) context.go(AppRoutes.login);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Applications'),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => context.read<SessionBloc>().add(
                const SessionSignOutRequested(),
              ),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch_outlined, size: 72),
              SizedBox(height: 16),
              Text('Application catalog will appear here.'),
            ],
          ),
        ),
      ),
    );
  }
}
