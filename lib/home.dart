import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:play_games/play_games.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/game.dart';
import 'package:tapper/game_provider.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Size size;
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  SharedPreferences _sharedPreferences;
  GameProvider _provider;

  @override
  void didChangeDependencies() {
    _provider = Provider.of<GameProvider>(context);
    if (_sharedPreferences == null) {
      _initialize();
    }
    super.didChangeDependencies();
  }

  void _initialize() async {
    _gameServiceSetup();
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _provider.record = _sharedPreferences.getInt("record") ?? 0;
      _provider.soundOn = _sharedPreferences.getBool("soundOn") ?? true;
    });
    if (_provider.record == 0) {
      setState(() {
        _provider.firstPlay = true;
      });
    }
    if (_provider.soundOn) _playSoundtrack();
  }

  void _gameServiceSetup() async {
    if (Platform.isIOS) {
      GamesServices.signIn();
    } else {
      SigninResult result = await PlayGames.signIn();
      if (result.success) {
        await PlayGames.setPopupOptions();

        // this.account = result.account;
      } else {
        debugPrint("GPG" + result.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color(0XFF4E4C67),
        body: Column(
          children: [
            SafeArea(
                child: Container(
                    margin: EdgeInsets.only(
                        top: size.height * .05, bottom: size.height * .02),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/crown.png',
                      width: 36,
                    ))),
            Text(_provider.record.toString(),
                style: TextStyle(fontSize: 64.0, color: Colors.white)),
            SizedBox(
              height: size.height * .04,
            ),
            Image.asset(
              'assets/images/tapper.png',
              height: 64,
            ),
            SizedBox(
              height: size.height * .04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: Image.asset('assets/images/leaderboard.png'),
                    iconSize: 80,
                    onPressed: () {
                      Platform.isIOS
                          ? GamesServices.showLeaderboards(
                              iOSLeaderboardID: 'highscores')
                          : PlayGames.showLeaderboard("CgkIiqT5p9YdEAIQAQ");
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
                      if (!_provider.soundOn) {
                        _audioPlayer.stop();
                      } else {
                        _audioPlayer.play();
                      }
                    }),
              ],
            ),
            SizedBox(
              height: size.height * .05,
            ),
            IconButton(
                icon: Image.asset('assets/images/play.png'),
                iconSize: 80,
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) => Game()));
                }),
          ],
        ));
  }

  void _playSoundtrack() {
    _audioPlayer.open(Audio(
      "assets/audios/soundtrack.mp3",
    ));
    _audioPlayer.loop = true;
    _audioPlayer.play();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.stop();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
