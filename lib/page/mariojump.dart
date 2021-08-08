import 'dart:math';

import 'package:flutter/material.dart';

class MarioJump extends StatelessWidget {
  final direction;
  final isMushroomEaten;
  const MarioJump({this.direction, this.isMushroomEaten});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(direction == "left" ? pi : 0),
      child: Container(
        width: 50 * (isMushroomEaten ? 1.5 : 1),
        height: 50 * (isMushroomEaten ? 1.5 : 1),
        child: Image.asset("assets/mariojump.png"),
      ),
    );
  }
}
