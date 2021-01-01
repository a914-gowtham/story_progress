import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:story_progress/story_progress.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var isPlaying = false;

  var _formKey = GlobalKey<StoryProgressState>();

  var imageList = [
    'assets/images3.jpeg',
    'assets/cyberpunk1.jpeg',
    'assets/cyberpunk2.jpg',
    'assets/images4.jpeg'
  ];
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StoryProgress(
                key: _formKey,
                progressCount: 4,
                width: width,
                duration: Duration(seconds: 4),
                onStatusChanged: (value) {
                  print("onStatusChanged $value");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    switch (value) {
                      case Status.next:
                        setState(() {
                          _currentIndex++;
                        });
                        break;
                      case Status.previous:
                        setState(() {
                          _currentIndex--;
                        });
                        break;
                      case Status.completed:
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Stories completed'),
                          duration: Duration(seconds: 2),
                        ));
                        break;
                    }
                  });
                },
              ),
              Spacer(),
              Image.asset(
                imageList[_currentIndex],
                width: 300,
                height: 200,
              ),
              IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    _formKey.currentState.skip();
                    setState(() {
                      _currentIndex = 0;
                      isPlaying = false;
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    _formKey.currentState.previous();
                    setState(() {
                      isPlaying = false;
                    });
                  }),
              Spacer(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: () {
            if (_formKey.currentState.isPlaying()) {
              _formKey.currentState.pause();
              isPlaying = false;
            } else {
              isPlaying = true;
              _formKey.currentState.resume();
            }
            setState(() {});
          },
        ));
  }
}
