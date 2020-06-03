import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapper/game_provider.dart';
import 'package:tapper/home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider())
      ],
      child: MaterialApp(
        title: 'Tapper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Home(),
      ),
    );
  }
}