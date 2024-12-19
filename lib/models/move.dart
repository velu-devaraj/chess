import 'dart:core';
import 'package:json_annotation/json_annotation.dart';


part '../move.g.dart'; 

@JsonSerializable(explicitToJson: true)
class Move {
  late int playerIndex;
//   @JsonKey(includeFromJson: false, includeToJson: false)
  late (int row, int col) square;
  int promotoinPiece = -1;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool selected = false;


  Move(){}


  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);
  Map<String, dynamic> toJson() => _$MoveToJson(this);


}