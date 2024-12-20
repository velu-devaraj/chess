import 'dart:async';

import 'package:chess/models/app_data_store.dart';
import 'package:chess/models/app_state_data.dart';
import 'package:chess/widgets/moves_list_widget.dart';
import 'package:chess/models/uci_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/chess_board.dart';
import '../models/game.dart';
import '../models/move.dart';
import 'grid_widget.dart';
import 'widget_keys.dart';



class ChessPage extends StatefulWidget {
 // dynamic game;

  ChessPage({super.key}) {
    chessPageKey = key as GlobalKey;
  }

  @override
  ChessWidgetState createState() => ChessWidgetState();
}

class ChessWidgetState extends State<ChessPage> {
  //Game game;

  ChessWidgetState();

  @override
  void initState() {
    super.initState();

    //  initResources();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      initResources();
      makeFirstMove();
    });
  }

  StreamSubscription<Move>? subscription1;
  StreamSubscription<Move>? subscription2;

  bool resourcesInitiatlized = false;

  late Move lastHalfMove;
  initResources() {
    if (resourcesInitiatlized) {
      return;
    }
//    ChessPage cp = chessPageKey?.currentWidget as ChessPage;

 //   Game g = cp.game;

    Game? g = AppStateData.getInstance().currentGame;
    if (null == gameWidgetKey!.currentState!) {
      return;
    }
    GridWidgetState gws = (gameWidgetKey!.currentState! as GridWidgetState);
    MovesListWidgetState mlws =
        (movesListWidgetKey!.currentState! as MovesListWidgetState);

    gws.setChessBoard(g!);
    g!.player1.resetStream();
    g.player2.resetStream();

    subscription1 = g.player1.stream.listen((onData) {
      gws.setState(() {
        MoveSteps ms = gws.moveStep(onData);
        if (ms == MoveSteps.moved) {
          
          g.moves.add(lastHalfMove);
          g.moves.add(onData);
          if (g.moves.length > 0 && g.moves.length % 2 == 0) {
            mlws.setState(() {});
          }
          gws.changeTurn(g);
          g.player2.play();
        }else{
          lastHalfMove = onData;
        }
      });
    }, onDone: () {
      // TODO Any cleanup?
    });

    subscription2 = g.player2.stream.listen((onData) {
      gws.setState(() {
        MoveSteps ms = gws.moveStep(onData);
        if (ms == MoveSteps.moved) {
          g.moves.add(lastHalfMove);
          g.moves.add(onData);
          if (g.moves.length > 0 && g.moves.length % 2 == 0) {
            mlws.setState(() {});
          }

          gws.changeTurn(g);
          g.player1.play();
        }else{
          lastHalfMove = onData;
        }
      });
    }, onDone: () {
      // TODO any cleanup?
    });
    resourcesInitiatlized = true;
  }

  @override
  void dispose() {
    AppDataStore ads = AppDataStore.getInstance();

    /*
    if (null != ads.currentGame) {
      Game? g = ads.currentGame;
      // Dispose the StreamController
      g!.player1.close();
      g.player2.close();
    }
*/
    // Cancel the StreamSubscription
    subscription1!.cancel();
    subscription2!.cancel();
    // Call the super.dispose()
    resourcesInitiatlized = false;
    super.dispose();
  }

  void makeFirstMove() {
        Game? game = AppStateData.getInstance().currentGame;

    if (game!.player1 is UCIClient && game.player1.isTurn) {
      UCIClient p = game.player1 as UCIClient;
      p.setFEN(game.fen);
      p.play();
    } else if (game.player2 is UCIClient && game.player2.isTurn) {
      UCIClient p = game.player2 as UCIClient;
      p.setFEN(game.fen);
      p.play();
    }
  }
// 4k2r/6r1/8/8/8/8/3R4/R3K3 w Qk - 0 1.
// The "Qk" in the third field indicates that White may castle queenside and Black may castle kingside.

  @override
  Widget build(BuildContext context) {
    GridWidget gw = GridWidget(key: GlobalKey());
    MovesListWidget mlw = MovesListWidget(key: GlobalKey());
        Game? game = AppStateData.getInstance().currentGame;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // Set the height here
          child: AppBar(
            title: Text("${game!.player1.name} vs ${game.player2.name}"),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              width: 8 * 40 + 5,
              height: 8 * 40 + 10,
              child: gw, // GridWidget(key: GlobalKey()),
            ),
            Expanded(
                //   width: 8 * 40 + 5,
                //   height: 6 * 40 + 10,
                child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: mlw, //MovesListWidget(key: GlobalKey())),
            )),
          ],
        ));
  }
}
