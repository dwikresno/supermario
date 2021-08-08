import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supermario/page/coin.dart';
import 'package:supermario/page/mariojump.dart';
import 'package:supermario/page/mariowalk.dart';
import 'package:supermario/page/mushroom.dart';
import 'package:supermario/page/question.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double marioX = -1;
  static double marioY = 1;
  bool isLeftTap = false;
  bool isRightTap = false;
  bool isMarioRun = false;
  var direction = "right";
  double initialHeight = marioY;
  bool isMarioJump = false;
  double time = 0;
  double height = 0;
  bool isMushroomEaten = false;

  //question
  static double questionX = 0.5;
  static double questionY = 0.2;

  //coin
  // static double coinX = questionX;
  static double coinY = 0.2;
  double initialHeightCoin = coinY;
  double timeCoin = 0;

  //mushroom
  static double mushroomX = 1;
  static double mushroomY = 1;

  @override
  void initState() {
    Wakelock.enable();
    super.initState();
  }

  takeCoin() {
    if (coinY == initialHeightCoin)
      setState(() {
        timeCoin = 0;
        initialHeightCoin = coinY;
      });
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      timeCoin += 0.05;
      height = -4.9 * timeCoin * timeCoin + 5 * timeCoin;
      if (initialHeightCoin - height > initialHeightCoin) {
        setState(() {
          coinY = initialHeightCoin;
          timer.cancel();
        });
      } else {
        setState(() {
          coinY = initialHeightCoin - height;
        });
      }
    });
  }

  eatMushroom() {
    if ((mushroomX - marioX).abs() < 0.05 && mushroomY == marioY) {
      setState(() {
        mushroomX = -2;
        isMushroomEaten = true;
      });
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (timer.tick == 5) {
          setState(() {
            isMushroomEaten = false;
            timer.cancel();
          });
        }
      });
    }
  }

  jump() {
    if (!isMarioJump) {
      setState(() {
        time = (questionX - marioX).abs() < 0.05 ? 0.85 : 0;
        isMarioJump = true;
        initialHeight = marioY;
      });
      if ((questionX - marioX).abs() < 0.05) {
        takeCoin();
      }
      Timer.periodic(Duration(milliseconds: 60), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;
        if (initialHeight - height > 1) {
          setState(() {
            isMarioJump = false;
            marioY = 1;
            timer.cancel();
          });
        } else {
          setState(() {
            marioY = initialHeight - height;
          });
        }
      });
    }
  }

  moveLeft() {
    setState(() {
      isMarioRun = !isMarioRun;
      direction = "left";
    });
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      if (isLeftTap && marioX - 0.02 > -1) {
        setState(() {
          isMarioRun = !isMarioRun;
          marioX -= 0.02;
          questionX += 0.02;
          mushroomX += 0.02;
        });
        eatMushroom();
      } else {
        setState(() {
          timer.cancel();
        });
      }
    });
  }

  moveRight() {
    setState(() {
      isMarioRun = !isMarioRun;
      direction = "right";
    });
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      if (isRightTap) {
        if (marioX + 0.02 < 0.0) {
          setState(() {
            isMarioRun = !isMarioRun;
            marioX += 0.02;
            questionX -= 0.02;
            mushroomX -= 0.02;
          });
        } else {
          setState(() {
            isMarioRun = !isMarioRun;
            questionX -= 0.02;
            mushroomX -= 0.02;
          });
        }
        eatMushroom();
      } else {
        setState(() {
          timer.cancel();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        });
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff0c76ed),
                      Color(0xffc6e7ed),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 50),
                      alignment: Alignment(questionX, coinY),
                      child: Coin(),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 50),
                      alignment: Alignment(mushroomX, mushroomY),
                      child: Mushroom(),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 50),
                      alignment: Alignment(questionX, questionY),
                      child: QuestionStone(),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 50),
                      alignment: Alignment(marioX, marioY),
                      child: isMarioJump
                          ? MarioJump(
                              direction: direction,
                              isMushroomEaten: isMushroomEaten,
                            )
                          : MarioWalk(
                              isMarioRun: isMarioRun,
                              direction: direction,
                              isMushroomEaten: isMushroomEaten,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2.8,
              color: Colors.brown,
              child: Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: Row(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              setState(() {
                                isLeftTap = false;
                                isMarioRun = false;
                              });
                            },
                            onTapDown: (TapDownDetails details) {
                              setState(() {
                                isLeftTap = true;
                              });
                              moveLeft();
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              setState(() {
                                isRightTap = false;
                                isMarioRun = false;
                              });
                            },
                            onTapDown: (TapDownDetails details) {
                              setState(() {
                                isRightTap = true;
                              });
                              moveRight();
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        jump();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white.withOpacity(0.5),
                          border: Border.all(
                            width: 1,
                            color: Colors.white,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "JUMP",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
