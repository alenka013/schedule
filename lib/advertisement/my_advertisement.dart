import 'package:flutter/material.dart';
import 'package:raspisanie/id_selection_screen%20.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

class MyAdvertisement extends StatefulWidget {
  final String? displayId;
  MyAdvertisement({this.displayId});

  @override
  State<MyAdvertisement> createState() => MyAdvertisementState();
}

class MyAdvertisementState extends State<MyAdvertisement> {
  late VideoPlayerController _controller;
  late final Random _random = Random();
  int _randomVideoIndex = 1;

  @override
  void initState() {
    super.initState();
    _randomVideoIndex = _random.nextInt(3) + 1;
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        setState(() {
          _controller.setVolume(0);
          _controller.play();
        });
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IdSelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
