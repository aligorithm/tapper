import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapper/home.dart';
import 'package:tapper/provider.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TapperProvider())],
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