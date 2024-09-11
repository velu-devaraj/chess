
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart'; 

@JsonSerializable()
class Game{
  final String player1;
  final String player2;
  late DateTime dateTime;

  late String fen;

  Game(this.player1,this.player2,this.fen){dateTime = DateTime.now();} 


  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  String getKey(){
    return "${player1}|${player1}|$dateTime";
  }

}

