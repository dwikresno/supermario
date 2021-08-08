import 'package:flutter/material.dart';

class Mushroom extends StatelessWidget {
  const Mushroom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      child: Image.asset("assets/mushroom.gif"),
    );
  }
}
