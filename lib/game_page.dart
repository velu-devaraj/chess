import 'dart:convert';
import 'dart:ui' as ui;


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'piece_images.dart';
import 'chess_board.dart';
import 'game.dart';

const double rSize = 40.0;
GlobalKey? chessPageKey;

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

// 4k2r/6r1/8/8/8/8/3R4/R3K3 w Qk - 0 1.
// The "Qk" in the third field indicates that White may castle queenside and Black may castle kingside.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        appBar: AppBar(
          title: Text("${game.player1} vs ${game.player2}"),
        ),
        body: Center(
          child: SizedBox(
            width: 600,
            height: 600,
            child: GridWidget(key: GlobalKey()),
          ),
        ));
  }
}

class GridWidget extends StatefulWidget {
  const GridWidget({super.key});

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
      ChessBoard.fromFEN( (chessPageKey?.currentWidget as ChessPage).game.fen);

  ChessBoard getChessBoard() {
    return chessBoard;
  }

  static late List<Widget> whitesPieces;
  static late List<Widget> blackPieces;
  static bool arePromotionPiecesLoaded = false;
  loadPromotionChoices() {

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

  GridWidgetState() {}

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

    prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> m = g.toJson();
    String s = jsonEncode(g);
    prefs!.setString(g.getKey(), s);
  }

  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: gestureDetectorKey,
        onDoubleTapDown: (details) {
          
          int col = details.localPosition.dx.round();
          int row = details.localPosition.dy.round();

          var rec = localPositionToCellID(
              details.localPosition, gestureDetectorKey.currentContext!.size);
         
          setState(() {
            MoveSteps valid = chessBoard.setSelectedSquare(rec);
            if (null != chessBoard.boardExternalState.whitePromotionSquare ||
                null != chessBoard.boardExternalState.blackPromotionSquare) {
              bool displayWhitePieces =
                  null != chessBoard.boardExternalState.whitePromotionSquare;
              loadPromotionChoices();
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      title: const Text('Select Promotion'),
                      
                      actions:
                          displayWhitePieces ? whitesPieces : blackPieces));
            }
            if (valid == MoveSteps.moved) {
              storeGame();
            }
          });
    
        },
        child: CustomPaint(
          key: customPaintKey,
          painter: ChessGridPainter(
              key: GlobalKey(),
              getChessBoard: getChessBoard), /* child : const GridWidget() */
        ));
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
