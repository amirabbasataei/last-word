import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/result/presentation/result_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String game = '/game';
  static const String result = '/result';

  static final router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: game,
        name: 'game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: result,
        name: 'result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultScreen(
            score: extra['score'] as int,
            words: List<String>.from(extra['words'] as List),
            isNewRecord: extra['isNewRecord'] as bool? ?? false,
          );
        },
      ),
    ],
  );
}
