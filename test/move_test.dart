
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/move.dart';

void main() {
  Move m = Move();
  m.square = (4,5);

  m.playerIndex = 1;
  m.promotoinPiece = 5;
  m.selected = true;


  var map =  m.toJson();

  print(map);

  Move mv = Move.fromJson(map);

  print(mv);

  expect(1, mv.playerIndex);
  expect(5, mv.promotoinPiece);

}