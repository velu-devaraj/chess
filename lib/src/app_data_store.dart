import 'dart:async';
import 'dart:core';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game.dart';
import 'server_config.dart';
import 'games_list_notifier.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppDataStore {
  ServerConfig? _serverConfig;

  ServerConfig? get serverConfig => _serverConfig;

  set serverConfig(ServerConfig? value) {
    _serverConfig = value;
  }


  
  GamesListNotifier gamesList = GamesListNotifier();

  static AppDataStore? appDataStore;

  Game? get currentGame => null;

  static AppDataStore getInstance() {
    if (null == appDataStore) {
      appDataStore = AppDataStore();
      appDataStore!.loadData();
    }
    return appDataStore!;
  }

  void loadData() {
    SharedPreferencesWithCache spc;
    Completer completer = Completer();
    SharedPreferencesWithCache.create(
            cacheOptions: SharedPreferencesWithCacheOptions())
        .then((onValue) {
      spc = onValue;
      int len = spc.keys.length;
      completer.complete(spc);

      List<Game> games = List.empty(growable: true);

      int i = 0;
      while (i < len) {
        String key = spc.keys.elementAt(i);
        String json = spc.get(key) as String;
        dynamic map = jsonDecode(json);
        if (key.startsWith("flutter.ServerConfig")) {
          serverConfig = ServerConfig.fromJson(map);
        } else {
          Game g = Game.fromJson(map);
          games!.add(g);
        }
        i++;
      }

      gamesList.games = games;

      Completer<ServerConfig> completer2 = Completer<ServerConfig>();
      if (null == serverConfig) {
        loadJsonData().then((value) {
          serverConfig = value;
          completer2.complete(value);
        });
      }
      //dynamic temp = completer2.future as 
      completer2.future.then( (value){
        dynamic temp = value;
        return temp;
      } );
    });
  }

  void storeObject(dynamic storableObject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Map<String, dynamic> m = storableObject.toJson();
    var encoder = JsonEncoder.withIndent(' ');
    //   String s = jsonEncode(storableObject);
    String s = encoder.convert(storableObject);
    prefs!.setString(storableObject.getKey(), s);
  }

  Future<ServerConfig> loadJsonData() async {
    // Load the JSON file

    String jsonString;
    ServerConfig serverConfig;
    Completer completer = Completer();

    await rootBundle.loadString('assets/settings.json').then((onValue) {
      jsonString = onValue;
      dynamic map = jsonDecode(jsonString);
      serverConfig = ServerConfig.fromJson(map);
      completer.complete(serverConfig);
      // return serverConfig;
    });

    // Parse the JSON

    //return serverConfig;
    return await completer.future;
  }
}


