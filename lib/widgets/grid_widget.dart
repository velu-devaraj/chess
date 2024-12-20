import 'dart:async';
import 'dart:ui' as ui;

import 'package:chess/models/human_player.dart';
import 'package:chess/models/app_data_store.dart';
import 'package:chess/widgets/moves_list_widget.dart';
import 'package:chess/models/uci_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state_data.dart';
import '../piece_images.dart';
import '../models/chess_board.dart';
import '../models/game.dart';
import '../models/move.dart';
import 'widget_keys.dart';

const double rSize = 40.0;

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
      //  ChessBoard.fromFEN((chessPageKey?.currentWidget as ChessPage).game.fen);
      ChessBoard.fromFEN((AppStateData.getInstance().currentGame!.fen));
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
    //   ChessPage cp = chessPageKey?.currentWidget as ChessPage;

    //   Game g = cp.game;

    Game? g = AppStateData.getInstance().currentGame;
    g!.fen = chessBoard.toFEN();

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

          //         ChessPage cp = chessPageKey?.currentWidget as ChessPage;

          //         Game g = cp.game;
          Game? g = AppStateData.getInstance().currentGame;

          if (g!.player1.isTurn) {
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
