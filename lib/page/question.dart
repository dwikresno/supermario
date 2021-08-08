import 'package:flutter/material.dart';

class QuestionStone extends StatelessWidget {
  const QuestionStone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      child: Image.asset("assets/question.png"),
    );
  }
}
