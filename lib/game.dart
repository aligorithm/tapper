import 'dart:async';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:play_games/play_games.dart';
import 'package:provider/provider.dart';
import 'package:tapper/constants.dart';
import 'package:tapper/game_provider.dart';
import 'dart:io' show Platform;

import 'package:tapper/widgets/game_guide.dart';

class Game extends StatefulWidget {
  Game({Key key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  int _score = 0;
  double _positionTop = 200;
  double _positionLeft = 200;
  bool _tapping = false;
  bool _gameOver = false;
  // bool _gameWaiting = true;
  bool _newRecord = false;
  bool _badBox = false;
  bool _boxInvisibleForMiscellaneousReasons = false;
  Timer _loseTimer = Timer(Duration(), () {});
  int _timeLimit = 1000;
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
  GameProvider _provider;
  Size size;
  @override
  void initState() {
    super.initState();
    _currentColor = Colors.greenAccent;
  }

  @override
  void didChangeDependencies() {
    _provider = Provider.of<GameProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0XFF4E4C67),
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 42.0),
                    child: Stack(
                      children: [
                        Row(children: <Widget>[
                          Image.asset(
                            'assets/images/crown.png',
                            height: 36.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              _provider.record.toString(),
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.white),
                            ),
                          ),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_score.toString(),
                                style: TextStyle(
                                    fontSize: 48.0, color: Colors.white)),
                            Visibility(
                                visible: _newRecord,
                                child: Image.asset(
                                  'assets/images/fire.png',
                                  height: 40.0,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: _positionTop,
              left: _positionLeft,
              child: Visibility(
                visible: (_gameOver || _boxInvisibleForMiscellaneousReasons)
                    ? false
                    : true,
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
                          color: _badBox ? Color(0XFFE81123) : _currentColor,
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                width: size.width,
                top: size.height * .5,
                child: Visibility(
                  visible: _gameOver,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon:
                                  Image.asset('assets/images/leaderboard.png'),
                              iconSize: 80,
                              onPressed: () {
                                Platform.isIOS
                                    ? GamesServices.showLeaderboards(
                                        iOSLeaderboardID:
                                            Constants.ios_leaderboard_id)
                                    : PlayGames.showLeaderboard(
                                        Constants.android_leaderboard_id);
                              }),
                          SizedBox(
                            width: 64.0,
                          ),
                          IconButton(
                              icon: Image.asset(_provider.soundOn
                                  ? 'assets/images/sound.png'
                                  : 'assets/images/sound_muted.png'),
                              iconSize: 80,
                              onPressed: () {
                                _provider.soundOn = !_provider.soundOn;
                              }),
                        ],
                      ),
                      SizedBox(
                        height: size.height * .05,
                      ),
                      IconButton(
                        iconSize: 80.0,
                        icon: Image.asset('assets/images/play.png'),
                        onPressed: () {
                          _restartGame();
                        },
                      ),
                    ],
                  ),
                )),
                _provider.guideSeen ? Container(): Center(
                  child: Container(
                    width: size.width * .8,
                    height: 300.0,
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: GameGuide()),
                )
          ],
        ),
      ),
    );
  }

  _increaseScore() async {
    setState(() {
      _score++;
    });
    if (_score > _provider.record) {
      if(!_provider.firstPlay){
        setState(() {
        _newRecord = true;
      });
      }
      
      // await Future.delayed(Duration(milliseconds: 500));
      _setNewRecord();
      setState(() {
        _newRecord = false;
      });
    }
  }

  _setNewRecord() {
    _provider.record = _score;
  }

  _loseGame() {
    _badBox ? _playBadBox() : _playGameOver();
    setState(() {
      _provider.firstPlay = false;
      _gameOver = true;
      _timeLimit = 1000;
      _positionTop = 200;
      _positionLeft = 200;
      _loseTimer = Timer(Duration(), () {});
    });
  }

  _restartGame() {
    setState(() {
      _badBox = false;
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
    if (_badBox) {
      _loseGame();
      return;
    }
    _playTapSound();
    final Random _random = Random();

    setState(() {
      _tapping = true;
      _badBox = false;
    });
    _increaseScore();
    if (_score == 5) {
      setState(() {
        _timeLimit -= 50;
      });
    }
    if (_score == 10) {
      setState(() {
        _timeLimit -= 50;
      });
    }
    if (_score % 10 == 0) {
      if(_timeLimit >= 500){
        _timeLimit -= 50;
      }
      setState(() {
        _currentColor = _colors[_random.nextInt(_colors.length)];
      });
    }
    await Future.delayed(Duration(milliseconds: _timeLimit));
    _boxInvisibleForMiscellaneousReasons = false;
    double left = _random.nextInt(size.width.toInt() - 130).toDouble();
    double top =
        _random
            .nextInt(size.height.toInt() - 130)
            .toDouble();
    if(top < 200){
      top += 200;
    }
    int _randomBadBoxChecker = _random.nextInt(6);
    if (_randomBadBoxChecker == 3) {
      setState(() {
        _badBox = true;
      });
    }
    setState(() {
      _positionLeft = left;
      _positionTop = top;
      _tapping = false;
    });
    _loseTimer = Timer(Duration(milliseconds: _timeLimit), () {
      if (!_badBox) {
        _loseGame();
      } else {
        setState(() {
          _boxInvisibleForMiscellaneousReasons = true;
          _badBox = false;
        });
        _tap();
      }
    });
    return;
  }

  // Future<void> _flicker({Color color}) async {
  //   if (color == null) {
  //     color = _currentColor;
  //   }
  //   setState(() {
  //     _backgroundColor = color.withAlpha(100);
  //   });
  //   await Future.delayed(Duration(milliseconds: 200));
  //   setState(() {
  //     _backgroundColor = Colors.white;
  //   });
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.stop();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.play();
    }
  }

  void _playGameOver() {
    if (_provider.soundOn) {
      _audioPlayer.open(Audio(
        "assets/audios/over.mp3",
      ));
      _audioPlayer.play();
    }
  }

  void _playBadBox() {
    if (_provider.soundOn) {
      _audioPlayer.open(Audio("assets/audios/bad_box.mp3"));
      _audioPlayer.play();
    }
  }

  void _playTapSound() {
    if (_provider.soundOn) {
      _audioPlayer.open(Audio(
        "assets/audios/tap.mp3",
      ));
      _audioPlayer.play();
    }
  }
}
