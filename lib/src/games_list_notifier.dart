import 'package:flutter/material.dart';

import '../models/game.dart';

class GamesListNotifier with ChangeNotifier {
  late List<Game> _games;
  bool gamesListLoaded = false;

  List<Game> get games => _games;

  set games(List<Game> value) {
    _games = value;
    gamesListLoaded = true;
    notifyListeners();
  }
  
  void setGames(List<Game> games){

    notifyListeners();
  }

  void addGame(Game game){
    _games.add(game);
    notifyListeners();
  }
  
}