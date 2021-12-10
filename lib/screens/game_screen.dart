import 'dart:async';

// import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flappy/screens/background.dart';
import 'package:flappy/widgets/base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final AudioCache _player = AudioCache();

  final GlobalKey _keyBase = GlobalKey();
  final GlobalKey _keyPipeUp = GlobalKey();
  final GlobalKey _keyPipeDown = GlobalKey();
  final GlobalKey _keyBird = GlobalKey();

  late final Size _screenSize;

  final List<String> birdStates = ['upflap', 'midflap', 'downflap'];
  String curBirdState = 'upflap';

  double birdHeight = 300.0;
  double highestHeight = 300.0;
  double acceleration = 1;
  double birdMovement = 0;
  bool goingUp = false;

  int _score = 0;
  bool _goingToScore = false;
  bool _scoreCooldown = false;

  Icon _buttonIcon = const Icon(
    Icons.pause,
    size: 50,
    color: Colors.white,
  );
  bool _paused = false;

  double pipeX = 800;
  int pipeY = -200;
  bool gotWidth = false;

  final randGen = math.Random(DateTime.now().millisecondsSinceEpoch);

  late final AnimationController _birdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0,
      upperBound: 3)
    ..repeat(
      reverse: false,
    );

  late final AnimationController _pipeController;
  late final Tween<double> _pipeTween;
  late final Animation<double> _pipeXPos;
  late final Timer _birdTimer;

  void updateBird(Timer t) {
    if (_paused) return;

    setState(() {
      birdMovement += acceleration;
      birdHeight += birdMovement;
    });

    checkCollisionAndScore();
  }

  void checkCollisionAndScore() {
    final RenderBox pipeUpBox =
        _keyPipeUp.currentContext?.findRenderObject() as RenderBox;

    final RenderBox pipeDownBox =
        _keyPipeDown.currentContext?.findRenderObject() as RenderBox;

    final RenderBox birdBox =
        _keyBird.currentContext?.findRenderObject() as RenderBox;

    final RenderBox baseBox =
        _keyBase.currentContext?.findRenderObject() as RenderBox;

    double pipeUpBottomY =
        pipeUpBox.localToGlobal(Offset.zero).dy + pipeUpBox.size.height;
    double pipeUpStartX = pipeUpBox.localToGlobal(Offset.zero).dx;
    double pipeUpEndX =
        pipeUpBox.localToGlobal(Offset.zero).dx + pipeUpBox.size.width;

    double pipeDownTopY = pipeDownBox.localToGlobal(Offset.zero).dy;
    double pipeDownStartX = pipeDownBox.localToGlobal(Offset.zero).dx;
    double pipeDownEndX =
        pipeDownBox.localToGlobal(Offset.zero).dx + pipeDownBox.size.width;

    double birdLeft = birdBox.localToGlobal(Offset.zero).dx;
    double birdRight =
        birdBox.localToGlobal(Offset.zero).dx + birdBox.size.width;
    double birdTop = birdBox.localToGlobal(Offset.zero).dy;
    double birdBottom =
        birdBox.localToGlobal(Offset.zero).dy + birdBox.size.height;

    double baseY = baseBox.localToGlobal(Offset.zero).dy;

    if ((birdRight - 20 >= pipeUpStartX &&
            birdTop + 20 <= pipeUpBottomY &&
            birdLeft + 20 <= pipeUpEndX) ||
        (birdRight - 20 >= pipeDownStartX &&
            birdBottom - 20 >= pipeDownTopY &&
            birdLeft + 20 <= pipeDownEndX) ||
        birdTop <= 20 || birdBottom >= baseY) {
      playSound('hit.wav');

      _birdController.removeListener(flapWings);
      _pipeController.removeListener(movePipes);

      _birdController.dispose();
      _pipeController.dispose();

      _birdTimer.cancel();

      Navigator.pop(context, _score);
    }

    if (!_goingToScore && (birdRight >= pipeUpStartX)) {
      setState(() {
        _goingToScore = true;
        _scoreCooldown = false;
      });
    }

    if (_goingToScore && !_scoreCooldown && (birdLeft >= pipeUpEndX)) {
      _scoreCooldown = true;
      setState(() {
        _score += 1;
      });

      playSound('point.wav');

      Timer(const Duration(milliseconds: 400), () {
        setState(() {
          _goingToScore = false;
        });
      });
    }
  }

  void moveUp() {
    if (_paused) return;

    setState(() {
      goingUp = true;
      birdMovement = -12;
    });

    playSound('swoosh.wav');
  }

  void playSound(String name) {
    _player.play('audio/$name');
  }

  void flapWings() {
    if (_paused ||
        _birdController.value.toInt() >= 3 ||
        _birdController.value.toInt() < 0) return;

    setState(() {
      curBirdState = birdStates[_birdController.value.toInt()];
    });
  }

  void movePipes() {
    setState(() {
      pipeX = -_pipeXPos.value;

      if (pipeX <= -90) {
        pipeY = -randGen.nextInt(200) - 200;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _birdController.addListener(flapWings);
    _birdTimer = Timer.periodic(const Duration(milliseconds: 30), updateBird);
  }

  @override
  Widget build(BuildContext context) {
    if (!gotWidth) {
      _pipeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
        lowerBound: 0,
        upperBound: 1,
        animationBehavior: AnimationBehavior.preserve,
      )..repeat();

      _screenSize = MediaQuery.of(context).size;

      _pipeTween = Tween<double>(begin: -(_screenSize.width + 50), end: 100);
      _pipeXPos = _pipeTween.animate(_pipeController);
      _pipeController.addListener(movePipes);

      gotWidth = true;
    }

    return GestureDetector(
      onTap: moveUp,
      behavior: HitTestBehavior.deferToChild,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Background(),
          Positioned(
            key: _keyBird,
            left: 100,
            top: birdHeight,
            child: Transform.rotate(
              angle: (birdMovement * math.pi) / 180 * 3,
              child: Transform.scale(
                scale: 1.7,
                child: Image(
                  width: 100,
                  // height: 112,
                  image:
                      AssetImage('assets/sprites/bluebird-$curBirdState.png'),
                ),
              ),
            ),
          ),
          Positioned(
            key: _keyPipeUp,
            top: pipeY.toDouble(),
            left: pipeX,
            child: Transform.rotate(
              angle: math.pi,
              child: Image.asset(
                'assets/sprites/pipe-green.png',
                scale: 0.6,
              ),
            ),
          ),
          Positioned(
            key: _keyPipeDown,
            bottom: -pipeY.toDouble() - 300,
            left: pipeX,
            child: Image.asset(
              'assets/sprites/pipe-green.png',
              scale: 0.6,
            ),
          ),
          Positioned(
            bottom: -20,
            child: Base(
              key: _keyBase,
              paused: _paused,
            ),
          ),
          Positioned(
            top: 60,
            child: Text(
              '$_score',
              style: const TextStyle(
                fontFamily: 'FlappyFont',
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 60,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 40,
            child: TextButton(
              child: _buttonIcon,
              style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(Colors.green.shade100)),
              onPressed: () {
                setState(() {
                  if (_paused) {
                    _paused = false;
                    _buttonIcon = const Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 50,
                    );

                    _birdController.repeat();
                    _pipeController.repeat();
                  } else {
                    _paused = true;
                    _buttonIcon = const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    );

                    _birdController.stop();
                    _pipeController.stop();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
