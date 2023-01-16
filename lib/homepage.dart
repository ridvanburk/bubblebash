import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:bubblebash/ball.dart';
import 'package:bubblebash/button.dart';
import 'package:bubblebash/missile.dart';
import 'package:bubblebash/spawnPoint.dart';
import 'package:bubblebash/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum direction { LEFT, RIGHT }

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double playerX = 0;

  double missileX = playerX;
  double missileHeight = 10;

  bool midShot = false;

  double ballX = 0.5;
  double ballY = 1;

  var ballDirection = direction.LEFT;

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
        // do nothing to add collidar on x-axis
      } else {
        playerX -= 0.1;
      }
      missileX = playerX;
    });

    if (!midShot) {
      missileX = playerX;
    }
  }



  void moveRight() {

    setState(() {
      if (playerX + 0.1 > 1) {
        //do nothing
      } else {
        playerX += 0.1;
      }
      missileX = playerX;
    });
  }

  void fireMissile() {
    if (midShot == false) {
      Timer.periodic(Duration(milliseconds: 1), (timer) {
        midShot = true;
        //missile grows till it hits the top of the screen
        setState(() {
          missileHeight += 10;
        });

        //stop missile when it reaches top of screen
        if (missileHeight > MediaQuery.of(context).size.height * 3 / 4) {
          resetMissile();
          timer.cancel();
          midShot = false;
        }

        // check If missile has hit the ball
        if (ballY > heightToCoordinate(missileHeight) &&
            (ballX - missileX).abs() < 0.03) {
          resetMissile();
          ballY = 5;
          timer.cancel();
          midShot = false;
          resetBallPosition();
        }
      });
    }
  }

  bool IsDead() {
    if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
      return true;
    } else {
      return false;
    }
  }

  void startGame() {
    double time = 0;
    double height = 0;
    double velocity = 50;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      // quadratic equation that models a bounce (upside down parabola)
      height = -5 * time * time + velocity * time;

      if (height < 0) {
        time = 0;
      }

      setState(() {
        ballY = heightToCoordinate(height);
      });
      time += 0.1;
         if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
      } else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }

      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX = ballX - 0.005;
        });
      } else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      // check If the ball hits the player
      if (IsDead()) {
        timer.cancel();
        showDialogMessage();

       resetBallPosition();
      }
    });



    Timer mytimer = Timer.periodic(Duration(seconds: 1), (timer) {
      MyBall(ballX: ballX+0.1,ballY: ballY);
    });
  }

  void showDialogMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey,
            title: Center(
              child: Text(
                "You dead ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.lightGreen[100],
              child: Center(
                child: Stack(
                  children: [
                    Spawn(),
                    MyBall(ballX: ballX, ballY: ballY),
                    MyMissile(
                      height: missileHeight,
                      missileX: missileX,
                    ),
                    MyPlayer(
                      playerX: playerX,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: Container(
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  icon: Icons.play_arrow,
                  function: startGame,
                ),
                MyButton(
                  icon: Icons.arrow_back,
                  function: moveLeft,
                ),
                MyButton(
                  icon: Icons.arrow_upward,
                  function: fireMissile,
                ),
                MyButton(
                  icon: Icons.arrow_forward,
                  function: moveRight,
                ),

              ],
            ),
          ))
        ],
      ),
    );
  }

  double heightToCoordinate(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double missileY = 1 - 2 * height / totalHeight;
    return missileY;
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 10;
  }

  void resetBallPosition() {
    ballX = 0.5;
    ballY = 1;
  }
}

//TODO top oyuncuya çarptıktan sonra poziyonu resetleme işini yapmadan önce uygulamayı beklet
//belirli noktalara spawn pointler koyarak oyunda devam etmeyi zorlaştır.
