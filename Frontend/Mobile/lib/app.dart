import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/session_manager.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_router.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/security/presentation/pages/app_lock_page.dart';

class GoldWalletApp extends StatefulWidget {
  const GoldWalletApp({super.key});

  @override
  State<GoldWalletApp> createState() => _GoldWalletAppState();
}

class _GoldWalletAppState extends State<GoldWalletApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  bool _locked = false;
  bool _ready = false;
  Timer? _inactivityTimer;
  Timer? _configurationSyncTimer;
  StreamSubscription<SessionLogoutEvent>? _logoutSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logoutSubscription = SessionManager.logoutEvents.listen(_handleLogoutEvent);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final isInstalledBefore = prefs.getBool('app_installed_once') ?? false;
    if (!isInstalledBefore) {
      await AuthSessionStore.clearAll();
      await prefs.setBool('app_installed_once', true);
    }

    await AuthSessionStore.hydrate();
    await _syncRemoteConfiguration();
    await AuthSessionStore.applyAdminUnlockPolicy();

    if (AuthSessionStore.isLoggedIn &&
        AppReleaseConfig.quickUnlockAllowed &&
        !AuthSessionStore.hasUnlockMethod) {
      await AuthSessionStore.setQuickUnlockEnabled(false);
      await AuthSessionStore.setSecuritySetupDone(false);
      await AuthSessionStore.setLocked(false);
    }

    if (AuthSessionStore.isLoggedIn) {
      final expired = AuthSessionStore.accessTokenExpiresAtUtc != null &&
          AuthSessionStore.accessTokenExpiresAtUtc!.isBefore(DateTime.now().toUtc());
      if (expired) {
        try {
          await SessionManager.refreshTokenIfNeeded();
        } catch (_) {
          await SessionManager.forceLogout(localOnly: true);
        }
      }
    }

    final shouldLockImmediately = AuthSessionStore.isLoggedIn &&
        AuthSessionStore.quickUnlockEnabled &&
        AuthSessionStore.hasUnlockMethod;

    if (mounted) {
      setState(() {
        _locked = shouldLockImmediately;
        _ready = true;
      });
    }
    await AuthSessionStore.markInactiveNow();
    _startInactivityWatcher();
    _startConfigurationSyncWatcher();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AuthSessionStore.markInactiveNow();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_syncRemoteConfiguration());
      AuthSessionStore.shouldLockForInactivity().then((shouldLock) async {
        if (!mounted || !shouldLock || !AuthSessionStore.isLoggedIn) return;
        await AuthSessionStore.setLocked(true);
        setState(() => _locked = true);
      });
    }
  }

  void _startInactivityWatcher() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _locked || !AuthSessionStore.isLoggedIn) return;
      final shouldLock = await AuthSessionStore.shouldLockForInactivity();
      if (!shouldLock) return;
      await AuthSessionStore.setLocked(true);
      if (!mounted) return;
      setState(() => _locked = true);
    });
  }

  void _startConfigurationSyncWatcher() {
    _configurationSyncTimer?.cancel();
    _configurationSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _syncRemoteConfiguration();
    });
  }

  Future<void> _syncRemoteConfiguration() async {
    final previousRevision = AppReleaseConfig.revisionListenable.value;
    await InjectionContainer.syncReleaseConfiguration();
    await AuthSessionStore.applyAdminUnlockPolicy();
    if (mounted && previousRevision != AppReleaseConfig.revisionListenable.value) {
      setState(() {});
    }
  }

  Future<void> _handleLogoutEvent(SessionLogoutEvent event) async {
    if (!mounted) return;

    if (event.reason == SessionLogoutReason.sessionExpired ||
        event.reason == SessionLogoutReason.unauthorized) {
      final shouldRequireUnlock =
          AppReleaseConfig.quickUnlockAllowed &&
          AuthSessionStore.quickUnlockEnabled &&
          AuthSessionStore.hasUnlockMethod;

      if (shouldRequireUnlock) {
        await AuthSessionStore.setLocked(true);
      } else {
        await AuthSessionStore.setLocked(false);
      }

      if (!mounted) return;
      setState(() {
        _locked = shouldRequireUnlock;
      });

      _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.loginRoute,
        (_) => false,
      );
      return;
    }

    await AuthSessionStore.setLocked(false);
    if (!mounted) return;
    setState(() => _locked = false);
    _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.loginRoute,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: _rootNavigatorKey,
            debugShowCheckedModeBanner: false,
            title: AppLocalizations.of(context).appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) {
              if (!_ready) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final appChild = Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => AuthSessionStore.markInactiveNow(),
                onPointerSignal: (_) => AuthSessionStore.markInactiveNow(),
                child: child ?? const SizedBox.shrink(),
              );

              if (!_locked) return appChild;

              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                  builder: (_) => AppLockPage(
                    onUnlocked: () {
                      if (!mounted) return;
                      setState(() => _locked = false);
                      if (!AuthSessionStore.isLoggedIn) {
                        _rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                          AppRoutes.loginRoute,
                          (_) => false,
                        );
                      }
                    },
                    onLoginFallback: () async {
                      await AuthSessionStore.setLocked(false);
                      await AuthSessionStore.removePin();
                      await AuthSessionStore.setQuickUnlockEnabled(false);
                      await AuthSessionStore.setSecuritySetupDone(false);
                      await SessionManager.forceLogout();
                      if (!mounted) return;
                      setState(() => _locked = false);
                      _rootNavigatorKey.currentState
                          ?.pushNamedAndRemoveUntil(AppRoutes.loginRoute, (_) => false);
                    },
                  ),
                ),
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
    _inactivityTimer?.cancel();
    _configurationSyncTimer?.cancel();
    _logoutSubscription?.cancel();
    super.dispose();
  }
}
