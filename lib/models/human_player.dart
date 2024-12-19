import 'player.dart';
import 'package:json_annotation/json_annotation.dart';

part '../human_player.g.dart';

@JsonSerializable()
class Humanplayer extends Player {
  Humanplayer(type, name, playingWhite, isTurn, index)
      : super(type, name, playingWhite, isTurn, index);

  @override
  void saveGame() {
    // TODO: implement saveGame
  }

  @override
  void selectSquare((int, int) rec) {
    //sendPort.send(rec);
  }

  @override
  void play() {
    // TODO: implement play
  }

  factory Humanplayer.fromJson(Map<String, dynamic> json) =>
      _$HumanplayerFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$HumanplayerToJson(this);
}
