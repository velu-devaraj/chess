
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

import 'player.dart';
import 'move.dart';

part '../game.g.dart'; 

@JsonSerializable(explicitToJson: true)
class Game{
  final Player player1;
  final Player player2;
  late DateTime dateTime;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool _selected = false;

  bool get selected => _selected;

  set selected(bool value) {
    _selected = value;
  }

  late String startFen;
  late String fen;

  List<Move> moves = List.empty(growable: true);

  Game(this.player1,this.player2,this.fen){dateTime = DateTime.now(); startFen = fen;} 


  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  String getKey(){
    return "Game:${player1.name}|${player2.name}|$dateTime";
  }

}

