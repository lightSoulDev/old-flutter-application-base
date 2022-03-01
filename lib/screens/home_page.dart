import 'package:appbase/app_localizations.dart';
import 'package:appbase/support/constants.dart';
import 'package:appbase/tcp/client_tcp.dart';
import 'package:appbase/screens/net_splash.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  static const double _mult = 1;
  static bool _canBeDragged = false;
  static const double _minDragStartEdge = 75;

  @override
  void initState() {
    ClientTCP.setCallback(this.onServerData);
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
  }

  void close() => animationController.reverse();

  void open() => animationController.forward();

  void toggle() => animationController.isCompleted ? close() : open();

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed &&
      details.globalPosition.dx < _minDragStartEdge;
    bool isDragCloseFromRight = animationController.isCompleted &&
      details.globalPosition.dx > MediaQuery.of(context).size.width * (_mult - 0.3);

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / (MediaQuery.of(context).size.width * _mult);
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted)
      return;
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  void onServerData(data) async {
    print("onServerData: $data");
    if (data == NetProtocol.CONNECTION_ERROR) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NetworkSplashScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var drawer = Stack(
        children: <Widget>[
        Container(color: Colors.blueAccent),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  (AppLocalizations.of(context)?.translate("{l|SETTINGS}") ?? ""),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    var content = Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: 80,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: 30,
                        ),
                        onPressed: toggle,
                      ),
                      Text(
                        (AppLocalizations.of(context)?.translate("{l|MENU}") ?? ""),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 30,
                        ), onPressed: () {  },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, snapshot) {
          double slide = MediaQuery.of(context).size.width * _mult * animationController.value;
          double scale = 1 - (animationController.value * 0.3);
          return Scaffold(
            body: Stack(
              children: <Widget>[
                drawer,
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slide)
                    ..scale(scale)
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-pi/2 * animationController.value),
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Opacity(
                            opacity: animationController.value >= 0.75
                                ? 1
                                : 0,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blueAccent,
                              size: 200,
                            ),
                          )
                        ),
                      ),
                      Opacity(
                        opacity: animationController.value >= 0.75
                          ? 0
                          : 1 - animationController.value,
                        child: content
                      )
                    ],
                  ),
                )
              ],
            )
          );
        },
      ),
    );
  }
}