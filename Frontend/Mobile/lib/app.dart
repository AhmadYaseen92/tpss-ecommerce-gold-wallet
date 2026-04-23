import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/session_manager.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_router.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/security/presentation/pages/app_lock_page.dart';

class GoldWalletApp extends StatefulWidget {
  const GoldWalletApp({super.key});

  @override
  State<GoldWalletApp> createState() => _GoldWalletAppState();
}

class _GoldWalletAppState extends State<GoldWalletApp> with WidgetsBindingObserver {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AuthSessionStore.hydrate();
    final needsRefresh = AuthSessionStore.accessTokenExpiresAtUtc != null &&
        AuthSessionStore.accessTokenExpiresAtUtc!.isBefore(DateTime.now().toUtc());
    if (needsRefresh && SessionManager.hasValidRefreshToken) {
      try {
        await SessionManager.refreshTokenIfNeeded();
      } catch (_) {
        await SessionManager.forceLogout(localOnly: true);
      }
    }

    final locked = await AuthSessionStore.isLocked();
    if (mounted) setState(() => _locked = locked);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AuthSessionStore.markInactiveNow();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      AuthSessionStore.shouldLockForInactivity().then((shouldLock) async {
        if (!mounted || !shouldLock || !AuthSessionStore.isLoggedIn) return;
        await AuthSessionStore.setLocked(true);
        setState(() => _locked = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ECommerse Gold Wallet APP',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) {
              if (!_locked) return child ?? const SizedBox.shrink();
              return AppLockPage(
                onUnlocked: () => setState(() => _locked = false),
                onLoginFallback: () async {
                  await SessionManager.forceLogout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (_) => false);
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
