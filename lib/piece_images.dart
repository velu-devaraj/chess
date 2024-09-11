import "dart:async";
import "dart:ui" as ui;
import 'package:image/image.dart' as img;

import "chess_board.dart";
import 'package:flutter/services.dart';

class Pieceimages {
  static List<ui.Image?> images = List.empty(growable: true);
  static bool initialized = false;

  List<ui.Image?> loadImages() {
    if (initialized) {
      return images;
    }
    List<Piece> pieces = Pieces.initialize();
    loadScaledImageAssets(pieces).then((onValue) {
      return;
    });

    initialized = true;
    return images;
  }

  Future<void> loadImageAssets(List<Piece> pieces) async {
    for (Piece p in pieces) {
      final data = await rootBundle.load(p.iconName);
      Completer<ui.Image> completer = Completer<ui.Image>();
      ui.Image imgClone;
      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image image2) {
        completer.complete(image2);
        imgClone = image2.clone();
        images.add(imgClone);
      });
    }
  }

  Future<void> loadScaledImageAssets(List<Piece> pieces) async {
   
    for (Piece p in pieces) {
      final data = await rootBundle.load(p.iconName);

      ui.Image imgClone;
      img.Image? originalImage = img.decodeImage(data.buffer.asUint8List());

      img.Image? fittingImage =
          img.copyResize(originalImage!, width: 40, height: 40);

      final Uint8List resizedBytes = img.encodePng(fittingImage);
      final Completer<ui.Image> completer = Completer();

      ui.decodeImageFromList(resizedBytes, (ui.Image image2) {
        completer.complete(image2);
        imgClone = image2.clone();
        images.add(imgClone);

      });
    }
  }
}
