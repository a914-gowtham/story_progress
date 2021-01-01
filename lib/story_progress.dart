library story_progress;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///[Status] enum used for tracking story changes
enum Status { next, previous, completed }

class Controller {
  void skip() {}

  void previous() {}
}

/// This is the stateful widget that the main application instantiates.
class StoryProgress extends StatefulWidget {
  StoryProgress(
      {Key key,
      this.progressCount = 1,
      this.duration = const Duration(seconds: 8),
      this.width = 200.0,
      @required this.onStatusChanged,
      this.color = Colors.black})
      : super(key: key);

  final int progressCount;

  final Duration duration;

  final double width;

  final Function onStatusChanged;

  final Color color;

  @override
  StoryProgressState createState() => StoryProgressState();

// static StoryProgressState of(BuildContext context) => context.findAncestorStateOfType<StoryProgressState>();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class StoryProgressState extends State<StoryProgress>
    with TickerProviderStateMixin {
  AnimationController _controller;

  ProgressContainer spinningContainer;

  int _progressCount;

  @override
  void initState() {
    super.initState();

    _progressCount = widget.progressCount;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    spinningContainer = ProgressContainer(
        progressCount: _progressCount,
        width: widget.width,
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
    return spinningContainer;
  }

  void skip() {
    spinningContainer.forward();
  }

  void previous() {
    spinningContainer.previous();
  }

  void resetCurrentProgress() {
    spinningContainer.resetCurrentProgress();
  }

  void resetAllProgress() {
    spinningContainer.resetAllProgress();
  }

  void pause() {
    if (_controller.isAnimating) _controller.stop();
  }

  void resume() {
    _controller.forward();
  }

  bool isPlaying() => _controller.isAnimating;
}

//ProgressContainer contains all the progress widgets.
///It is using [AnimatedWidget] to animate progress with timer
///For read more about animatedWidget refer this [https://api.flutter.dev/flutter/widgets/AnimatedWidget-class.html]
// ignore: must_be_immutable
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
    double _width = width - 6; //front and back margin
    if (progressCount > 1) {
      _width = _width - (2 * progressCount); //margin b/w two progress
    }
    _width = _width / progressCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < progressCount; i++) _buildProgress(_width, i),
      ],
    );
  }

  ///This function navigates to previous story.
  ///Only if [currentIndex] is greater than zero
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

  ///This function navigates to next story.
  ///If current story index is equals to [progressCount]-1 that means it is in last progress,
  ///So, [statusChanged] to Status.completed
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

  void resetCurrentProgress() {
    controller.reset();
  }

  void resetAllProgress() {
    controller.reset();
    currentIndex = 0;
  }

  @override
  void skip() {
    forward();
  }

  ///This function return single progress view
  ///[width] is divided by [progressCount]
  Row _buildProgress(double width, int index) {
    if (_progress.value > 0.99 && controller.isAnimating) {
      if (progressCount == 1 || currentIndex != index) forward();
    }

    return Row(
      children: [
        index == 0
            ? SizedBox(
                width: 3,
              )
            : Container(),
        Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: new BoxDecoration(
                  color: color.withOpacity(0.3),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                width: width,
                height: 4,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: new BoxDecoration(
                  color: color,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
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
                width: 3,
              ),
      ],
    );
  }
}
