import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';


import 'molecule_data.dart';

class SpaceBackground extends SpriteComponent {
  double screenHeight;
  double screenWidth;

  SpaceBackground({required this.screenHeight, required this.screenWidth}) {
    size = Vector2(screenWidth, screenHeight);
    onLoad();
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('island.png');
  }

  void moveDown(double speed, double dt, double multiplier) {
    position.y += speed * dt * multiplier;

    if (position.y >= screenHeight) {
      position.y -= screenHeight * 2;
    }
  }
}


class Molecule extends SpriteComponent {
  final int moleculeNumber;
  List<Sprite> moleculeSprites = [];
  int currentSpriteIndex = 0;
  double animationTimer = 0.0;
  double animationSpeed = 0.1; // Adjust this speed as needed

  Molecule({
    required this.moleculeNumber,
    required double screenHeight,
    required double screenWidth,
    required double x,
    required double y,
  }) {
    size = Vector2(screenWidth * 0.1, screenHeight * 0.1);
    position = Vector2(x, y);
    onLoad();
  }

  @override
  Future<void> onLoad() async {
    // Load two sprites for the molecule animation
    moleculeSprites.add(await Sprite.load('molecule_1_$moleculeNumber.png'));
    moleculeSprites.add(await Sprite.load('molecule_2_$moleculeNumber.png'));

    // Set the initial sprite
    sprite = moleculeSprites[currentSpriteIndex];
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the animation timer
    animationTimer += dt;
    if (animationTimer >= animationSpeed) {
      // Reset the timer
      animationTimer = 0.0;

      // Update sprite index to alternate between the two sprites
      currentSpriteIndex = (currentSpriteIndex + 1) % moleculeSprites.length;

      // Change the sprite
      sprite = moleculeSprites[currentSpriteIndex];
    }
  }

  void moveDown(double speed, double dt, double multiplier) {
    position.y += speed * dt * multiplier;
  }
}

class Player extends SpriteComponent {
  double screenHeight;
  double screenWidth;
  bool isMovingUp = false;
  bool isMovingDown = false;
  bool isMovingLeft = false;
  bool isMovingRight = false;

  //for player animation
  List<Sprite> playerSprites = [];
  int currentSpriteIndex = 0;
  double animationTimer = 0.0;
  double animationSpeed = 0.1;

  Player(this.screenHeight, this.screenWidth) {
    size = Vector2(screenWidth * 0.1, screenHeight * 0.1);
    position = Vector2(screenWidth * 0.5 - size.x / 2, screenHeight * 0.5 - size.y / 2);
    onLoad();
  }

  @override
  Future<void> onLoad() async {
    //sprite = await Sprite.load('player1.png');
    // Load multiple player sprites
    playerSprites.add(await Sprite.load('player1.png'));
    playerSprites.add(await Sprite.load('player2.png'));
    playerSprites.add(await Sprite.load('player3.png'));

    // Set the initial sprite
    sprite = playerSprites[currentSpriteIndex];
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isMovingUp) {
      moveUp(dt);
    }
    if (isMovingDown) {
      moveDown(dt);
    }
    if (isMovingLeft) {
      moveLeft(dt);
    }
    if (isMovingRight) {
      moveRight(dt);
    }


    // Update the animation timer
    animationTimer += dt;
    if (animationTimer >= animationSpeed) {
      // Reset the timer
      animationTimer = 0.0;

      // Update sprite index
      currentSpriteIndex = (currentSpriteIndex + 1) % playerSprites.length;

      // Change the sprite
      sprite = playerSprites[currentSpriteIndex];
    }
  }


  bool collidesWith(Molecule molecule) {
    return toRect().overlaps(molecule.toRect());
  }

  bool collidesWithBadMolecule(BadMolecule junk) {
    return toRect().overlaps(junk.toRect());
  }



  void moveUp(double dt) {
    position.y -= 10 * dt *60;
    position.y = max(position.y, 0);
  }

  void moveDown(double dt) {
    position.y += 10 * dt * 60;
    position.y = min(position.y, screenHeight - size.y);
  }

  void moveLeft(double dt) {
    position.x -= 10 * dt * 60;
    position.x = max(position.x, 0);
  }

  void moveRight(double dt) {
    position.x += 10 * dt * 60;
    position.x = min(position.x, screenWidth - size.x);
  }
}

class BadMolecule extends SpriteComponent {
  final int imageIndex;
  final int moleculeNumber; // Add this line
  List<Sprite> badMoleculeSprites = [];
  int currentSpriteIndex = 0;
  double animationTimer = 0.0;
  double animationSpeed = 0.1; // Adjust this speed as needed

  BadMolecule({
    required this.imageIndex,
    required this.moleculeNumber,
    required double screenHeight,
    required double screenWidth,
    required double x,
    required double y,
  }) {
    size = Vector2(screenWidth * 0.1, screenHeight * 0.1);
    position = Vector2(x, y);
    onLoad();
  }

  @override
  Future<void> onLoad() async {
    // Load two sprites for the BadMolecule animation
    badMoleculeSprites.add(await Sprite.load('molecule_1_$imageIndex.png'));
    badMoleculeSprites.add(await Sprite.load('molecule_2_$imageIndex.png'));

    // Set the initial sprite
    sprite = badMoleculeSprites[currentSpriteIndex];
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the animation timer
    animationTimer += dt;
    if (animationTimer >= animationSpeed) {
      // Reset the timer
      animationTimer = 0.0;

      // Update sprite index to alternate between the two sprites
      currentSpriteIndex = (currentSpriteIndex + 1) % badMoleculeSprites.length;

      // Change the sprite
      sprite = badMoleculeSprites[currentSpriteIndex];
    }
  }

  void moveDown(double speed, double dt, double multiplier) {
    position.y += speed * dt * multiplier;
  }
}

class ShieldIcon extends PositionComponent {
  bool isActive;
  late SpriteComponent icon;

  ShieldIcon({
    required this.isActive,
    required Vector2 position,
  }) {
    this.position = position;
    size = Vector2(32 * 0.8, 32 * 0.8); // Adjust size as needed
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadSprite(isActive);
  }

  Future<void> loadSprite(bool active) async {
    icon = SpriteComponent(
      sprite: await Sprite.load(active ? 'shield_active.png' : 'shield_inactive.png'),
      size: size,
    );
    add(icon);
  }

  void updateIcon(bool active) async {
    isActive = active;
    await loadSprite(active); // Handle sprite loading asynchronously
  }
}



class SpaceJetpackGame extends FlameGame {
  Player? player;
  final Random random = Random();
  final BuildContext context;
  int score = 0;
  int biocoin = 0;
  int biocoinEarned = 0;
  late TextComponent scoreTextComponent;
  late TextComponent levelTextComponent;
  late TextComponent biocoinDisplayComponent;
  final List<ShieldIcon> shieldIcons = [];
  late TextComponent shieldStrengthText;
  int shieldStrength = 4; // Start with half full shield
  bool gameOver  = false;
  double backgroundSpeed = 2.0;
  int level = 1;
  double multiplier = 60; // Initial multiplier value
  double timeSinceLastIncrement = 0; // Timer to track time since last multiplier increment
  final double incrementInterval = 30; // Time in seconds to wait before incrementing the multiplier
  final double maxMultiplier = 100; // Maximum value for the multiplier
  Set<LogicalKeyboardKey> _pressedKeys = {};


  SpaceJetpackGame(this.context);

  Iterable<Component> get components => children;



  @override
  Future<void> onLoad() async {
    await super.onLoad();
    double screenHeight = canvasSize.y;
    double screenWidth = canvasSize.x;

    final spaceBackground = SpaceBackground(screenHeight: screenHeight, screenWidth: screenWidth);
    add(spaceBackground);

    final spaceBackground2 = SpaceBackground(screenHeight: screenHeight, screenWidth: screenWidth);
    spaceBackground2.position.y = -screenHeight;
    add(spaceBackground2);

    player = Player(screenHeight, screenWidth);
    add(player!);

    for (int i = 0; i < 5; i++) {
      add(createRandomMolecule(screenHeight, screenWidth));
      add(createRandomBadMolecule(screenHeight, screenWidth));
    }

    final textPaint = TextPaint(
      style: TextStyle(
        fontSize: 14, // Example of a smaller font size, adjust as needed
        color: Colors.white, // Adjust color as needed
      ),
    );

    // Shield Strength Text
    shieldStrengthText = TextComponent(
      text: 'Shield',
      position: Vector2(10, 10),
      textRenderer: textPaint, // Use the custom TextPaint
    );
    add(shieldStrengthText);

    // Shield Icons positioned to the right of the "Shield Strength" text
    double startX = shieldStrengthText.position.x + 60; // Adjust startX based on the length of your text
    for (int i = 0; i < 8; i++) {
      var icon = ShieldIcon(
        isActive: i < shieldStrength,
        position: Vector2(startX + i * 36, 10), // Positioned to the right of the "Shield Strength" text
      );
      shieldIcons.add(icon);
      add(icon);
    }

    // Level Text positioned below the "Shield Strength" text
    levelTextComponent = TextComponent(
      text: 'Level: $level',
      position: Vector2(10, 50), // Adjust Y position based on your preference
      textRenderer: textPaint, // Use the custom TextPaint
    );
    add(levelTextComponent);

    // Assuming the Coin Icon is a SpriteComponent similar to ShieldIcon but with its sprite
    var coinIcon = SpriteComponent(
        sprite: await Sprite.load('coin_icon.png'), // Ensure this sprite exists in your assets folder
        size: Vector2(32 * 0.8, 32 * 0.8),
        position: Vector2(levelTextComponent.position.x + levelTextComponent.width + 20, levelTextComponent.position.y - 3) // Position to the right of the level text
    );
    add(coinIcon);

    // Load lifetime BioCoin balance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    biocoin = prefs.getInt('lifetimeBiocoin') ?? 0;

    biocoinDisplayComponent = TextComponent(
      text: 'BioCoin: $biocoin',
      position: Vector2(coinIcon.position.x + coinIcon.size.x + 7, coinIcon.position.y+3),
      textRenderer: textPaint, // Use the custom TextPaint
    );
    add(biocoinDisplayComponent);

    // Score Text positioned to the right of the Coin Icon
    scoreTextComponent = TextComponent(
      text: 'Score: $score',
      position: Vector2(coinIcon.position.x + coinIcon.size.x + 120, coinIcon.position.y +3),
      textRenderer: textPaint, // Use the custom TextPaint
    );
    add(scoreTextComponent);

    updateBioCoinDisplay();
  }

  void onRawKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is RawKeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  void updateScore() async {
    scoreTextComponent.text = 'Score: $score';
  }

  void updateBioCoinDisplay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lifetimeBiocoin', biocoin); // Save the lifetime BioCoin
    biocoinDisplayComponent.text = 'BioCoin: $biocoin'; // Assume you have a TextComponent for this
  }

  OverlayEntry? gameOverOverlay;

  void removeGameOverOverlay() {
    gameOverOverlay?.remove();
    gameOverOverlay = null; // Ensure to reset the overlay variable
    gameOver = false; // Reset game over state if necessary
  }


  void showGameOver(BuildContext context) {
    gameOverOverlay = OverlayEntry(
      builder: (context) => Material( // Wrap in a Material widget to remove yellow underline
        color: Colors.transparent, // Set color to transparent or as needed
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20), // Add padding around the column
            width: MediaQuery.of(context).size.width * 0.8, // This makes the box not take the full width, adjust as needed
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7), // Semi-transparent black background for the text box
              borderRadius: BorderRadius.circular(10), // Rounded corners for the box
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use the minimum space
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Game Over',
                  style: TextStyle(fontSize: 48, color: Colors.white),
                ),
                SizedBox(height: 10), // Space out the text and buttons
                Text(
                  'Final Score: $score', // Display final score
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 10), // Space out the text and buttons
                Text(
                  'BioCoin: $biocoin', // Display biocoin
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 10), // Space out the text and buttons
                Text(
                  'BioCoin Earned: $biocoinEarned', // Display biocoin earned
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 20), // Space out the text and buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/'); // Go to main menu
                    gameOverOverlay?.remove();
                  },
                  child: Text('Back to Main Menu'),
                ),
                SizedBox(height: 10), // Space out the buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/game'); // Restart the game
                    gameOverOverlay?.remove();
                  },
                  child: Text('Restart Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(gameOverOverlay!);


  }


  Molecule createRandomMolecule(double screenHeight, double screenWidth) {
    int moleculeNumber = random.nextInt(4) * 2 + 2;
    //int moleculeNumber = 0;

    return Molecule(
      moleculeNumber: moleculeNumber,
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      x: random.nextDouble() * screenWidth,
      y: -random.nextDouble() * screenHeight, // Updated to start above the top of the frame
    );
  }

  BadMolecule createRandomBadMolecule(double screenHeight, double screenWidth) {
    //for n
    int moleculeNum = random.nextInt(4) * 2 + 1;
    //int moleculeNumber = 1;
    return BadMolecule(
      moleculeNumber: moleculeNum,
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      x: random.nextDouble() * screenWidth,
      y: -random.nextDouble() * screenHeight, // Updated to start above the top of the frame
      imageIndex: moleculeNum,
    );
  }

  void increaseShield() {
    if (shieldStrength < 8) {
      shieldStrength++;
      shieldIcons[shieldStrength - 1].updateIcon(true);
    }
  }

  void decreaseShield() {
    if (shieldStrength > 0) {
      shieldStrength--;
      shieldIcons[shieldStrength].updateIcon(false); // Update the icon to inactive
      if (shieldStrength == 0) {
        gameOver = true;
        backgroundSpeed = 0;
        showGameOver(context);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Increment the timer with the delta time
    timeSinceLastIncrement += dt;

    // Check if it's time to increase the multiplier
    if (timeSinceLastIncrement >= incrementInterval && multiplier < maxMultiplier) {
      multiplier += 5; // Increase the multiplier by 1
      level += 1; // Increase the level by 1
      timeSinceLastIncrement = 0; // Reset the timer
      // Update level display
      levelTextComponent.text = 'Level: $level';
    }

    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      player!.moveUp(dt);
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      player!.moveDown(dt);
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      player!.moveLeft(dt);
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      player!.moveRight(dt);
    }

    if (!gameOver) {
      components.whereType<SpaceBackground>().forEach((bg) {
        bg.moveDown(backgroundSpeed, dt, multiplier);
      });

      components.whereType<Molecule>().forEach((molecule) {
        molecule.moveDown(backgroundSpeed, dt, multiplier);

        if (player!.collidesWith(molecule)) {
          if (molecule.moleculeNumber == 4) { // Check if molecule is of type 1
            increaseShield(); // Increase shield strength
          }
          if (molecule.moleculeNumber == 2 || molecule.moleculeNumber == 8) { // Check if molecule is of type 1
            biocoin += molecule.moleculeNumber; // Increase shield strength
            biocoinEarned += molecule.moleculeNumber;
          }
          score += molecule.moleculeNumber; // Incrementing the score by molecule number
          MoleculeData.collectMoleculeByNumber(molecule.moleculeNumber);
          remove(molecule);
          double screenHeight = canvasSize.y;
          double screenWidth = canvasSize.x;
          add(createRandomMolecule(screenHeight, screenWidth));
          updateScore();
          updateBioCoinDisplay();// Update the displayed score
        }

        if (molecule.position.y >= canvasSize.y) {
          remove(molecule);
          double screenHeight = canvasSize.y;
          double screenWidth = canvasSize.x;
          add(createRandomMolecule(screenHeight, screenWidth));
        }
      });

      components.whereType<BadMolecule>().forEach((junk) {
        junk.moveDown(backgroundSpeed, dt, multiplier);

        if (player!.collidesWithBadMolecule(junk)) {
          MoleculeData.collectMoleculeByNumber(junk.moleculeNumber);
          decreaseShield();// Exit the update method
          remove(junk);
          if (!gameOver) {
            add(createRandomBadMolecule(canvasSize.y, canvasSize.x));
          }
        }


        if (junk.position.y >= canvasSize.y) {
          remove(junk);
          double screenHeight = canvasSize.y;
          double screenWidth = canvasSize.x;
          add(createRandomBadMolecule(screenHeight, screenWidth));
        }
      });
    }
  }

  void setPlayerDirection(Direction direction, bool isPressed) {
    switch (direction) {
      case Direction.up:
        player!.isMovingUp = isPressed;
        break;
      case Direction.down:
        player!.isMovingDown = isPressed;
        break;
      case Direction.left:
        player!.isMovingLeft = isPressed;
        break;
      case Direction.right:
        player!.isMovingRight = isPressed;
        break;
    }
  }



  void movePlayer(Direction direction, Offset? offset, double dt) {
    switch (direction) {
      case Direction.up:
        player!.moveUp(dt);
        break;
      case Direction.down:
        player!.moveDown(dt);
        break;
      case Direction.left:
        player!.moveLeft(dt);
        break;
      case Direction.right:
        player!.moveRight(dt);
        break;
    }
  }
}

enum Direction { up, down, left, right }

class MovementButtons extends StatelessWidget {
  final SpaceJetpackGame game;

  MovementButtons({required this.game});

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: Colors.white.withOpacity(0.5),
        size: 48,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Listener(
            onPointerDown: (_) => game.setPlayerDirection(Direction.up, true),
            onPointerUp: (_) => game.setPlayerDirection(Direction.up, false),
            child: Icon(Icons.arrow_upward_outlined),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Listener(
                onPointerDown: (_) => game.setPlayerDirection(Direction.left, true),
                onPointerUp: (_) => game.setPlayerDirection(Direction.left, false),
                child: Icon(Icons.arrow_back_outlined),
              ),
              SizedBox(width: 16),
              Listener(
                onPointerDown: (_) => game.setPlayerDirection(Direction.right, true),
                onPointerUp: (_) => game.setPlayerDirection(Direction.right, false),
                child: Icon(Icons.arrow_forward_outlined),
              ),
            ],
          ),
          Listener(
            onPointerDown: (_) => game.setPlayerDirection(Direction.down, true),
            onPointerUp: (_) => game.setPlayerDirection(Direction.down, false),
            child: Icon(Icons.arrow_downward_outlined),
          ),
        ],
      ),
    );
  }
}