import 'dart:io';

import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:games_services/models/score.dart';
import 'package:play_games/play_games.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  int _record = 0;
  bool _soundOn = false;
  bool _firstPlay = false;
  bool _guideSeen = false;
  SharedPreferences _preferences;
  int get record => _record;
  bool get soundOn => _soundOn;
  bool get firstPlay => _firstPlay;
  bool get guideSeen => _guideSeen;

  set record(int record){
    _record = record;
    _persistRecordAndUpdateGameServices(record);
    notifyListeners();
  }

  set soundOn(bool soundOn){
    _soundOn = soundOn;
    _persistSoundSetting(_soundOn);
    notifyListeners();
  }

  set firstPlay(bool firstPlay){
    _firstPlay = firstPlay;
    notifyListeners();
  }

  set guideSeen(bool guideSeen){
    _guideSeen = guideSeen;
    _persistGuideSeenSetting(guideSeen);
    notifyListeners();
  }


  _persistRecordAndUpdateGameServices(int record)async{
    if(_preferences == null) _preferences = await SharedPreferences.getInstance();
    _preferences.setInt("record", record);
    if(Platform.isIOS) {
      GamesServices.submitScore(
        score: Score(
            // androidLeaderboardID: 'CgkIiqT5p9YdEAIQAQ',
            iOSLeaderboardID: 'highscores',
            value: _record));
    } else PlayGames.submitScoreById("CgkIiqT5p9YdEAIQAQ", _record);
  }

  _persistSoundSetting(bool soundOn) async{
    if(_preferences == null) _preferences = await SharedPreferences.getInstance();
    _preferences.setBool("soundOn", soundOn);
  }
  _persistGuideSeenSetting(bool guideSeen) async{
    if(_preferences == null) _preferences = await SharedPreferences.getInstance();
    _preferences.setBool("guideSeen", guideSeen);
  }

}