import 'package:flutter/material.dart';

class Coin extends StatelessWidget {
  const Coin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      child: Image.asset("assets/coin.png"),
    );
  }
}
