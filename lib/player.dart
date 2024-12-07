import 'dart:async';
import 'package:chess/src/com/uci/api/move.dart';
import 'package:json_annotation/json_annotation.dart';

import 'human_player.dart';
import 'uci_client.dart';
part 'player.g.dart';

@JsonSerializable()
class Player {
  late String name;
  late bool playingWhite;
  late bool isTurn;
  String type;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late StreamController<Move> _controller;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late bool streamClosed = false;

  void addData(Move data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    } else {
      // TODO
    }
  }

  void close() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  Stream<Move> get stream => _controller.stream;

  Player(this.type, this.name, this.playingWhite, this.isTurn) {
    _controller = StreamController<Move>();
  }

  void resetStreamIfClosed() {
    if (_controller.isClosed) {
      _controller = StreamController<Move>();
    }
  }

  void selectSquare((int row, int col) rec) {}

// generate two records and a promotion piece if applicable.
  void play() {}

  void saveGame() {}

  factory Player.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'Humanplayer':
        return Humanplayer.fromJson(json);
      case 'UCIClient':
        return UCIClient.fromJson(json); // UCIClient.fromJson(json);
      default:
        throw Exception('Unknown type');
    }
  }
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
//_$PlayerFromJson
}
