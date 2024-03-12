import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'screens.dart';
import 'dart:io'; // For Platform checks
import 'package:flutter/foundation.dart'; // For kIsWeb, defaultTargetPlatform

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Jetpack Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainMenu(),
      routes: {
        '/game': (context) => GameScreen(),
        '/periodicTable': (context) => MoleculeTableScreen(),
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SpaceJetpackGame _game;

  @override
  void initState() {
    super.initState();
    _game = SpaceJetpackGame(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    Widget gameWidget = RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _game.onRawKeyEvent,
      child: GameWidget(game: _game),
    );

    // Request focus when the game widget is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus();
    });

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          if (_game.gameOver) {
            // Assuming you have a method in your game class to handle overlay removal
            _game.removeGameOverOverlay();
            Navigator.pop(context);
          } else {
            // Logic for popping the screen, if necessary, or handling other actions when the game is not over
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            gameWidget,
            if (isMobile)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: MovementButtons(game: _game),
                ),
              ),
            // Other widgets or UI components as needed
          ],
        ),
      ),
    );
  }
}