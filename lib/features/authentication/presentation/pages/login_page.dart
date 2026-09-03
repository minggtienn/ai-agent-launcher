import 'package:ai_agent_launcher/app/config/app_environment.dart';
import 'package:ai_agent_launcher/app/di/service_locator.dart';
import 'package:ai_agent_launcher/app/router/app_router.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/bloc/session_bloc.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/launcher_brand.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/login_hero_panel.dart';
import 'package:ai_agent_launcher/features/authentication/presentation/widgets/window_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

final class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _rememberAccount = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionAuthenticated) context.go(AppRoutes.catalog);
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final showCampaign = constraints.maxWidth >= 980;
            return Row(
              children: [
                if (showCampaign) const Expanded(child: LoginHeroPanel()),
                SizedBox(
                  width: showCampaign ? 320 : constraints.maxWidth,
                  child: _buildLoginPanel(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context) {
    final config = serviceLocator<AppConfig>();
    return ColoredBox(
      color: const Color(0xFF11151E),
      child: Column(
        children: [
          const DragToMoveArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: WindowControls(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    const Center(child: LauncherBrand()),
                    const SizedBox(height: 30),
                    const Divider(color: Color(0xFF29303D)),
                    const SizedBox(height: 30),
                    const Text(
                      'ĐĂNG NHẬP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      key: const Key('usernameField'),
                      controller: _username,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Tên tài khoản',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tên tài khoản'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('passwordField'),
                      controller: _password,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu (6 đến 18 ký tự)',
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6 || value.length > 18) {
                          return 'Mật khẩu phải từ 6 đến 18 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberAccount,
                            side: const BorderSide(color: Colors.white60),
                            onChanged: (value) => setState(
                              () => _rememberAccount = value ?? false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: Text(
                            'Ghi nhớ đăng nhập',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _showNotAvailable,
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: Color(0xFFFF4038),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<SessionBloc, SessionState>(
                      builder: (context, state) => SizedBox(
                        height: 52,
                        child: FilledButton(
                          key: const Key('loginButton'),
                          onPressed: state is SessionLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF08AFE8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: state is SessionLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _showNotAvailable,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6DBD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'ĐĂNG KÝ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    BlocBuilder<SessionBloc, SessionState>(
                      builder: (context, state) => state is SessionFailure
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(
                                state.failure.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFF655E),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phiên bản: 1.0.0 • ${config.environment.updateChannel}',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SessionBloc>().add(
      SessionSignInRequested(_username.text.trim(), _password.text),
    );
  }

  void _showNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng sẽ được cập nhật trong phiên bản tiếp theo.'),
      ),
    );
  }
}
