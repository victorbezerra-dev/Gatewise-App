import 'package:go_router/go_router.dart';
import '../../modules/splash_screen/presentation/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const SplashPage())],
);
