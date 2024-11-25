import 'package:flutter/material.dart';

class ButtonStyles{
    static ButtonStyle style = ElevatedButton.styleFrom(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontSize: 20),
      shape: const LinearBorder(
        side: BorderSide(color: Colors.blue),
        top: LinearBorderEdge(),
        bottom: LinearBorderEdge(),
        start: LinearBorderEdge(),
        end: LinearBorderEdge(),
      ),
      fixedSize: const Size(200, 60));
}