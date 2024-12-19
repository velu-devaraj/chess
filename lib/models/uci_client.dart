import 'package:chess/models/chess_board.dart';
import 'package:chess/models/server_config.dart';

import 'player.dart';
import 'move.dart';
import 'package:json_annotation/json_annotation.dart';

import '../src/api.dart';
import 'app_data_store.dart';
import '../src/com/uci/api/command_response.dart';
//import 'src/com/uci/api/move.dart.bak';
import '../src/com/uci/api/moves_api.dart';
import '../src/com/uci/api/command.dart';
import 'package:dio/dio.dart';
part 'uci_client.g.dart';

@JsonSerializable()
class UCIClient extends Player {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late MovesApi movesApi;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool initialized = false;

  UCIClient(type, name, playingWhite, isTurn, index)
      : super(type, name, playingWhite, isTurn, index) {
        initialize();
      }

  void initialize() {
    ServerConfig? serverConfig = AppDataStore.getInstance().serverConfig;

    if (null != serverConfig) {
      String scheme =
          serverConfig!.properties[PropertyKeys.uciServerScheme]!.value![0];
      String port =
          serverConfig!.properties[PropertyKeys.uciServerPort]!.value![0];
      String host =
          serverConfig!.properties[PropertyKeys.uciServerHost]!.value![0];
      String basePath =
          serverConfig!.properties[PropertyKeys.uciServerBasePath]!.value![0];

      String engineURL = scheme + "://" + host + ":" + port + "/" + basePath;
      BaseOptions? bo = BaseOptions(baseUrl: engineURL);
      movesApi = Openapi(dio: Dio(bo)).getMovesApi();
      initialized = true;
    }
  }

  @override
  void selectSquare((int, int) rec) {
    Command command;
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
    if(!initialized){
      initialize();
    }
    ServerConfig? serverConfig = AppDataStore.getInstance().serverConfig;

    String maxDepth = serverConfig!.getPropertyAsString(PropertyKeys.maxDepth);
    int moveDelay = serverConfig!.getPropertyAsInt(PropertyKeys.moveDelay);
    int selectionToMoveDelay =
        serverConfig!.getPropertyAsInt(PropertyKeys.selectionToMoveDelay);

    CommandBuilder commandInstance = CommandBuilder();

    commandInstance.commandString
        .addAll(["uci", "position fen " + currentFen, "go depth " + maxDepth]);

    Command command = commandInstance.build();

    movesApi.execute(command: command).then((value) {
      Response<CommandResponse> res = value;
      print(res);

      List<Move> moves = findBestMove(res.data!);

      Future.delayed(Duration(milliseconds: moveDelay), () {
        // provide a delay for selection
        addData(moves[0]);
        Future.delayed(Duration(milliseconds: selectionToMoveDelay), () {
          // provide a delay between selection and move.
          addData(moves[1]);
        });
      });

      //  addData(moves[1]);
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
        move1.playerIndex = index;
 //       move1.promotoinPiece = -1;
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
        move2.playerIndex = index;
 //       move2.promotoinPiece = -1;
        return moves;
      }
    }
    return moves;
  }

  factory UCIClient.fromJson(Map<String, dynamic> json) =>
      _$UCIClientFromJson(json);
  Map<String, dynamic> toJson() => _$UCIClientToJson(this);
}
