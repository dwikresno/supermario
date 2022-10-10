// ignore_for_file: prefer_typing_uninitialized_variables, sized_box_for_whitespace, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class Enemy extends StatelessWidget {
  final isEnemyRun;
  const Enemy({this.isEnemyRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      child: isEnemyRun
          ? Image.asset("assets/enemy1.png")
          : Image.asset("assets/enemy2.png"),
    );
  }
}
