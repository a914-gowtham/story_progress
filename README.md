# Story Progress

[![pub package](https://img.shields.io/pub/v/story_progress.svg)](https://pub.dartlang.org/packages/story_progress)

A package provides an easy way to show horizontal progress like instagram stories in Flutter project

<p>
    <img src="https://github.com/a914-gowtham/story_progress/blob/master/screenshots/demo1.gif?raw=true?size=200" width="250" height="480"/>
</p>

## How to use

```dart
import 'package:story_progress/story_progress.dart';

```

```dart
  var _formKey = GlobalKey<StoryProgressState>(); 
  var _play = false;

StoryProgress(
       key: _formKey,
       progressCount: 4,
       width: width,
       duration: Duration(seconds: 3),
       onStatusChanged: (value) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (value) {
             case Status.next:
              //       
             break;
             case Status.previous:
              //
             break;
             case Status.completed:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Stories completed'),
                          duration: Duration(seconds: 1),
               ));
             break;
             }
           });
       },
)

```

###  Skip and Previous story
Use this function on onPressed event

```dart

_formKey.currentState.skip();
_formKey.currentState.previous();

```

###  Pause and Resume(start) story
Use this function on onPressed event

```dart

  _formKey.currentState.pause();
  _formKey.currentState.resume(); //

```









