import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapper/game_provider.dart';

class GameGuide extends StatefulWidget {
  const GameGuide({Key key}) : super(key: key);

  @override
  _GameGuideState createState() => _GameGuideState();
}

class _GameGuideState extends State<GameGuide> {
  GameProvider _gameProvider;
  @override
  void didChangeDependencies() {
    _gameProvider = Provider.of<GameProvider>(context);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top:16.0,bottom: 8.0),
            child: Text(
              "How to Play",
              style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
              "1. Tap the green box to earn points (its color will change from time to time)"),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("2. Tap the red box, GAME OVER"),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("3. Tap too slow, GAME OVER"),
        ),
        Padding(
          padding: const EdgeInsets.only(top:16.0),
          child: Center(
              child: FlatButton(
            color: Color(0XFF4E4C67),
            child: Text(
              "Okay",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _gameProvider.guideSeen = true;
            },
          )),
        )
      ],
    );
  }
}
