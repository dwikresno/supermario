// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, avoid_print, avoid_unnecessary_containers

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_mario_new/page/coin.dart';
import 'package:super_mario_new/page/enemy.dart';
import 'package:super_mario_new/page/mariojump.dart';
import 'package:super_mario_new/page/mariowalk.dart';
import 'package:super_mario_new/page/mushroom.dart';
import 'package:super_mario_new/page/question.dart';
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
  bool isEnemyComingBack = false;
  bool isEnemyRun = false;

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

  //enemy
  static double enemyX = 1;
  static double enemyY = 1;

  //audio
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioMainPlayer = AudioPlayer();

  @override
  void initState() {
    Wakelock.enable();
    playIntro();
    enemyAutoRun();
    super.initState();
  }

  restart() {
    setState(() {
      marioX = -1;
      marioY = 1;
      enemyX = 2;
      enemyY = 1;
      audioPlayer.stop();
      initialHeight = marioY;
      questionX = 0.5;
      questionY = 0.2;

      coinY = 0.2;
      initialHeightCoin = coinY;
      timeCoin = 0;

      //mushroom
      mushroomX = 1;
      mushroomY = 1;

      //enemy
      enemyX = 1;
      enemyY = 1;
      playIntro();
      enemyAutoRun();
    });
  }

  Future<void> playIntro() async {
    var content = await rootBundle.load("assets/sound/running_about.mp3");
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/running_about.mp3");
    file.writeAsBytesSync(content.buffer.asUint8List());
    await audioMainPlayer.setFilePath(file.path);
    audioMainPlayer.setLoopMode(LoopMode.one);
    audioMainPlayer.play();
  }

  enemyAutoRun() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!isEnemyComingBack) {
        setState(() {
          isEnemyRun = !isEnemyRun;
          enemyX -= 0.02;
        });
        if (enemyX <= -1) {
          setState(() {
            isEnemyComingBack = true;
          });
        }
      } else {
        setState(() {
          isEnemyRun = !isEnemyRun;
          enemyX += 0.02;
        });
        if (enemyX >= 1) {
          setState(() {
            isEnemyComingBack = false;
          });
        }
      }
      if ((enemyX - marioX).abs() < 0.08 && (enemyY - marioY).abs() < 0.05) {
        marioDead();
        timer.cancel();
      }
    });
  }

  marioDead() {
    if (!isMarioJump) {
      audioMainPlayer.stop();
      audioPlayer.setAsset("assets/sound/smb_mariodie.wav");
      audioPlayer.play();
      setState(() {
        time = 0;
        isMarioJump = true;
        initialHeight = marioY;
      });
      Timer.periodic(Duration(milliseconds: 60), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;
        if (initialHeight - height > 5) {
          setState(() {
            isMarioJump = false;
            marioY = 5;
            timer.cancel();
            audioPlayer.setAsset("assets/sound/smb_gameover.wav");
            audioPlayer.play();
          });
        } else {
          setState(() {
            marioY = initialHeight - height;
          });
        }
      });
    }
  }

  takeCoin() {
    if (coinY == initialHeightCoin) {
      audioPlayer.setAsset("assets/sound/smb_coin.wav");
      audioPlayer.play();
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
  }

  eatMushroom() {
    if ((mushroomX - marioX).abs() < 0.05 && mushroomY == marioY) {
      audioPlayer.setAsset("assets/sound/smb_powerup.wav");
      audioPlayer.play();
      setState(() {
        mushroomX = -2;
        isMushroomEaten = true;
      });
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (timer.tick == 5) {
          audioPlayer.setAsset("assets/sound/smb_powerdown.wav");
          audioPlayer.play();
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
      audioPlayer.setAsset("assets/sound/smb_jump-small.wav");
      audioPlayer.play();
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
          enemyX += 0.005;
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
            enemyX -= 0.02;
          });
        } else {
          setState(() {
            isMarioRun = !isMarioRun;
            questionX -= 0.02;
            mushroomX -= 0.02;
            enemyX -= 0.02;
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
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: [SystemUiOverlay.bottom]);
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height / 2.8,
                color: Colors.brown,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 30,
                    right: 30,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // ignore: prefer_const_literals_to_create_immutables
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
                          alignment: Alignment(enemyX, enemyY),
                          child: Enemy(isEnemyRun: isEnemyRun),
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
                  color: Colors.transparent,
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
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: marioY > 4,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white.withOpacity(0.7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Text(
                        "GAME OVER",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 80,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          restart();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            "RESTART",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
