import 'package:chess/models/app_data_store.dart';
import 'package:chess/models/server_config.dart';
import 'package:flutter/material.dart';

import 'game_router.dart';
import 'widgets/main_page.dart';
import 'piece_images.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    WidgetsFlutterBinding.ensureInitialized();
    ServerConfig sc;
    AppDataStore appDataStore = AppDataStore.getInstance();
    appDataStore.loadJsonData().then((onValue) {
      sc = onValue;
    });
    Pieceimages pis = Pieceimages();

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
