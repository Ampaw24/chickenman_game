import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/onboarding/presentation/screens/nickname_screen.dart';
import '../features/onboarding/presentation/screens/avatar_screen.dart';
import '../features/onboarding/presentation/screens/game_select_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/presentation/screens/game_result_screen.dart';
import '../features/rewards/presentation/screens/voucher_wallet_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String nickname = '/onboarding/nickname';
  static const String avatar = '/onboarding/avatar';
  static const String gameSelect = '/onboarding/game-select';
  static const String home = '/home';
  static const String game = '/game';
  static const String result = '/result';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      pageBuilder: (_, state) => _fadeTransition(state, const AuthScreen()),
    ),
    GoRoute(
      path: AppRoutes.nickname,
      pageBuilder: (_, state) =>
          _slideTransition(state, const NicknameScreen()),
    ),
    GoRoute(
      path: AppRoutes.avatar,
      pageBuilder: (_, state) =>
          _slideTransition(state, const AvatarScreen()),
    ),
    GoRoute(
      path: AppRoutes.gameSelect,
      pageBuilder: (_, state) =>
          _slideTransition(state, const GameSelectScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (_, state) => _fadeTransition(state, const HomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.game,
      pageBuilder: (_, state) => _slideTransition(state, const GameScreen()),
    ),
    GoRoute(
      path: AppRoutes.result,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return _slideTransition(
          state,
          GameResultScreen(
            score: extra['score'] as int? ?? 0,
            reward: extra['reward'] as String? ?? '',
            loyaltyPoints: extra['loyaltyPoints'] as int? ?? 0,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.wallet,
      pageBuilder: (_, state) => _slideTransition(state, const VoucherWalletScreen()),
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (_, state) => _slideTransition(state, const ProfileScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, widget) => FadeTransition(
      opacity: animation,
      child: widget,
    ),
  );
}

CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, widget) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: widget),
    ),
  );
}
