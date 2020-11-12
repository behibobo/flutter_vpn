import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("MyVPN"),
          SizedBox(
            height: 30,
          ),
          LoadingBouncingGrid.square(
            borderColor: Colors.blue,
            borderSize: 1.0,
            size: 70.0,
            backgroundColor: Colors.blueAccent,
            duration: Duration(milliseconds: 1000),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
