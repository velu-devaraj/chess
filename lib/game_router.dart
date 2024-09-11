import 'package:flutter/material.dart';
import 'game_page.dart';
import 'main_page.dart';


class GameRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainWidget());
      case '/game':
        return MaterialPageRoute(builder: (_) => ChessPage(settings.arguments, key : GlobalKey() ));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
