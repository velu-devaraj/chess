import 'package:chess/src/app_data_store.dart';
import 'package:chess/src/lookups.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../move.dart';
import '../game_page.dart';

class MovesListWidget extends StatefulWidget {
  MovesListWidget({super.key}) {
    movesListWidgetKey = key as GlobalKey;
  }

  @override
  State<StatefulWidget> createState() {
    MovesListWidgetState mlws = MovesListWidgetState();
    return mlws;
  }
}

class MovesListWidgetState extends State<StatefulWidget> {
  Game? getGame() {
    Game? g = AppDataStore.getInstance().currentGame;
    return g;
  }

  MovesListWidgetState() {}

  int selectedIndex = -1;

// TODO
  void selectSingleMove(int index) {
    Game? game = getGame();

    bool selected = false;
    for (int i = 0; i < game!.moves!.length; i++) {}
  }

  List<String> getRowValues(List<Move> moves, int rowIndex, int cellsPerRow) {
    List<String> values = List.filled(cellsPerRow, "");

    for (int i = 0; i < cellsPerRow; i++) {
      if (rowIndex + 1 >= moves.length) {
        break;
      }
      String fullMove = Lookups.columnCode[moves[rowIndex].square.$2] +
          (moves[rowIndex].square.$1 + 1).toString() +
          Lookups.columnCode[moves[rowIndex + 1].square.$2] +
          (moves[rowIndex + 1].square.$1 + 1).toString();
      values[i] = fullMove;
      rowIndex += 2;
    }
    return values;
  }

  List<DataCell> getRowCells(List<String> rowValues) {
    List<DataCell> dataCells = List.empty(growable: true);

    for (int i = 0; i < rowValues.length; i++) {
      DataCell dataCell = DataCell(
        SizedBox(
          height: 25,
          child: Text(rowValues[i]),
        ),
      );

      dataCells.add(dataCell);
    }

    return dataCells;
  }

  DataTable movesWidget() {
    List<DataRow> rows = List.empty(growable: true);

    List<DataColumn> cols = [
      DataColumn(label: Text("Player 1")),
      DataColumn(label: Text("Player 2")),
    ];

    if (!AppDataStore.getInstance().gamesList.gamesListLoaded) {
      DataTable table = DataTable(columns: cols, rows: rows);

      return table;
    }

    ChessPage cp = chessPageKey?.currentWidget as ChessPage;

    Game game = cp.game;
    int fullMoveCount = game!.moves!.length - game!.moves!.length % 2;

    int cellsPerRow = 2;
    for (int i = 0; i < fullMoveCount; i += cellsPerRow) {
      List<String> rowValues = this.getRowValues(game.moves, i, cellsPerRow);

      DataRow row = DataRow(
          key: UniqueKey(),
          color: WidgetStateColor.resolveWith((states) {
            return Colors.amberAccent;
          }),
          cells: this.getRowCells(rowValues));

      rows.add(row);
    }

    DataTable table = DataTable(
      showCheckboxColumn: true,
      columns: cols,
      rows: rows,
      headingRowColor:
          WidgetStateColor.resolveWith((states) => Colors.amberAccent.shade100),
      dataRowColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return Colors.lightBlue; // Use the default value.
      }),
    );

    return table;
  }

  @override
  Widget build(BuildContext context) {
    return movesWidget();
  }
}
