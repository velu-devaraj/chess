import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chess_board.dart';


import 'game.dart';

typedef ModelGetter = Game Function();
typedef ModelSetter = void Function(Game g);

class MainWidget extends StatelessWidget {
  String? player1;
  String? player2;
  ModelGetter? getGame;

  Game? game;

  void setGame(Game g) {
    this.game = g;
  }

  MainWidget({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const Text("First Player's Name"),
        TextField(
          onChanged: (value) {
            player1 = value;
          },
          onSubmitted: (value) {
            player1 = value;
          },
        ),
        const Text("Second Player's Name"),
        TextField(
          onChanged: (value) {
            player2 = value;
          },
          onSubmitted: (value) {
            player2 = value;
          },
        ),
        GameListWidget(setGame),
        ElevatedButton(
            onPressed: () {
              Game? g;
              if (null != this.game) {
                g = game;
              } else if (null != player1 && null != player2) {
                g = Game(player1!, player2!, ChessBoard.startPosFEN);
              }
              Navigator.pushNamed(context, "/game",
                  //   arguments: [player1, player2]);
                  arguments: g);
            },
            child: const Text("Start"))
      ]),
    );
  }
}

class GameListWidget extends StatefulWidget {
  ModelSetter setModel;

  GameListWidget(this.setModel);
  @override
  State<StatefulWidget> createState() {
    GameListWidgetState glws = GameListWidgetState();
    return glws;
  }
}

class GameListWidgetState extends State<StatefulWidget> {
  int gameIndex = -1;

  Game? getGame() {
    if (gameIndex == -1) {
      return null;
    }
    return games!.elementAt(gameIndex);
  }

  GameListWidgetState() {
    SharedPreferencesWithCache spc;
    Completer completer = Completer();
    SharedPreferencesWithCache.create(
            cacheOptions: SharedPreferencesWithCacheOptions())
        .then((onValue) {
      spc = onValue;
      int len = spc.keys.length;
      completer.complete(spc);

      games = List.empty(growable: true);

      int i = 0;
      while (i < len) {
        String key = spc.keys.elementAt(i);
        String json = spc.get(key) as String;
        dynamic map = jsonDecode(json);
        Game g = Game.fromJson(map);
        games!.add(g);
        i++;
      }
      setState(() {});
    });
  }

  List<Game>? games;

  DataTable gamesWidgets(List<Game>? games) {
    List<DataRow> rows = List.empty(growable: true);

    List<DataColumn> cols = [
      DataColumn(label: Text("Player 1")),
      DataColumn(label: Text("Player 2")),
      DataColumn(label: Text("Time")),
    ];

    //rows.add(row);
    if (null == games) {
      DataTable table = DataTable(columns: cols, rows: rows);

      return table;
    }

    for (int i = 0; i < games.length; i++) {
      DataRow row = DataRow(
 
          color: WidgetStateColor.resolveWith((states) {
            if (states.isEmpty) {
              return Colors.lightBlueAccent;
            } else if (states.first == WidgetState.pressed) {
              return Colors.green;
            } else {
              return Colors.lightBlueAccent;
            }
          }),
          cells: [
            DataCell(Text(games[i].player1), onDoubleTap: () {
              gameIndex = i;
              GameListWidget glw = this.widget as GameListWidget;
              glw.setModel(games[i]);
            }),
            DataCell(Text(games[i].player2), onDoubleTap: () {
              gameIndex = i;
              GameListWidget glw = this.widget as GameListWidget;
              glw.setModel(games[i]);
            }),
            DataCell(Text(games[i].dateTime.toString()), onDoubleTap: () {
              gameIndex = i;
              GameListWidget glw = this.widget as GameListWidget;
              glw.setModel(games[i]);
            })
          ]);

      rows.add(row);
    }

    DataTable table = DataTable(
      columns: cols,
      rows: rows,
      headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blue),
      dataRowColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return Colors.lightBlue; // Use the default value.
      }),
    );

    return table;
  }

  @override
  Widget build(BuildContext context) {
    return gamesWidgets(games);
  }
}
