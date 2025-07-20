import 'package:gatewise_app/modules/authenticate/presentation/auth_screen.dart';
import 'package:go_router/go_router.dart';
import '../../modules/splash_screen/presentation/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/auth-login',
      builder: (context, state) => const AuthLoginScreen(),
    ),
  ],
);
