import 'package:flutter/material.dart';

import 'game_router.dart';
import 'main_page.dart';
import 'piece_images.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Pieceimages pis = Pieceimages();
    WidgetsFlutterBinding.ensureInitialized();
    pis.loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: MainWidget()),
      onGenerateRoute: GameRouter.generateRoute,
    );
  }
}
