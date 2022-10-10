// ignore_for_file: sized_box_for_whitespace, use_key_in_widget_constructors

import 'dart:math';

import 'package:flutter/material.dart';

class MarioWalk extends StatelessWidget {
  final isMarioRun;
  final direction;
  final isMushroomEaten;
  const MarioWalk({this.isMarioRun, this.direction, this.isMushroomEaten});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(direction == "left" ? pi : 0),
      child: Container(
        width: 50 * (isMushroomEaten ? 1.5 : 1),
        height: 50 * (isMushroomEaten ? 1.5 : 1),
        child: isMarioRun
            ? Image.asset("assets/mariowalk.png")
            : Image.asset("assets/mariostand.png"),
      ),
    );
  }
}
