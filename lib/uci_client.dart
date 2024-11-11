import 'package:chess/chess_board.dart';

import 'player.dart';

import 'package:json_annotation/json_annotation.dart';

import 'src/api.dart';
import 'src/com/uci/api/command_response.dart';
import 'src/com/uci/api/move.dart';
import 'src/com/uci/api/moves_api.dart';
import 'src/com/uci/api/command.dart';
import 'package:dio/dio.dart';
part 'uci_client.g.dart';

@JsonSerializable()
class UCIClient extends Player {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late MovesApi movesApi;

  UCIClient(type, name, playingWhite, isTurn)
      : super(type, name, playingWhite, isTurn) {
    BaseOptions? bo =
        BaseOptions(baseUrl: 'http://localhost:8080/uci-api-0.0.1-SNAPSHOT');
    movesApi = Openapi(dio: Dio(bo)).getMovesApi();

    CommandBuilder commandInstance = CommandBuilder();

//commandInstance.commandString = ListBuilder<String>();
    commandInstance.commandString
        .addAll(["uci", "position startpos moves e2e4 e7e5", "go depth 5"]);
  }

  @override
  void selectSquare((int, int) rec) {
    Command command;

    //  sendPort.send(rec);
  }

  void saveGame() {}

  @JsonKey(includeFromJson: false, includeToJson: false)
  late String currentFen;
  void setFEN(String fen) {
    this.currentFen = fen;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  late ChessBoard chessBoard;
  void setChessBoard(ChessBoard chessBoard) {
    this.chessBoard = chessBoard;
  }

  @override
  void play() {
    CommandBuilder commandInstance = CommandBuilder();

    commandInstance.commandString
        .addAll(["uci", "position fen " + currentFen, "go depth 5"]);

    Command command = commandInstance.build();

    movesApi.execute(command: command).then((value) {
      Response<CommandResponse> res = value;
      print(res);

      List<Move> moves = findBestMove(res.data!);

      addData(moves[0]);

      addData(moves[1]);
    });
  }

  int letterToColumn(String colCode) {
    switch (colCode) {
      case "a":
      case "A":
        return 1;
      case "b":
      case "B":
        return 2;
      case "c":
      case "C":
        return 3;
      case "d":
      case "D":
        return 4;
      case "e":
      case "E":
        return 5;
      case "f":
      case "F":
        return 6;
      case "g":
      case "G":
        return 7;
      case "h":
      case "H":
        return 8;
    }

    return -1;
  }

  List<Move> findBestMove(CommandResponse cr) {
    Iterator<String> it = cr.engineResult!.iterator;
    Move move1 = Move();
    Move move2 = Move();
    List<Move> moves = [move1, move2];
    while (it.moveNext()) {
      String outputLine = it.current;
      if (outputLine.startsWith("bestmove")) {
        List<String> splits = outputLine.split(" ");
        int row = int.parse(splits[1][1]) - 1;
        int col = letterToColumn(splits[1][0]) - 1;

        move1.square = (row, col);
        row = int.parse(splits[1][3]) - 1;
        col = letterToColumn(splits[1][2]) - 1;

        // castle target square for king is adjusted
        // from engine outputs
        if (chessBoard.isKingInSquare(move1.square) &&
            chessBoard.twoColumnsAway(move1.square, (row, col))) {
          if (col == 1) {
            col = 0;
          } else if (col == 6) {
            col = 7;
          }
        }
        move2.square = (row, col);

        return moves;
      }
    }
    return moves;
  }

/*
  Future<List<Move>> findMove() async {
    CommandBuilder commandInstance = CommandBuilder();

//commandInstance.commandString = ListBuilder<String>();
    commandInstance.commandString
        .addAll(["uci", "position fen " + currentFen, "go depth 5"]);

    Command command = commandInstance.build();

    await movesApi.execute(command: command).then((value) {
      Response<CommandResponse> res = value;
      print(res);
    });

    movesApi.execute(command: command);

    Move move1 = Move();
    Move move2 = Move();

    List<Move> moves = [move1, move2];
    return moves;
  }

  */

  factory UCIClient.fromJson(Map<String, dynamic> json) =>
      _$UCIClientFromJson(json);
  Map<String, dynamic> toJson() => _$UCIClientToJson(this);
}
