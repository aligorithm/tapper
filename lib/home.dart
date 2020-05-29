import 'dart:async';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:games_services/score.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/widgets/circlebutton.dart';
import 'dart:io' show Platform;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int _score = 0;
  int _record = 0;
  double _positionTop = 200;
  double _positionLeft = 200;
  double _badPositionTop = 300;
  double _badPositionLeft = 300;
  bool _badBoxActive = true;
  bool _tapping = false;
  bool _gameOver = false;
  bool _gameWaiting = true;
  bool _newRecord = false;
  bool _firstPlay = false;
  Timer _loseTimer = Timer(Duration(), () {});
  int _timeLimit = 800;
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  List<Color> _colors = [
    Colors.blueGrey,
    Colors.blue,
    Colors.teal,
    Colors.yellow,
    Colors.amber,
    Colors.deepPurple,
    Colors.lime,
    Colors.purple,
    Colors.indigo,
    Colors.deepPurpleAccent,
    Colors.greenAccent,
    Colors.green,
    Color(0XFF038387),
    Color(0XFF2D7D9A),
    Color(0XFFCA5010),
    Color(0XFF006064),
    Color(0XFF880E4F),
    Color(0XFF3E2723),
    Color(0XFF6D4C41),
    Color(0XFFFF6F00),
    Color(0XFF498205)
  ];
  Color _currentColor;
  Color _backgroundColor = Colors.white;
  SharedPreferences _sharedPreferences;
  // TapperProvider _tapperProvider;
  bool _soundOn = true;
  // List<Widget> _tappers = [];
  Size size;
  @override
  void initState() {
    GamesServices.signIn();
    super.initState();
    _initialize();
    _currentColor = Colors.greenAccent;
  }

  void _initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _record = _sharedPreferences.getInt("record") ?? 0;
      _soundOn = _sharedPreferences.getBool("soundOn") ?? true;
    });
    if (_record == 0) {
      setState(() {
        _firstPlay = true;
      });
    }
    if (_soundOn) {
      _playSoundtrack();
    }
    GamesServices.submitScore(
        score: Score(
            androidLeaderboardID: 'CgkIiqT5p9YdEAIQAQ',
            iOSLeaderboardID: 'highscores',
            value: _record));
  }

  @override
  void didChangeDependencies() {
    // _tapperProvider = Provider.of<TapperProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                          style:
                              TextStyle(fontSize: 32.0, color: Colors.black54),
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
                SizedBox(height: 32.0),
                AnimatedOpacity(
                  opacity: _gameOver || _gameWaiting ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleButton(
                        active: _soundOn,
                        iconData:
                            _soundOn ? Icons.volume_up : Icons.volume_mute,
                        onTap: () {
                          setState(() {
                            _soundOn = !_soundOn;
                          });
                          _sharedPreferences.setBool("soundOn", _soundOn);
                          if (!_soundOn) {
                            _audioPlayer.stop();
                          }
                        },
                      ),
                      SizedBox(
                        width: 32.0,
                      ),
                      Platform.isIOS
                          ? CircleButton(
                              active: true,
                              iconData: Icons.list,
                              onTap: () {
                                GamesServices.showLeaderboards(
                                    iOSLeaderboardID: 'highscores');
                              },
                            )
                          : Container()
                    ],
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
                      _tap();
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
            ), // Good Box
            Positioned(
              top: _badPositionTop,
              left: _badPositionLeft,
              child: Visibility(
                visible: _gameOver ? false : true,
                child: AnimatedOpacity(
                  opacity: _tapping || _gameOver ? 0 : 1,
                  duration: Duration(milliseconds: 100),
                  child: InkWell(
                    onTap: () {
                      _loseGame();
                      _flicker(color: Colors.red);
                    },
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ),
            ), // Bad Box
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
    GamesServices.submitScore(
        score: Score(
            androidLeaderboardID: 'CgkIiqT5p9YdEAIQAQ',
            iOSLeaderboardID: 'highscores',
            value: _record));
  }

  _loseGame() {
    _playGameOver();
    setState(() {
      _firstPlay = false;
      _gameOver = true;
      _timeLimit = 1000;
      _positionTop = 200;
      _positionLeft = 200;
      _loseTimer = Timer(Duration(), () {});
    });
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

  _tap() async {
    if (_tapping) {
      return;
    }
    _loseTimer.cancel();
    _playTapSound();
    final Random _random = Random();
    setState(() {
      _tapping = true;
      _gameWaiting = false;
    });
    _increaseScore();
    if (_score == 5) {
      setState(() {
        _timeLimit -= 100;
      });
    }
    if (_score == 10) {
      setState(() {
        _timeLimit -= 50;
      });
    }
    if (_score % 10 == 0) {
      setState(() {
        _timeLimit -= 50;
        _currentColor = _colors[Random().nextInt(_colors.length)];
      });
      _flicker();
    }
    if(_score == 100){
      _badBoxActive = true;
    }
    await Future.delayed(Duration(milliseconds: _timeLimit));
    double left = 50 + _random.nextInt(size.width.toInt() - 130).toDouble();
    double top = 50 + _random.nextInt(size.height.toInt() - 130).toDouble();
    setState(() {
      _positionLeft = left;
      _positionTop = top;
      _tapping = false;
    });
    if (_badBoxActive) {
      double badLeft = 50 + _random.nextInt(size.width.toInt() - 130).toDouble();
      if(badLeft <= _positionLeft + 80 && badLeft >= _positionLeft - 80){
        badLeft = 50 + _random.nextInt(size.width.toInt() - 130).toDouble();
      }
      double badTop = 50 + _random.nextInt(size.height.toInt() - 130).toDouble();
      if(badTop <= _positionTop + 80 && badTop >= _positionTop - 80){
        badTop = 50 + _random.nextInt(size.width.toInt() - 130).toDouble();
      }
      setState(() {
        _badPositionLeft = badLeft;
        _badPositionTop = badTop;
      });
      
    }
    _loseTimer = Timer(Duration(milliseconds: _timeLimit), () {
      _loseGame();
    });
    return;
  }

  Future<void> _flicker({Color color}) async {
    if (color == null) {
      color = _currentColor;
    }
    setState(() {
      _backgroundColor = color.withAlpha(100);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.play();
    }
  }

  void _playSoundtrack() {
    if (_soundOn) {
      _audioPlayer.open(AssetsAudio(
        asset: "soundtrack.mp3",
        folder: "assets/audios/",
      ));
      _audioPlayer.play();
    }
  }

  void _playGameOver() {
    if (_soundOn) {
      _audioPlayer.open(AssetsAudio(
        asset: "over.mp3",
        folder: "assets/audios/",
      ));
      _audioPlayer.play();
    }
  }

  void _playTapSound() {
    if (_soundOn) {
      _audioPlayer.open(AssetsAudio(
        asset: "tap.mp3",
        folder: "assets/audios/",
      ));
      _audioPlayer.play();
    }
  }
}
