
import 'package:flutter/material.dart';
import 'widgets/game_page.dart';
import 'widgets/main_page.dart';
import 'widgets/settings_page.dart';

class GameRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainWidget());
      case '/game':
        return MaterialPageRoute(
            builder: (_) => ChessPage(settings.arguments, key: GlobalKey()));
      case '/settings':
        return MaterialPageRoute(
            builder: (_) => SettingsPage(key: GlobalKey()));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
