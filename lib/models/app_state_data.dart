import 'game.dart';

class AppStateData {
  static AppStateData? appStateData;

  static AppStateData getInstance() {
    if (null == appStateData) {
      appStateData = AppStateData();
    }
    return appStateData!;
  }

  Game? _currentGame;

  Game? get currentGame => _currentGame;

  set currentGame(Game? value) {
    if (null != _currentGame) {
      _currentGame!.player1.close();
      _currentGame!.player2.close();
    }
    _currentGame = value;
  }
}
