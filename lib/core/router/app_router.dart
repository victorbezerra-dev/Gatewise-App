import 'package:go_router/go_router.dart';
import '../../modules/authenticate/presentation/auth_screen.dart';
import '../../modules/host/presentation/host_screen.dart';
import '../../modules/splash_screen/presentation/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/auth-login',
      builder: (context, state) => const AuthLoginScreen(),
    ),
    GoRoute(path: '/main', builder: (context, state) => const HostScreen()),
  ],
);
