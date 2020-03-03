import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
class DrawArea{
  Offset point;
  Paint areaPaint;
  DrawArea({this.point, this.areaPaint});
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DrawArea> points = [];
  Color selectedColor;
  double strokeWidth;

  void selectColor() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromRGBO(138, 35, 135, 1.0),
                Color.fromRGBO(233, 64, 87, 1.0),
                Color.fromRGBO(242, 113, 33, 1.0)
              ])),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                height: MediaQuery.of(context).size.height * 0.80,
                margin: EdgeInsets.only(top: 6.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 1.0),
                    ]),
                child: GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      points.add(DrawArea(point:details.localPosition, areaPaint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true
                        ..strokeCap = StrokeCap.round));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      points.add(DrawArea(point:details.localPosition, areaPaint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true
                        ..strokeCap = StrokeCap.round));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      points.add(null);
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CustomPaint(
                      painter: MyCustomPainter(points: points),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.palette,
                          color: selectedColor,
                        ),
                        onPressed: () {
                          selectColor();
                        }),
                    Expanded(
                        child: Slider(
                            min: 2.0,
                            max: 20.0,
                            activeColor: selectedColor,
                            value: strokeWidth,
                            onChanged: (value) {
                              setState(() {
                                strokeWidth = value;
                              });
                            })),
                    IconButton(
                        icon: Icon(
                          Icons.layers_clear,
                          color: selectedColor,
                        ),
                        onPressed: () {
                          points.clear();
                        })
                  ],
                ),
              )
            ],
          ),
        )
      ],
    ));
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawArea> points;
  Color selectedColor;
  double strokeWidth;
  MyCustomPainter({this.points, this.selectedColor, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    Paint paint;
    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        paint = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x + 1].point, paint);
      } else if (points[x] != null && points[x + 1] == null) {
        paint = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
