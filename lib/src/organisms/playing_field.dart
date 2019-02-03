import 'package:flutter/material.dart';
import '../molecules/score_display.dart';
import 'dart:math' as math;

class PlayingField extends StatefulWidget {
  _PlayingFieldState createState() => _PlayingFieldState();
}

class _PlayingFieldState extends State<PlayingField>
  with TickerProviderStateMixin{

  Animation<double> scoreReducer;
  AnimationController scoreReducerController;

  double score;
  double difficulty;

  @override
  void initState() {
    score = 0.0;
    difficulty = 0.8; //TODO: Tune difficulty 0.1 is easy mode for dev

    scoreReducerController = AnimationController(
      duration: Duration(
        milliseconds: math.max( (400 - difficulty*300).round(), 50 ) 
      ),
      vsync: this
    );
    scoreReducer = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: scoreReducerController,
        curve: Curves.linear
      )
    );

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onVerticalDragStart:(details) => _placeFinger(details),
      onVerticalDragUpdate: (details) => _onDrag(details),
      onVerticalDragEnd: (details) => _liftFinger(details),
      child: Container(
        alignment: AlignmentDirectional.center,
        width: size.width,
        height: size.height,
        color: Colors.yellow,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: scoreReducer,
              builder: (conext, child){
                score *= scoreReducer.value;
                return ScoreDisplay(score);
              }
            )
          ],
        ),
      ),
    );
  }

  void _liftFinger(DragEndDetails details) => _youLose();

  void _placeFinger(DragStartDetails details){
    scoreReducerController.reset();
  }

  void _onDrag(DragUpdateDetails details){
    double punishment = score + details.delta.dy/((difficulty*10).round());
    double newScore = score + details.delta.dy/(math.pow(score, difficulty) + 1);
    if(newScore >= score) setState(() => score = newScore);
    else if(punishment >= 0) setState(()=> score = punishment);
    else setState(()=> score = 0);
  }

  void _youLose(){
    scoreReducerController.forward();
  }
}