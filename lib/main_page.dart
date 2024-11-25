import 'dart:async';
import 'dart:convert';

import 'package:chess/human_player.dart';
import 'package:chess/uci_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chess_board.dart';

import 'game.dart';
import 'player.dart';
import 'src/server_config.dart';

typedef ModelGetter = Game Function();
typedef ModelSetter = void Function(Game? g);
typedef ServerConfigGetter = ServerConfig Function();
typedef ServerConfigSetter = void Function(ServerConfig? g);

class MainWidget extends StatefulWidget {
  MainWidget({super.key}) {}

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  bool isEngine1 = false;
  bool isEngine2 = true;

  bool player1White = true;
  String? player1Name;

  String? player2Name;

  ModelGetter? getGame;

  Game? game;
  ServerConfig? serverConfig;

  void setGame(Game? g) {
    this.game = g;
  }

  void setServerConfig(ServerConfig? serverConfig) {
    this.serverConfig = serverConfig;
  }

  InputDecoration decoration = InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
    border: new OutlineInputBorder(borderRadius: BorderRadius.only()),
  );

  final ButtonStyle style = ElevatedButton.styleFrom(
      padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontSize: 20),
      shape: const LinearBorder(
        side: BorderSide(color: Colors.blue),
        top: LinearBorderEdge(),
        bottom: LinearBorderEdge(),
        start: LinearBorderEdge(),
        end: LinearBorderEdge(),
      ),
      fixedSize: const Size(200, 60));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: EdgeInsets.all(5.0),
          child: ElevatedButton(
              style: style,
              onPressed: () {
                Navigator.pushNamed(context, "/settings");
              },
              child: const Text("Settings")),
        ),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(children: [
              Expanded(child: const Text("First Player's Name")),
              Expanded(
                  child: LabeledCheckbox(
                label: "Engine Play",
                value: isEngine1,
                onChanged: (bool value) {
                  setState(() {
                    isEngine1 = value;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              )),
              Expanded(
                  child: LabeledCheckbox(
                label: "White",
                value: player1White,
                onChanged: (bool value) {
                  setState(() {
                    player1White = value;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              ))
            ])),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: TextField(
              decoration: decoration,
              onChanged: (value) {
                player1Name = value;
              },
              onSubmitted: (value) {
                player1Name = value;
              },
            )),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Row(children: [
            Expanded(child: const Text("Second Player's Name")),
            Expanded(
                child: LabeledCheckbox(
              label: "Engine Play",
              value: isEngine2,
              onChanged: (bool value) {
                setState(() {
                  isEngine2 = value;
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
            )),
            Expanded(
                child: LabeledCheckbox(
              label: "White",
              value: !player1White,
              onChanged: (bool value) {
                setState(() {
                  player1White = value;
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
            ))
          ]),
        ),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: TextField(
              decoration: decoration,
              onChanged: (value) {
                player2Name = value;
              },
              onSubmitted: (value) {
                player2Name = value;
              },
            )),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: GameListWidget(setGame, setServerConfig)),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: ElevatedButton(
                style: style,
                onPressed: () {
                  Game? g;
                  if (null != this.game) {
                    g = game;
                  } else if (null != player1Name && null != player2Name) {
                    Player player1;
                    Player player2;

                    if (isEngine1) {
                      player1 = UCIClient(
                          "UCIClient", player1Name, player1White, player1White);
                    } else {
                      player1 = Humanplayer("Humanplayer", player1Name,
                          player1White, player1White);
                    }
                    if (isEngine2) {
                      player2 = UCIClient("UCIClient", player2Name,
                          !player1White, !player1White);
                    } else {
                      player2 = Humanplayer("Humanplayer", player2Name,
                          !player1White, !player1White);
                    }
                    // g = Game(player1Name!, player2Name!, ChessBoard.startPosFEN);
                    g = Game(player1, player2, ChessBoard.startPosFEN);
                  } else {
                    return;
                  }
                  Navigator.pushNamed(context, "/game", arguments: g);
                },
                child: const Text("Start")))
      ]),
    );
  }
}

class GameListWidget extends StatefulWidget {
  ModelSetter setModel;
  ServerConfigSetter setServerConfig;

  GameListWidget(this.setModel, this.setServerConfig);
  @override
  State<StatefulWidget> createState() {
    GameListWidgetState glws = GameListWidgetState();
    return glws;
  }
}

class GameListWidgetState extends State<StatefulWidget> {
  Player deserialize(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'UCIClient':
        return UCIClient.fromJson(json);
      case 'Humanplayer':
      //return Humanplayer.fromJson(json);
      default:
        throw Exception('Unknown type');
    }
  }

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
        if (key.startsWith("flutter.ServerConfig")) {
          serverConfig = ServerConfig.fromJson(map);
        } else {
          Game g = Game.fromJson(map);
          games!.add(g);
        }
        i++;
      }
      if (null == serverConfig) {
        serverConfig = ServerConfig();
      }
      GameListWidget glw = this.widget as GameListWidget;
      glw.setServerConfig(serverConfig);
      setState(() {});
    });
  }

  List<Game>? games;
  ServerConfig? serverConfig;

  int selectedIndex = -1;

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
          key: UniqueKey(),
          color: WidgetStateColor.resolveWith((states) {
            /*
            if (states.isEmpty) {
              return Colors.lightBlueAccent;
            }
            */
            if (i == selectedIndex) {
              return Colors.lightGreenAccent.shade100;
            } else {
              return Colors.lightBlueAccent.shade100;
            }
          }),
          onSelectChanged: (value) {
            GameListWidget glw = this.widget as GameListWidget;
            setState(() {
              if (!value!) {
                selectedIndex = -1;
                gameIndex = -1;
                // game = null;
                glw.setModel(games[i]);
                return;
              }
              selectedIndex = i;
              gameIndex = i;

              glw.setModel(games[i]);
            });

            /// print(value.toString());
          },
          cells: [
            DataCell(Text(key: UniqueKey(), games[i].player1.name),
                onDoubleTap: () {
              gameIndex = i;
              GameListWidget glw = this.widget as GameListWidget;
              setState(() {
                if (-1 == selectedIndex) {
                  selectedIndex = i;
                } else {
                  selectedIndex = -1;
                }
              });

              glw.setModel(games[i]);
            }),
            DataCell(Text(games[i].player2.name), onDoubleTap: () {
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
      showCheckboxColumn: true,
      columns: cols,
      rows: rows,
      headingRowColor:
          WidgetStateColor.resolveWith((states) => Colors.amberAccent.shade100),
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

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
