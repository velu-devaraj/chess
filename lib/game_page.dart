import 'dart:async';
import 'dart:ui' as ui;

import 'package:chess/human_player.dart';
import 'package:chess/src/app_data_store.dart';
import 'package:chess/src/moves_list_widget.dart';
import 'package:chess/uci_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'piece_images.dart';
import 'chess_board.dart';
import 'game.dart';
import 'move.dart';
//import 'src/com/uci/api/move.dart.bak';

const double rSize = 40.0;
GlobalKey? chessPageKey;
GlobalKey? gameWidgetKey;
GlobalKey? movesListWidgetKey;

class ChessPage extends StatefulWidget {
  dynamic game;

  ChessPage(this.game, {super.key}) {
    chessPageKey = key as GlobalKey;
  }

  @override
  ChessWidgetState createState() => ChessWidgetState(game as Game);
}

class ChessWidgetState extends State<ChessPage> {
  Game game;

  ChessWidgetState(this.game);

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
    ChessPage cp = chessPageKey?.currentWidget as ChessPage;

    Game g = cp.game;
    if (null == gameWidgetKey!.currentState!) {
      return;
    }
    GridWidgetState gws = (gameWidgetKey!.currentState! as GridWidgetState);
    MovesListWidgetState mlws =
        (movesListWidgetKey!.currentState! as MovesListWidgetState);

    gws.setChessBoard(g);
    g.player1.resetStream();
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
    if (game.player1 is UCIClient && game.player1.isTurn) {
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

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // Set the height here
          child: AppBar(
            title: Text("${game.player1.name} vs ${game.player2.name}"),
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

class GridWidget extends StatefulWidget {
  GridWidget({super.key}) {
    gameWidgetKey = key as GlobalKey;
  }

  @override
  // ignore: no_logic_in_create_state
  State<GridWidget> createState() {
    return GridWidgetState();
  }
}

class GridWidgetState extends State<GridWidget> {
  final GlobalKey gestureDetectorKey = GlobalKey();
  final GlobalKey customPaintKey = GlobalKey();
  late final ChessGridPainter chessGridPainter;
  ChessBoard chessBoard =
      ChessBoard.fromFEN((chessPageKey?.currentWidget as ChessPage).game.fen);

  ChessBoard getChessBoard() {
    return chessBoard;
  }

  static late List<Widget> whitesPieces;
  static late List<Widget> blackPieces;
  static bool arePromotionPiecesLoaded = false;
  loadPromotionChoices() {
    //if(mounted)
    if (!arePromotionPiecesLoaded) {
      whitesPieces = List<Widget>.empty(growable: true);
      blackPieces = List<Widget>.empty(growable: true);

      const List<int> whites = [1, 2, 3, 4];
      for (int i = 0; i < 4; i++) {
        whitesPieces.add(IconButton(
            onPressed: () {
              chessBoard.promotePawnTo(whites[i]);
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {});
            },
            icon: Image.asset(Pieces.pieces[whites[i]].iconName)));
      }
      const List<int> blacks = [7, 8, 9, 10];
      for (int i = 0; i < 4; i++) {
        blackPieces.add(IconButton(
            onPressed: () {
              chessBoard.promotePawnTo(blacks[i]);
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {});
            },
            icon: Image.asset(Pieces.pieces[blacks[i]].iconName)));
      }
      arePromotionPiecesLoaded = true;
    }
  }

  void setChessBoard(Game g) {
    if (g.player1 is UCIClient) {
      UCIClient p = g.player1 as UCIClient;
      p.setChessBoard(chessBoard);
    }
    if (g.player2 is UCIClient) {
      UCIClient p = g.player2 as UCIClient;
      p.setChessBoard(chessBoard);
    }
  }

  bool resourcesInitiatlized = false;
  GridWidgetState() {
    // initResources();
  }
  late StreamSubscription<Move> subscription1;

  late StreamSubscription<Move> subscription2;

  @override
  void dispose() {
    super.dispose();
  }

  void changeTurn(Game g) {
    g.player1.isTurn = !g.player1.isTurn;
    g.player2.isTurn = !g.player2.isTurn;
  }

  (int, int) localPositionToCellID(Offset offset, Size? canvasSize) {
    double renderedXSize = rSize * 8;
    double renderedYSize = rSize * 8;
    double xStart = (canvasSize!.width - renderedXSize) / 2;
    double yStart = (canvasSize.height - renderedYSize) / 2;
    int row = 7 - ((offset.dy - yStart) / rSize).floor();
    int col = ((offset.dx - xStart) / rSize).floor();

    return (row, col);
  }

  void storeGame() async {
    ChessPage cp = chessPageKey?.currentWidget as ChessPage;

    Game g = cp.game;
    g.fen = chessBoard.toFEN();

    if (g.player1 is UCIClient) {
      UCIClient p = g.player1 as UCIClient;
      p.setFEN(g.fen);
    }
    if (g.player2 is UCIClient) {
      UCIClient p = g.player2 as UCIClient;
      p.setFEN(g.fen);
    }

    AppDataStore ads = AppDataStore.getInstance();
    ads.storeObject(g);
  }

  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    //  initResources(); // TODO call from parent?
    return GestureDetector(
        key: gestureDetectorKey,
        onDoubleTapDown: (details) {
          int col = details.localPosition.dx.round();
          int row = details.localPosition.dy.round();

          var rec = localPositionToCellID(
              details.localPosition, gestureDetectorKey.currentContext!.size);

          ChessPage cp = chessPageKey?.currentWidget as ChessPage;

          Game g = cp.game;

          if (g.player1.isTurn) {
            if (g.player1 is Humanplayer) {
              Move m = Move();
              m.playerIndex = 0;
              m.square = rec;
              g.player1.addData(m);
            } else {
              String fen = chessBoard.toFEN();
              UCIClient player = g.player1 as UCIClient;
              player.setFEN(fen);
              player.setChessBoard(chessBoard);
            }
          }

          if (g.player2.isTurn) {
            if (g.player2 is Humanplayer) {
              Move m = Move();
              m.playerIndex = 1;
              m.square = rec;
              g.player2.addData(m);
            } else {
              String fen = chessBoard.toFEN();
              UCIClient player = g.player2 as UCIClient;
              player.setFEN(fen);
              player.setChessBoard(chessBoard);
            }
          }
        },
        child: CustomPaint(
          key: customPaintKey,
          painter: ChessGridPainter(
              key: GlobalKey(),
              getChessBoard: getChessBoard), /* child : const GridWidget() */
        ));
  }

  MoveSteps moveStep(Move move) {
    // if it player1's turn and is on this device select square.
    // or player2's turn and is on this device select square.
    // else ignore.
    // don't call  chessBoard.setSelectedSquare(rec); directly
    // show visually geometrical reach areas
    //
    (int, int) rec = move.square;
    MoveSteps valid = chessBoard.setSelectedSquare(rec);
    if (null != chessBoard.boardExternalState.whitePromotionSquare ||
        null != chessBoard.boardExternalState.blackPromotionSquare) {
      bool displayWhitePieces =
          null != chessBoard.boardExternalState.whitePromotionSquare;
      loadPromotionChoices();

      if (-1 == move.promotoinPiece) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: const Text('Select Promotion'),
                actions: displayWhitePieces ? whitesPieces : blackPieces));
      }
    } else {}
    if (valid == MoveSteps.moved) {
      storeGame();
    }

    return valid;
  }
}

typedef ModelGetter = ChessBoard Function();

class ChessGridPainter extends ChangeNotifier implements CustomPainter {
  late GlobalKey customPainterKey;

  ModelGetter getChessBoard;

  ChessGridPainter({key, required this.getChessBoard}) {
    customPainterKey = key;
  }

  void paintSelection(Canvas canvas, Size size) {
    ChessBoard cb = getChessBoard();
    if (null == cb.selectedSquare) {
      return;
    }

    final paintWhiteSelected = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.lightGreenAccent.withRed(255);

    final paintBlackSelected = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.grey.withRed(255);

    double xStart = (size.width - rSize * 8) / 2;
    double yStart = (size.height - rSize * 8) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(xStart + (rSize * cb.selectedSquare!.$2),
              yStart + (rSize * (7 - cb.selectedSquare!.$1)), rSize, rSize),
          const Radius.circular(3)),
      (cb.selectedSquare!.$1 + cb.selectedSquare!.$2) % 2 != 0
          ? paintWhiteSelected
          : paintBlackSelected,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
    final paintWhite = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0
      ..color = Colors.lightGreenAccent.shade100;

    final paintBlack = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0
      ..color = Colors.grey;

    double xStart = (size.width - rSize * 8) / 2;
    double yStart = (size.height - rSize * 8) / 2;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(
                    xStart + (rSize * j), yStart + (rSize * i), rSize, rSize),
                const Radius.circular(3)),
            (i + j) % 2 == 1 ? paintBlack : paintWhite);
      }
    }

    Pieceimages pis = Pieceimages();
    List<ui.Image?> images = pis.loadImages();

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        int imageIndex = getChessBoard().squares[i][j];
        if (100 == imageIndex) {
          continue;
        }

        ui.Image origImage = images[imageIndex]!;
        Offset offset =
            Offset(xStart + (rSize * j), yStart + (rSize * (7 - i)));
        canvas.drawImage(origImage, offset, Paint());
      }
    }

    paintSelection(canvas, size);
  }

  @override
  bool shouldRepaint(ChessGridPainter oldDelegate) => true;

  @override
  bool get hasListeners => true;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  (int, int) localPositionToCellID(Offset offset, Size? canvasSize) {
    double renderedXSize = rSize * 8;
    double renderedYSize = rSize * 8;
    double xStart = (canvasSize!.width - renderedXSize) / 2;
    double yStart = (canvasSize.height - renderedYSize) / 2;
    int col = ((offset.dy - yStart) / rSize).floor();
    int row = ((offset.dx - xStart) / rSize).floor();

    return (row, col);
  }

  bool? hitTest(Offset position) {
    return true;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return true;
  }
}
