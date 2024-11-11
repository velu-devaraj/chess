class BoardExternalState {
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  bool rook00Moved = true;
  bool rook07Moved = true;
  bool rook70Moved = true;
  bool rook77Moved = true;
  bool whiteCastleCompleted = false;
  bool blackCastleCompleted = false;

  (int i, int j)? whitePromotionSquare;
  (int i, int j)? blackPromotionSquare;
  (int i, int j)? enPassantCaptureSquare;

  int halfMoveCount = 0;
  int fullMoveCount = 0;

  BoardExternalState() {}

  BoardExternalState.from(BoardExternalState bes) {
    whiteKingMoved = bes.whiteKingMoved;
    blackKingMoved = bes.blackKingMoved;
    rook00Moved = bes.rook00Moved;
    rook07Moved = bes.rook07Moved;
    rook70Moved = bes.rook70Moved;
    rook77Moved = bes.rook77Moved;
    whiteCastleCompleted = bes.whiteCastleCompleted;
    blackCastleCompleted = bes.blackCastleCompleted;

    if (null != bes.whitePromotionSquare) {
      whitePromotionSquare =
          (bes.whitePromotionSquare!.$1, bes.whitePromotionSquare!.$2);
    }
    if (null != bes.blackPromotionSquare) {
      blackPromotionSquare =
          (bes.blackPromotionSquare!.$1, bes.blackPromotionSquare!.$2);
    }
    if (null != bes.enPassantCaptureSquare) {
      enPassantCaptureSquare =
          (bes.enPassantCaptureSquare!.$1, bes.enPassantCaptureSquare!.$2);
    }

    halfMoveCount = bes.halfMoveCount;
    fullMoveCount = bes.fullMoveCount;
  }
}

enum MoveSteps { selected, moved, invalid }

class ChessBoard {
  static String startPosFEN =
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0";

  List<List<int>> squares = List.generate(8, (i) => List.filled(8, 100));
  List<Piece> pieces = Pieces.initialize();
  (int row, int col)? selectedSquare;
  List<String> moveHistory = List.empty(growable: true);

  BoardExternalState boardExternalState = BoardExternalState();
  List<List<int>>? prevSquares;
  BoardExternalState? prevBoardExternalState;

  void pushState() {
    prevSquares = List.generate(
        8, (i) => List.filled(8, 100)); // List<List<int>>.from( squares);
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        prevSquares![row][col] = squares[row][col];
      }
    }
    prevBoardExternalState = BoardExternalState.from(boardExternalState);
  }

  void popState() {
    squares = prevSquares!;
    boardExternalState = prevBoardExternalState!;
    selectedSquare = null;
  }

  ChessBoard.fromFEN(String fen) {
    int i = 7;
    int j = 0;
    int breakPos = 0;
    for (int pos = 0; pos < fen.length; pos++) {
      if (breakPos != 0) {
        break;
      }
      switch (fen[pos]) {
        case "p":
          squares[i][j] = 6;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "r":
          squares[i][j] = 7;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "n":
          squares[i][j] = 8;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "b":
          squares[i][j] = 9;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "q":
          squares[i][j] = 10;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "k":
          squares[i][j] = 11;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "P":
          squares[i][j] = 0;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "R":
          squares[i][j] = 1;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "N":
          squares[i][j] = 2;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "B":
          squares[i][j] = 3;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "Q":
          squares[i][j] = 4;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "K":
          squares[i][j] = 5;
          if (j == 7) {
            j = 0;
            i = i - 1;
          } else {
            j++;
          }
          break;
        case "/":
          break;
        default:
          if (fen[pos] == " ") {
            breakPos = pos;
            break;
          }
          int? blankCount = int.tryParse(fen[pos]);
          while (0 < blankCount!) {
            squares[i][j] = 100;
            if (j == 7) {
              j = 0;
              i = i - 1;
            } else {
              j++;
            }
            blankCount--;
          }
      }
    }
    int pos = breakPos + 1;

    if (fen[pos++] == "w") {
      whiteToMove = true;
    } else {
      whiteToMove = false;
    }
    pos += 1; // escape space
    int c = 0;
    while (c < 4) {
      if (fen[pos] == "K") {
        boardExternalState.rook07Moved = false;
        pos++;
      } else if (fen[pos] == "Q") {
        boardExternalState.rook00Moved = false;
        pos++;
      } else if (fen[pos] == "k") {
        boardExternalState.rook70Moved = false;
        pos++;
      } else if (fen[pos] == "q") {
        boardExternalState.rook77Moved = false;
        pos++;
      } else if (fen[pos] == "-") {
        pos++;
        break;
      } else {
        break; // space
      }
      c++;
    }
    pos += 1; // escape space
    if (fen[pos] == "-") {
      pos += 2; // skip space
    } else {
      String code = fen.substring(pos, pos + 2);
      boardExternalState.enPassantCaptureSquare = decodeSquare(code);
      pos += 3;
    }
    String str;
    if (fen[pos + 2] == " ") {
      str = fen.substring(pos, pos + 1);
      pos++;
    } else {
      str = fen.substring(pos, pos + 1);
      pos += 2;
    }
    boardExternalState.halfMoveCount = int.tryParse(str)!;
    if (fen.length > pos + 1) {
      str = fen.substring(pos, pos + 2);
    } else {
      str = fen.substring(pos, pos + 1);
    }
    boardExternalState.fullMoveCount = int.tryParse(str)!;
  }

  List<String> pieceCodes = [
    "P",
    "R",
    "N",
    "B",
    "Q",
    "K",
    "p",
    "r",
    "n",
    "b",
    "q",
    "k"
  ];

  List<String> columnCode = ["a", "b", "c", "d", "e", "f", "g", "h"];

  String toFEN() {
    StringBuffer sb = StringBuffer();

    for (int row = 7; row >= 0; row--) {
      int blanks = 0;
      for (int col = 0; col < 8; col++) {
        if (squares[row][col] == 100) {
          blanks++;
        } else {
          if (0 != blanks) {
            sb.write(blanks);
          }
          sb.write(pieceCodes[squares[row][col]]);
          blanks = 0;
        }
        if (col == 7) {
          if (0 != blanks) {
            sb.write(blanks);
          }
          blanks = 0;
          if (0 != row) {
            sb.write("/");
          }
        }
      }
    }
    String s = whiteToMove ? "w" : "b";
    sb.write(" ");
    sb.write(s);
    //  KQkq e3 0 1
    sb.write(" ");
    bool noCastle = true;
    if (!boardExternalState.rook00Moved && !boardExternalState.whiteKingMoved) {
      sb.write("Q");
      noCastle = false;
    }
    if (!boardExternalState.rook07Moved && !boardExternalState.whiteKingMoved) {
      sb.write("K");
      noCastle = false;
    }
    if (!boardExternalState.rook70Moved && !boardExternalState.blackKingMoved) {
      sb.write("q");
      noCastle = false;
    }
    if (!boardExternalState.rook77Moved && !boardExternalState.blackKingMoved) {
      sb.write("k");
      noCastle = false;
    }
    if (noCastle) {
      sb.write("-");
    }
    sb.write(" ");
    if (boardExternalState.enPassantCaptureSquare != null) {
      sb.write(boardExternalState.enPassantCaptureSquare!.$1);
      sb.write(columnCode[boardExternalState.enPassantCaptureSquare!.$2]);
    } else {
      sb.write("-");
    }
    sb.write(" ");
    sb.write(boardExternalState.halfMoveCount);
    sb.write(" ");
    sb.write(boardExternalState.fullMoveCount);
    return sb.toString();
  }

  (int row, int col) decodeSquare(String code) {
    int row;
    int col;

    if (code[0] == "a") {
      col = 0;
    } else if (code[0] == "b") {
      col = 1;
    } else if (code[0] == "c") {
      col = 2;
    } else if (code[0] == "d") {
      col = 3;
    } else if (code[0] == "e") {
      col = 4;
    } else if (code[0] == "f") {
      col = 5;
    } else if (code[0] == "g") {
      col = 6;
    } else {
      col = 7;
    }
    row = int.tryParse(code[1])!;
    return (row, col);
  }

  MoveSteps setSelectedSquare((int row, int col) rec) {
    if (null != selectedSquare) {
      pushState();
      bool isValid =
          isValidMove(selectedSquare!, rec, whiteToMove, true, false, true);

      if (isValid) {
        makePrevalidatedMove(selectedSquare!, rec);
        isValid = !isKingUnderAttack(!whiteToMove);
        if (isValid) {
          return MoveSteps.moved;
        }
        whiteToMove = !whiteToMove;
        popState();
        return MoveSteps.invalid;
      } else {
        popState();
        return MoveSteps.invalid;
      }
    }

    int fromIndex = squares[rec.$1][rec.$2];
    if (fromIndex == 100) {
      return MoveSteps.invalid;
    } else if (whiteToMove) {
      if (fromIndex > 5) {
        return MoveSteps.invalid;
      } else {
        selectedSquare = rec;
        return MoveSteps.selected;
      }
    } else {
      if (fromIndex > 5) {
        selectedSquare = rec;
        return MoveSteps.selected;
      } else {
        return MoveSteps.invalid;
      }
    }
  }

  bool whiteToMove = true;
  bool firstMoveDone = false;

  bool haveAdjacentColumns((int row, int col) from, (int row, int col) to) {
    return from.$2 == to.$2 + 1 || from.$2 == to.$2 - 1;
  }

  bool twoColumnsAway((int row, int col) from, (int row, int col) to) {
    return from.$2 == to.$2 + 2 || from.$2 == to.$2 - 2;
  }

  bool haveAdjacentRanks((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1 + 1 || from.$1 == to.$1 - 1;
  }

  bool haveSameColumns((int row, int col) from, (int row, int col) to) {
    return from.$2 == to.$2;
  }

  bool haveSameRanks((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1;
  }

  bool hasOneRankAbove((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1 + 1;
  }

  bool hasOneRankBelow((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1 - 1;
  }

  bool hasTwoRanksAbove((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1 + 2;
  }

  bool hasTwoRanksBelow((int row, int col) from, (int row, int col) to) {
    return from.$1 == to.$1 - 2;
  }

  //
  bool canSelectForValidMoves((int i, int j) square) {
    return true; // TODO
  }

  bool isInCheck() {
    return false; // TODO
  }

  bool isAStaleMate() {
    return false; // TODO
  }

  bool isValidRookMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    if (haveSameColumns(from, to) || haveSameRanks(from, to)) {
      if (hasFreeRectPath(from, to)) {
        int fromIndex = squares[from.$1][from.$2];
        int toIndex = squares[to.$1][to.$2];
        if (toIndex == 100) {
          return true;
        } else {
          if (isWhitePiece(fromIndex) && !isWhitePiece(toIndex)) {
            return true;
          } else if (!isWhitePiece(fromIndex) && isWhitePiece(toIndex)) {
            return true;
          }
        }
        return false;
      }
    }
    return false;
  }

  bool isValidKnightMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    int fromIndex = squares[from.$1][from.$2];
    int toIndex = squares[to.$1][to.$2];
    if (hasTwoRanksAbove(from, to) && haveAdjacentColumns(from, to)) {
      if (toIndex == 100) {
        return true;
      }
      if (isWhitePiece(fromIndex) && !isWhitePiece(toIndex)) {
        return true;
      } else if (!isWhitePiece(fromIndex) && isWhitePiece(toIndex)) {
        return true;
      }
      return false;
    }
    if (hasTwoRanksBelow(from, to) && haveAdjacentColumns(from, to)) {
      if (toIndex == 100) {
        return true;
      }
      if (isWhitePiece(fromIndex) && !isWhitePiece(toIndex)) {
        return true;
      } else if (!isWhitePiece(fromIndex) && isWhitePiece(toIndex)) {
        return true;
      }
      return false;
    }
    if (hasOneRankBelow(from, to) && twoColumnsAway(from, to)) {
      if (toIndex == 100) {
        return true;
      }
      if (isWhitePiece(fromIndex) && !isWhitePiece(toIndex)) {
        return true;
      } else if (!isWhitePiece(fromIndex) && isWhitePiece(toIndex)) {
        return true;
      }
      return false;
    }
    if (hasOneRankAbove(from, to) && twoColumnsAway(from, to)) {
      if (toIndex == 100) {
        return true;
      }
      if (isWhitePiece(fromIndex) && !isWhitePiece(toIndex)) {
        return true;
      } else if (!isWhitePiece(fromIndex) && isWhitePiece(toIndex)) {
        return true;
      }
      return false;
    }
    return false;
  }

  bool isWhitePiece(int index) {
    return index < 6;
  }

  void resetHalfMoveCounts() {
    boardExternalState.halfMoveCount = 0;
  }

  void incrementMoveCounts() {
    boardExternalState.fullMoveCount++;
    boardExternalState.halfMoveCount++;
  }

  bool isValidPawnMove((int row, int col) from, (int row, int col) to,
      bool isWhiteToMove, bool prepareToMove, bool pawnAttackOnly) {
    int toIndex = squares[to.$1][to.$2];
    if (isWhiteToMove) {
      if (haveSameColumns(from, to)) {
        if (pawnAttackOnly) {
          return false;
        }
        if (hasTwoRanksBelow(from, to) && from.$1 == 1 && toIndex == 100) {
          if (hasFreeRectPath(from, to)) {
            resetHalfMoveCounts();
            return true;
          } else {
            return false;
          }
        }
        if (hasOneRankBelow(from, to) && toIndex == 100) {
          if (to.$1 == 7) {
            if (prepareToMove) {
              boardExternalState.whitePromotionSquare = to;
            }
            resetHalfMoveCounts();
            return true;
          }
          resetHalfMoveCounts();
          return true;
        }
        return false;
      }

      if (hasOneRankBelow(from, to) && haveAdjacentColumns(from, to)) {
        if (isValidEnpassant(from, to, isWhiteToMove, prepareToMove)) {
          resetHalfMoveCounts();
          return true;
        }

        if (to.$1 == 7 && toIndex > 5 && toIndex < 12) {
          if (prepareToMove) {
            boardExternalState.whitePromotionSquare = to;
          }
          resetHalfMoveCounts();
          return true;
        }
        if (toIndex > 5 && toIndex < 12) {
          resetHalfMoveCounts();
          return true;
        }
      }
      return false;
    } else {
      if (haveSameColumns(from, to)) {
        if (pawnAttackOnly) {
          return false;
        }
        if (hasTwoRanksAbove(from, to) && from.$1 == 6 && toIndex == 100) {
          if (hasFreeRectPath(from, to)) {
            resetHalfMoveCounts();
            return true;
          } else {
            return false;
          }
        }
        if (hasOneRankAbove(from, to) && toIndex == 100) {
          if (to.$1 == 0) {
            if (prepareToMove) {
              boardExternalState.blackPromotionSquare = to;
            }
            resetHalfMoveCounts();
            return true;
          }
          resetHalfMoveCounts();
          return true;
        }
        return false;
      }
      if (hasOneRankAbove(from, to) && haveAdjacentColumns(from, to)) {
        if (isValidEnpassant(from, to, isWhiteToMove, prepareToMove)) {
          resetHalfMoveCounts();
          return true;
        }

        if (to.$1 == 0 && toIndex < 6) {
          if (prepareToMove) {
            boardExternalState.blackPromotionSquare = to;
          }
          resetHalfMoveCounts();
          return true;
        }
        if (toIndex < 6) {
          resetHalfMoveCounts();
          return true;
        }
      }
      return false;
    }
  }

  bool isValidMove(
      (int row, int col) from,
      (int row, int col) to,
      bool isWhiteToMove,
      bool checkCastleMove,
      bool pawnAttackOnly,
      bool prepareToMove) {
    //if (null == selectedSquare) {
    //  return false;
    //}
    int fromIndex = squares[from.$1][from.$2];
    if (fromIndex == 100) {
      return false;
    }

    if (checkCastleMove && isValidCastleMove(from, to, isWhiteToMove)) {
      return true;
    }
    if (isWhiteToMove) {
      if (fromIndex > 5) {
        return false;
      }
    } else {
      if (fromIndex <= 5) {
        return false;
      }
    }
    int toIndex = squares[to.$1][to.$2];
    if (isWhiteToMove) {
      if (toIndex < 6) {
        return false;
      }
    } else {
      if (toIndex >= 6 && toIndex != 100) {
        return false;
      }
    }
    switch (fromIndex) {
      case 0:
        return isValidPawnMove(from, to, isWhiteToMove, true, pawnAttackOnly);
      case 1:
        return isValidRookMove(from, to, isWhiteToMove);
      case 2:
        return isValidKnightMove(from, to, isWhiteToMove);
      case 3:
        return isValidBishopMove(from, to, isWhiteToMove);
      case 4:
        return isValidQueenMove(from, to, isWhiteToMove);
      case 5:
        return isValidKingMove(from, to, isWhiteToMove);
      case 6:
        return isValidPawnMove(
            from, to, isWhiteToMove, prepareToMove, pawnAttackOnly);
      case 7:
        return isValidRookMove(from, to, isWhiteToMove);
      case 8:
        return isValidKnightMove(from, to, isWhiteToMove);
      case 9:
        return isValidBishopMove(from, to, isWhiteToMove);
      case 10:
        return isValidQueenMove(from, to, isWhiteToMove);
      case 11:
        return isValidKingMove(from, to, isWhiteToMove);

      default:
        return false; // TODO error
    }
  }

  bool isFreeDiagonalPath((int row, int col) from, (int row, int col) to) {
    int rowStart;
    int rowEnd;

    (int row, int col) from2;
    (int row, int col) to2;

    if (from.$1 < to.$1) {
      rowStart = from.$1;
      rowEnd = to.$1;
      from2 = (from.$1, from.$2);
      to2 = (to.$1, to.$2);
    } else {
      rowStart = to.$1;
      rowEnd = from.$1;
      from2 = (to.$1, to.$2);
      to2 = (from.$1, from.$2);
    }
    int colInc;
    if (from2.$2 < to2.$2) {
      colInc = 1;
    } else if (from2.$2 > to2.$2) {
      colInc = -1;
    } else {
      return false; // not diagonal or zero move
    }
    int diff = to2.$1 - from2.$1;
    if (from2.$2 + diff * colInc != to2.$2) {
      return false;
    }

    for (int i = rowStart + 1; i < rowEnd; i++) {
      if (squares[i][from2.$2 + colInc * (i - rowStart)] != 100) {
        return false;
      }
    }
    return true;
  }

  bool hasFreeRectPath((int row, int col) from, (int row, int col) to) {
    if (from.$1 == to.$1) {
      if (to.$2 == from.$2) {
        return true;
      }

      int start;
      int end;
      if (from.$2 < to.$2) {
        start = from.$2;
        end = to.$2;
      } else {
        end = from.$2;
        start = to.$2;
      }
      for (int i = start + 1; i < end; i++) {
        if (squares[from.$1][i] != 100) {
          return false;
        }
      }
      return true;
    } else if (from.$2 == to.$2) {
      if (to.$1 == from.$1) {
        return true;
      }

      int start;
      int end;
      if (from.$1 < to.$1) {
        start = from.$1;
        end = to.$1;
      } else {
        end = from.$1;
        start = to.$1;
      }
      for (int i = start + 1; i < end; i++) {
        if (squares[i][from.$2] != 100) {
          return false;
        }
      }
      return true;
    } else {
      // Error Condition TODO throw;
      return false;
    }
  }

  bool isValidBishopMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    int toIndex = squares[to.$1][to.$2];
    if (isWhiteToMove && toIndex < 6) {
      return false;
    } else if (!isWhiteToMove && toIndex > 5 && toIndex < 12) {
      return false;
    }
    return isFreeDiagonalPath(from, to);
  }

  bool isValidQueenMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    if (isValidBishopMove(from, to, isWhiteToMove)) {
      return true;
    }
    if (isValidRookMove(from, to, isWhiteToMove)) {
      return true;
    }
    return false;
  }

  (int row, int col)? getKingSquare(bool whiteKing) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (whiteKing && squares[row][col] == 5) {
          return (row, col);
        } else if (!whiteKing && squares[row][col] == 11) {
          return (row, col);
        }
      }
    }
    return null; // error
  }

  // is the to" square under attack to prevent king move
  bool isKingUnderAttack(bool whiteKing) {
    (int, int)? kingSquare = getKingSquare(whiteKing);
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (isValidMove(
            (row, col), kingSquare!, !whiteKing, false, true, false)) {
          print(whiteKing ? "white king " : "black king ");
          print(
              " under attack from ${row}, ${col} to ${kingSquare.$1}, ${kingSquare.$2} ");
          return true;
        }
      }
    }

    return false;
  }

  // is the to" square under attack to prevent king move
  bool isSquareUnderAttack((int row, int col) to, bool isWhiteToMove) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int attackerIndex = squares[row][col];

        if (isWhiteToMove && isWhitePiece(attackerIndex)) {
          bool attacked =
              isValidMove((row, col), to, isWhiteToMove, false, true, false);
          if (attacked) {
            return true;
          }
        } else if (!isWhiteToMove && !isWhitePiece(attackerIndex)) {
          bool attacked =
              isValidMove((row, col), to, isWhiteToMove, false, true, false);
          if (attacked) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int castleDetected = -1;

  bool isKingInSquare((int row, int col) rec) {
    if (squares[rec.$1][rec.$2] == 5 || squares[rec.$1][rec.$2] == 11) {
      return true;
    }
    return false;
  }

  bool isValidCastleMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    if (isWhiteToMove) {
      if (boardExternalState.whiteKingMoved) {
        return false;
      }
      if (to.$1 == 0 && to.$2 == 0) {
        if (boardExternalState.rook00Moved) {
          return false;
        }
        if (squares[0][1] != 100 ||
            squares[0][2] != 100 ||
            squares[0][3] != 100) {
          return false; // blocking pieces
        }
        if (isSquareUnderAttack((0, 4), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((0, 3), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((0, 2), !isWhiteToMove)) {
          return false;
        }
        castleDetected = 0;

        return true;
      }
      if (to.$1 == 0 && to.$2 == 7) {
        if (boardExternalState.rook07Moved) {
          return false;
        }
        if (squares[0][5] != 100 || squares[0][6] != 100) {
          return false; // blocking pieces
        }
        if (isSquareUnderAttack((0, 4), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((0, 5), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((0, 6), !isWhiteToMove)) {
          return false;
        }
        castleDetected = 7;
        return true;
      }
    }
    if (!isWhiteToMove) {
      if (boardExternalState.blackKingMoved) {
        return false;
      }
      if (to.$1 == 7 && to.$2 == 0) {
        if (boardExternalState.rook00Moved) {
          return false;
        }
        if (squares[7][1] != 100 ||
            squares[7][2] != 100 ||
            squares[7][3] != 100) {
          return false;
        }
        if (isSquareUnderAttack((7, 4), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((7, 3), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((7, 2), !isWhiteToMove)) {
          return false;
        }
        castleDetected = 70;
        return true;
      }
      if (to.$1 == 7 && to.$2 == 7) {
        if (boardExternalState.rook77Moved) {
          return false;
        }
        if (squares[7][5] != 100 || squares[7][6] != 100) {
          return false;
        }
        if (isSquareUnderAttack((7, 4), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((7, 5), !isWhiteToMove)) {
          return false;
        }
        if (isSquareUnderAttack((7, 6), !isWhiteToMove)) {
          return false;
        }
        castleDetected = 77;
        return true;
      }
      return false;
    }
    return false;
  }

  bool isValidKingMove(
      (int row, int col) from, (int row, int col) to, bool isWhiteToMove) {
    int toIndex = squares[to.$1][to.$2];
    if (isWhiteToMove && toIndex < 6) {
      return false;
    } else if (!isWhiteToMove && toIndex > 5 && toIndex < 12) {
      return false;
    }
    int rowDiff = from.$1 - to.$1;

    if (!(-1 <= rowDiff && rowDiff <= 1)) {
      return false;
    }
    int colDiff = from.$2 - to.$2;

    if (!(-1 <= colDiff && colDiff <= 1)) {
      return false;
    }
    return true;
  }

  (int i, int j)? enpassantSquare;
  bool isValidEnpassant((int row, int col) from, (int row, int col) to,
      bool isWhiteToMove, bool prepareToMove) {
    if (moveHistory.length < 2) {
      return false;
    }
    if (isWhiteToMove && from.$1 == 4) {
      String lastMove = moveHistory.last;
      List<String> tokens = lastMove.split(" ");
      if (tokens[0] == "6" &&
          tokens[1] == "6" &&
          (tokens[2] == (to.$2).toString())) {
        if (prepareToMove) {
          enpassantSquare = (from.$1, to.$2);
        }
        return true;
      } else {
        return false;
      }
    } else if (!isWhiteToMove && from.$1 == 3) {
      String lastMove = moveHistory.last;
      List<String> tokens = lastMove.split(" ");
      if (tokens[0] == "0" &&
          tokens[1] == "1" &&
          (tokens[2] == (to.$2).toString())) {
        if (prepareToMove) {
          enpassantSquare = (from.$1, to.$2);
        }
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void doCastle() {
    if (castleDetected == 0) {
      squares[0][4] = 100;
      squares[0][2] = 5;
      squares[0][3] = 1;
      squares[0][0] = 100;
      castleDetected = -1;
      boardExternalState.whiteKingMoved = true;
      boardExternalState.rook00Moved = true;
      return;
    }
    if (castleDetected == 7) {
      squares[0][4] = 100;
      squares[0][6] = 5;
      squares[0][5] = 1;
      squares[0][7] = 100;
      castleDetected = -1;
      boardExternalState.whiteKingMoved = true;
      boardExternalState.rook07Moved = true;
      return;
    }
    if (castleDetected == 70) {
      squares[7][4] = 100;
      squares[7][2] = 11;
      squares[7][3] = 7;
      squares[7][0] = 100;
      castleDetected = -1;
      boardExternalState.blackKingMoved = true;
      boardExternalState.rook70Moved = true;
      return;
    }
    if (castleDetected == 77) {
      squares[7][4] = 100;
      squares[7][6] = 11;
      squares[7][5] = 7;
      squares[7][7] = 100;
      castleDetected = -1;
      boardExternalState.blackKingMoved = true;
      boardExternalState.rook77Moved = true;
      return;
    }
  }

  bool promotePawnTo(int toIndex) {
    if (null != boardExternalState.whitePromotionSquare) {
      if (toIndex >= 1 && toIndex <= 4) {
        squares[boardExternalState.whitePromotionSquare!.$1]
            [boardExternalState.whitePromotionSquare!.$2] = toIndex;
        boardExternalState.whitePromotionSquare = null;
        return true;
      }
      return false;
    } else if (null != boardExternalState.blackPromotionSquare) {
      if (toIndex >= 7 && toIndex <= 10) {
        squares[boardExternalState.blackPromotionSquare!.$1]
            [boardExternalState.blackPromotionSquare!.$2] = toIndex;
        boardExternalState.blackPromotionSquare = null;
        return true;
      }
      return false;
    }
    return false;
  }

  void makePrevalidatedMove((int row, int col) from, (int row, int col) to) {
    if (castleDetected != -1) {
      doCastle();
      selectedSquare = null;
      whiteToMove = !whiteToMove;
      incrementMoveCounts();
      return;
    }
    String move =
        "${squares[from.$1][from.$2]} ${from.$1} ${from.$2} ${to.$1} ${to.$2}";
    print(move);
    moveHistory.add(move);
    int fromIndex = squares[from.$1][from.$2];
    int toIndex = squares[to.$1][to.$2];
    if (toIndex != 100) {
      resetHalfMoveCounts(); // reset on capture
    }
    squares[from.$1][from.$2] = 100;

    squares[to.$1][to.$2] = fromIndex;
    if (null != enpassantSquare) {
      squares[enpassantSquare!.$1][enpassantSquare!.$2] = 100;
      enpassantSquare = null;
    }
    selectedSquare = null;
    whiteToMove = !whiteToMove;

    if (fromIndex == 5) {
      boardExternalState.whiteKingMoved = true;
    } else if (fromIndex == 11) {
      boardExternalState.blackKingMoved = true;
    }
    if (fromIndex == 1) {
      if (from.$1 == 0 && from.$2 == 0) {
        boardExternalState.rook00Moved = true;
      }
      if (from.$1 == 0 && from.$2 == 7) {
        boardExternalState.rook07Moved = true;
      }
    } else if (fromIndex == 7) {
      if (from.$1 == 7 && from.$2 == 0) {
        boardExternalState.rook70Moved = true;
      }
      if (from.$1 == 7 && from.$2 == 7) {
        boardExternalState.rook77Moved = true;
      }
    }
    incrementMoveCounts();
  }

  ChessBoard() {
    squares[0][0] = 1;
    squares[0][1] = 2;
    squares[0][2] = 3;
    squares[0][3] = 4;
    squares[0][4] = 5;
    squares[0][5] = 3;
    squares[0][6] = 2;
    squares[0][7] = 1;

    squares[1][0] = 0;
    squares[1][1] = 0;
    squares[1][2] = 0;
    squares[1][3] = 0;
    squares[1][4] = 0;
    squares[1][5] = 0;
    squares[1][6] = 0;
    squares[1][7] = 0;

    squares[6][0] = 6;
    squares[6][1] = 6;
    squares[6][2] = 6;
    squares[6][3] = 6;
    squares[6][4] = 6;
    squares[6][5] = 6;
    squares[6][6] = 6;
    squares[6][7] = 6;

    squares[7][0] = 7;
    squares[7][1] = 8;
    squares[7][2] = 9;
    squares[7][3] = 10;
    squares[7][4] = 11;
    squares[7][5] = 9;
    squares[7][6] = 8;
    squares[7][7] = 7;
  }
}

class Piece {
  String name;

  String iconName;

  Piece(this.name, this.iconName);
}

class Pieces {
  static List<Piece> pieces = List.empty(growable: true);
  static bool initialized = false;
  static List<Piece> initialize() {
    if (initialized) {
      return pieces;
    }
    pieces.add(Piece("White Pawn", "assets/white-pawn.png"));

    pieces.add(Piece("White Rook", "assets/white-rook.png"));
    pieces.add(Piece("White Knight", "assets/white-knight.png"));
    pieces.add(Piece("White Bishop", "assets/white-bishop.png"));
    pieces.add(Piece("White Queen", "assets/white-queen.png"));
    pieces.add(Piece("White King", "assets/white-king.png"));

    pieces.add(Piece("Black Pawn", "assets/black-pawn.png"));

    pieces.add(Piece("Black Rook", "assets/black-rook.png"));
    pieces.add(Piece("Black Knight", "assets/black-knight.png"));
    pieces.add(Piece("Black Bishop", "assets/black-bishop.png"));
    pieces.add(Piece("Black Queen", "assets/black-queen.png"));
    pieces.add(Piece("Black King", "assets/black-king.png"));

    return pieces;
  }

  static bool isWhite(int index) {
    if (index < 6) {
      return true;
    } else {
      return false;
    }
  }
}
