// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      json['player1'] as String,
      json['player2'] as String,
      json['fen'] as String,
    )..dateTime = DateTime.parse(json['dateTime'] as String);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'dateTime': instance.dateTime.toIso8601String(),
      'fen': instance.fen,
    };
