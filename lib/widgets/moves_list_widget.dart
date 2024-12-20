import 'package:chess/models/app_data_store.dart';
import 'package:chess/models/lookups.dart';
import 'package:flutter/material.dart';

import '../models/app_state_data.dart';
import '../models/game.dart';
import '../models/move.dart';
import 'game_page.dart';
import 'widget_keys.dart';

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
      values[i] =  fullMove;
      rowIndex += 2;
    }
    return values;
  }

  List<DataCell> getRowCells(List<String> rowValues) {
    List<DataCell> dataCells = List.empty(growable: true);

    for (int i = 0; i < rowValues.length; i++) {
      DataCell dataCell = DataCell(
        Container(
          height: 25,
           width: 35,
          child: Text(textWidthBasis: TextWidthBasis.longestLine, rowValues[i]),
        ),
      );

      dataCells.add(dataCell);
    }

    return dataCells;
  }

  DataTable movesWidget() {
    List<DataRow> rows = List.empty(growable: true);
    int cellsPerRow = 6;
    List<DataColumn> cols = List.filled(cellsPerRow,  DataColumn(label: Text("")));

    /*
    [
      DataColumn(label: Text("1")),
      DataColumn(label: Text("2")),
      DataColumn(label: Text("1")),
      DataColumn(label: Text("2")),
      DataColumn(label: Text("1")),
      DataColumn(label: Text("2")),

      //   DataColumn(label: Text("moves")),
    ];
*/
    if (!AppDataStore.getInstance().gamesList.gamesListLoaded) {
      //DataTable table = DataTable(columns: cols, rows: rows);
      DataTable table = DataTable(columns: cols, rows: rows);

      return table;
    }

    //   ChessPage cp = chessPageKey?.currentWidget as ChessPage;

    //  Game game = cp.game;
    Game? game = AppStateData.getInstance().currentGame;

    int fullMoveCount = game!.moves!.length - game!.moves!.length % 2;

    for (int i = 0; i < fullMoveCount; i += cellsPerRow * 2) {
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
      headingRowHeight: 0,
      columnSpacing: 15, // to adjust column width and table width
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
