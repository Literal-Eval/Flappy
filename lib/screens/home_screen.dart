import 'package:flappy/screens/game_screen.dart';
import 'package:flappy/widgets/base.dart';
import 'package:flutter/material.dart';
import 'background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _score = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );

        setState(() {});
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Background(),
          Transform.scale(
            scale: 1.5,
            child: const Image(
              image: AssetImage('assets/sprites/message.png'),
            ),
          ),
          Positioned(
            bottom: -20,
            child: Base(
              paused: false,
            ),
          ),
          Positioned(
            bottom: 30,
            child: Text(
              '$_score',
              style: const TextStyle(
                fontFamily: 'FlappyFont',
                color: Colors.black87,
                decoration: TextDecoration.none,
                fontSize: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
