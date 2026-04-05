import 'package:go_router/go_router.dart';
import 'package:snake_game/screens/game/snake_game_screen.dart';

class RoutesNames {
  static const String gameScreen = '/gameScreen';

}

List<RouteBase> routesList() {
  return [
  
    GoRoute(
      path: RoutesNames.gameScreen,
      builder: (context, state) {
        return SnakeGame();
      },
    ),

  ];
}
