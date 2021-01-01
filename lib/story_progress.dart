library story_progress;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status { next, previous, completed }

class Controller {
  void skip() {}

  void previous() {}
}

/// This is the stateful widget that the main application instantiates.
class StoryProgress extends StatefulWidget {
  StoryProgress(
      {Key key,
        this.play = false,
        this.progressCount = 1,
        this.duration = const Duration(seconds: 8),
        this.width = 200.0,
        @required this.onStatusChanged,
        this.color = Colors.black})
      : super(key: key);

  final bool play;

  final int progressCount;

  final Duration duration;

  final double width;

  final Function onStatusChanged;

  final Color color;

  @override
  StoryProgressState createState() => StoryProgressState();

// static StoryProgressState of(BuildContext context) => context.findAncestorStateOfType<StoryProgressState>();
}


class StoryProgressState extends State<StoryProgress>
    with TickerProviderStateMixin {
  AnimationController _controller;

  double _width;

  ProgressContainer spinningContainer;

  int _progressCount;

  @override
  void initState() {
    super.initState();

    _progressCount = widget.progressCount;
    _width=widget.width-10;
    if (_progressCount>1) {
      _width = _width - (2 * _progressCount);
    }
    _width = _width / _progressCount;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    spinningContainer = ProgressContainer(
        progressCount: _progressCount,
        width: _width,
        color: widget.color,
        statusChanged: (status) {
          widget.onStatusChanged(status);
        },
        controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.play)
      _controller.forward();
    else
      _controller.stop();
    return spinningContainer;
  }

  void skip() {
    spinningContainer.forward();
  }

  void previous() {
    spinningContainer.previous();
  }
}

class ProgressContainer extends AnimatedWidget implements Controller {
  final int progressCount;
  final double width;
  final AnimationController controller;
  int currentIndex = 0;
  final Function statusChanged;
  bool isCompleted = false;
  final Color color;

  ProgressContainer(
      {Key key,
        this.statusChanged,
        this.progressCount,
        this.color,
        this.width,
        this.controller})
      : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < progressCount; i++) _buildProgress(width, i),
      ],
    );
  }

  @override
  void previous() {
    if (currentIndex > 0) {
      currentIndex--;
      controller.reset();
      controller.forward();
      statusChanged(Status.previous);
      isCompleted = false;
    }
  }

  void forward() {
    if (currentIndex == progressCount - 1) {
      print('finished'); //completed
      if (!isCompleted) {
        statusChanged(Status.completed);
        isCompleted = true;
      }
    } else {
      currentIndex++;
      controller.reset();
      controller.forward();
      statusChanged(Status.next);
    }
  }

  @override
  void skip() {
    forward();
  }

  Row _buildProgress(double width, int index) {
    if (_progress.value > 0.99 && controller.isAnimating) {
      if (progressCount == 1 || currentIndex != index) forward();
    }

    return Row(
      children: [
        Stack(
          children: [
            index == 0
                ? SizedBox(
              width: 5,
            )
                : Container(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: color.withOpacity(0.3),
                width: width,
                height: 4,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: color,
                width: currentIndex == index
                    ? width * _progress.value
                    : (index < currentIndex ? width : 0),
                height: 4,
              ),
            ),
          ],
        ),
        progressCount > 1 && index != progressCount - 1
            ? SizedBox(
          width: 2,
        )
            : SizedBox(
          width: 5,
        ),
      ],
    );
  }
}

