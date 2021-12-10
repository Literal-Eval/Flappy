// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class Base extends StatefulWidget {
  Base({Key? key, required this.paused}) : super(key: key);

  bool paused;

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      lowerBound: 0,
      upperBound: 1000)
    ..repeat(reverse: false);

  late final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: true);

  void moveBase() {
    if (widget.paused) return;

    _scrollController.animateTo(_controller.value / 2,
        duration: const Duration(milliseconds: 1), curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(moveBase);
  }

  @override
  void deactivate() {
    _controller.removeListener(moveBase);
    _controller.dispose();
    _scrollController.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 190,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            width: 500,
            height: 70,
            decoration: const BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.bottomCenter,
                fit: BoxFit.fitWidth,
                image: AssetImage('assets/sprites/base.png'),
              ),
            ),
          );
        },
      ),
    );
  }
}
