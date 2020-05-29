import 'package:flutter/material.dart';

class TapperProvider extends ChangeNotifier {
  int _score;
  int _record;
  bool _lost = false;

  int get score => _score;
  int get record => _record;
  bool get lost => _lost;

  set score(int score){
    _score = score;
    notifyListeners();
  }

  set record(int record) {
    _score = score;
    notifyListeners();
  }

  set lost(bool lost){
    _lost = lost;
    notifyListeners();
  }

}