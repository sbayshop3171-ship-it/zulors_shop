import 'package:flutter/material.dart';

class HorizontalLoader extends StatefulWidget {
  const HorizontalLoader({super.key});

  @override
  HorizontalLoaderState createState() => HorizontalLoaderState();
}

class HorizontalLoaderState extends State<HorizontalLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: false);

    _animations = List.generate(4, (index) {
      final startInterval = index * 0.25;
      final endInterval = startInterval + 0.25;

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(startInterval, endInterval, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return FadeTransition(
            opacity: _animations[index],
            child: Container(
              width: 10,
              height: 10,
              color: Theme.of(context).primaryColor,
            ),
          );
        }),
      ),
    );
  }
}