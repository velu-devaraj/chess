import '../game.dart';

class AppStateData{

  static AppStateData? appStateData;
  
  static AppStateData getInstance() {
    if (null == appStateData) {
      appStateData = AppStateData();
     
    }
    return appStateData!;
  }


  Game? _currentGame;

  Game? get currentGame => _currentGame;

  set currentGame(Game ?value) {
    _currentGame = value;
  }
}