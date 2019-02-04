import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../molecules/score_display.dart';
import '../molecules/high_score_display.dart';
import '../atoms/wind.dart';

class PlayingField extends StatefulWidget {
  _PlayingFieldState createState() => _PlayingFieldState();
}

class _PlayingFieldState extends State<PlayingField>
  with TickerProviderStateMixin{

  Animation<double> scoreReducer;
  AnimationController scoreReducerController;

  double score;
  double highScore;
  double difficulty;

  @override
  void initState() {
    score = 0.0;
    highScore = 0.0; //TODO: load highscore from db
    difficulty = 0.1; //TODO: Tune difficulty 0.1 is easy mode for dev

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
        color: Colors.black,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Image.asset(
              'assets/wet_grass_tile.png',
              scale: 3.0,
              width: size.width,
              height: size.height,
              repeat: ImageRepeat.repeat,
              ),
            AnimatedBuilder(
              animation: scoreReducer,
              builder: (conext, child){
                score *= scoreReducer.value;
                return ScoreDisplay(score);
              }
            ),
            HighScoreDisplay(highScore: highScore),
            Wind(size),
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
    double newScore = score + _applyDifficulty(details.delta.dy);
    if(newScore >= score) setState(() => score = newScore);
    else if(punishment >= 0) setState(()=> score = punishment);
    else setState(()=> score = 0);

    if(score > highScore) setState(()=> highScore = score);
  }

  double _applyDifficulty(double dy){
    return dy/(math.pow(score, difficulty) + 1);
  }

  void _youLose(){
    scoreReducerController.forward();
    //TODO: Store highScore to db
  }
}