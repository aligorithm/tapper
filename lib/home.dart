import 'dart:async';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _score = 0;
  int _record = 0;
  double _positionTop = 200;
  double _positionLeft = 200;
  bool _tapping = false;
  bool _gameOver = false;
  bool _gameWaiting = true;
  bool _newRecord = false;
  bool _firstPlay = false;
  Timer _loseTimer = Timer(Duration(), () {});
  int _timeLimit = 700;
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  List<Color> _colors = [
    Colors.blueGrey,
    Colors.blue,
    Colors.red,
    Colors.redAccent,
    Colors.teal,
    Colors.yellow
  ];
  Color _currentColor;
  Color _backgroundColor = Colors.white;
  SharedPreferences _sharedPreferences;
  @override
  void initState() {
    super.initState();
    _initialize();
    _currentColor = Colors.greenAccent;
    _audioPlayer.open(AssetsAudio(
      asset: "soundtrack.mp3",
      folder: "assets/audios/",
    ));
    _audioPlayer.play();
  }

  void _initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _record = _sharedPreferences.getInt("record") ?? 0;
      if (_record == 0) {
        _firstPlay = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: _backgroundColor,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              _score.toString(),
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.greenAccent),
                            ),
                            _newRecord
                                ? AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    child: Text("New Record!",
                                        style: TextStyle(
                                            fontSize: 20.0, color: Colors.red)),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      )
                    ],
                  ),
                ),
                AnimatedOpacity(
                    opacity: _gameWaiting || _gameOver ? 1 : 0,
                    duration: Duration(milliseconds: 200),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Tapper:",
                          style: TextStyle(fontSize: 32.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        _gameWaiting
                            ? Container()
                            : Text("Score: $_score",
                                style: TextStyle(
                                    fontSize: 24.0, color: Colors.greenAccent)),
                        Text("Record: $_record",
                            style: TextStyle(
                                fontSize: 24.0, color: Colors.greenAccent)),
                      ],
                    )),
                Expanded(
                  child: Container(),
                ),
                AnimatedOpacity(
                  opacity: _gameOver ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    width: 200.0,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Text(
                        "Restart Game",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.greenAccent,
                      onPressed: () {
                        _restartGame();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 64.0,
                )
              ],
            ),
            Positioned(
              top: _positionTop,
              left: _positionLeft,
              child: Visibility(
                visible: _gameOver ? false : true,
                child: AnimatedOpacity(
                  opacity: _tapping || _gameOver ? 0 : 1,
                  duration: Duration(milliseconds: 100),
                  child: InkWell(
                    onTap: () {
                      _tap(size);
                    },
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                          color: _currentColor,
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _increaseScore() async {
    setState(() {
      _score++;
    });
    if (_score > _record && !_firstPlay) {
      setState(() {
        _newRecord = true;
      });
      await Future.delayed(Duration(milliseconds: 500));
      _setNewRecord();
      setState(() {
        _newRecord = false;
      });
    }
  }

  _setNewRecord() {
    setState(() {
      _record = _score;
    });
    _sharedPreferences.setInt("record", _record);
  }

  _loseGame() {
    setState(() {
      _firstPlay = false;
      _gameOver = true;
      _timeLimit = 1000;
      _positionTop = 200;
      _positionLeft = 200;
      _loseTimer = Timer(Duration(), () {});
    });
    _audioPlayer.open(AssetsAudio(
      asset: "over.mp3",
      folder: "assets/audios/",
    ));
    _audioPlayer.play();
  }

  _restartGame() {
    setState(() {
      _newRecord = false;
      _currentColor = Colors.greenAccent;
      _timeLimit = 1000;
      _tapping = false;
      _score = 0;
      _gameOver = false;
    });
  }

  _tap(Size size) async {
    if (_tapping) {
      return;
    }
    _loseTimer.cancel();
    _audioPlayer.open(AssetsAudio(
      asset: "tap.mp3",
      folder: "assets/audios/",
    ));
    _audioPlayer.play();
    final Random _random = Random();
    setState(() {
      _tapping = true;
      _gameWaiting = false;
    });
    _increaseScore();
    if (_score % 10 == 0) {
      setState(() {
        _timeLimit -= 50;
        _currentColor = _colors[Random().nextInt(_colors.length)];
      });
      _flicker();
    }
    await Future.delayed(Duration(milliseconds: _timeLimit));
    setState(() {
      _positionLeft = 50 + _random.nextInt(size.width.toInt() - 130).toDouble();
      _positionTop = 50 + _random.nextInt(size.height.toInt() - 130).toDouble();
      _tapping = false;
    });
    _loseTimer = Timer(Duration(milliseconds: _timeLimit), () {
      _loseGame();
    });
    return;
  }

  Future<void> _flicker() async {
    setState(() {
      _backgroundColor = _currentColor.withAlpha(100);
    });
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _backgroundColor = Colors.white;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
