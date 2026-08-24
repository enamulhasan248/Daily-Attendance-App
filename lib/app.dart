/// App root — theme, routing, and auth gate.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

class AttendanceApp extends ConsumerStatefulWidget {
  const AttendanceApp({super.key});

  @override
  ConsumerState<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends ConsumerState<AttendanceApp> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await ref.read(authProvider.notifier).tryAutoLogin();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Daily Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isChecking
          ? const _SplashScreen()
          : user != null
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accent,
                    AppTheme.accent.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGlow,
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
