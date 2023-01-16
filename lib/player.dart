import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget {

  final  playerX;

MyPlayer({this.playerX});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          alignment: Alignment(playerX, 1),
          child: Container(
            color: Colors.deepOrange,
            height: 50,
            width: 50,

          ),
        ),
      ),
    );
  }
}
