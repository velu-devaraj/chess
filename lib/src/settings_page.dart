import 'package:chess/src/server_config.dart';
import 'package:flutter/material.dart';

import 'app_data_store.dart';
import 'button_styles.dart';

GlobalKey? settingsPageKey;

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key}) {
    settingsPageKey = key as GlobalKey;
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ServerConfig? serverConfig;

  @override
  Widget build(BuildContext context) {
    serverConfig = AppDataStore.getInstance().serverConfig;
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Expanded(child: preferencesTable(serverConfig!))),
            ),
            
        Padding(
            padding: EdgeInsets.fromLTRB(0,5,0,5),

          child:  ElevatedButton(
              style: ButtonStyles.style,
              onPressed: () {
                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: Text('Home'),
            )
        ),
            Flexible(
              child: Container(color: Colors.transparent),
            )
          ],
        ));
  }

  DataTable preferencesTable(ServerConfig serverConfig) {
    List<DataRow> rows = List.empty(growable: true);

    List<DataColumn> cols = [
      DataColumn(label: Text("Setting")),
      DataColumn(label: Text("Value")),
    ];

    //rows.add(row);

    DataTable table = DataTable(columns: cols, rows: rows);

    for (String propertyKey in serverConfig.propertyKeys) {
      String value = "";
      if (serverConfig.properties.containsKey(propertyKey)) {
        List<String>? values = serverConfig.properties[propertyKey]!.value;
        value = values![0];
      }

      DataRow row = DataRow(
          key: UniqueKey(),
          color: WidgetStateColor.resolveWith((states) {
            return Colors.blue;
          }),
          cells: [
            DataCell(Text(key: UniqueKey(), propertyKey), onDoubleTap: () {}),
            // DataCell(Text(value), onDoubleTap: () {})
            DataCell(_buildEditableCell(serverConfig.properties, propertyKey))
          ]);

      rows.add(row);
    }

    return table;
  }

  Widget _buildEditableCell(Map<String, dynamic> item, String column) {
    String value = "";
    if (item.containsKey(column)) {
      List<String>? values = item[column]!.value;
      value = values![0];
    } else {
      item[column] = Property();
      item[column]!.value = List<String>.empty(growable: true);
      item[column]!.value.add("");
    }
    AppDataStore appDataStore = AppDataStore.getInstance();
    return TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(border: InputBorder.none),
        onSubmitted: (newValue) {
          setState(() {
            item[column].value[0] = newValue;
            appDataStore.storeObject(serverConfig);
          });
        });
  }
}
