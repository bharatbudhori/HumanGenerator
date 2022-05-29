import 'dart:typed_data';
import 'dart:ui' as ui;
import "package:flutter/material.dart";
import 'package:human_generator/drawingarea.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DrawingArea> points = [];
  Widget? imageOutput;

  void saveToImage(List<DrawingArea> points) async {
    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(200, 200)));
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint2);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != points.last && points[i + 1] != points.last) {
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);

    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final listBytes = Uint8List.view(pngBytes!.buffer);

    String base64Image = base64Encode(listBytes);
    fetchResponse(base64Image);
  }

  void fetchResponse(var base64Image) async {
    var data = {"Image": base64Image};

    print('Started Request');

    var url = Uri.parse("http://192.168.0.109:5000/predict");

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Connection": "Keep-Alive",
    };

    var body = json.encode(data);
    try {
      var response = await http.post(url, body: body, headers: headers);
      final Map<String, dynamic> responseData = json.decode(response.body);
      String outputBytes = responseData["Image"];
      print(outputBytes.substring(2, outputBytes.length - 1));
    } catch (e) {
      print(" * Error had Occured");
      return null;
    }
  }

  void diplayResponseImage(String byes) async {
    Uint8List convertedBytes = base64.decode(byes);
    setState(() {
      imageOutput = Container(
        width: 256,
        height: 256,
        child: Image.memory(
          convertedBytes,
          fit: BoxFit.cover,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5.0,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onPanDown: (details) {
                        setState(() {
                          points.add(
                            DrawingArea(
                                point: details.localPosition,
                                arreaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0),
                          );
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          points.add(
                            DrawingArea(
                                point: details.localPosition,
                                arreaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = Colors.white
                                  ..strokeWidth = 2.0),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        saveToImage(points);
                        setState(
                          () {
                            DrawingArea x = points.last;
                            points.add(x);
                          },
                        );
                      },
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: CustomPaint(
                            painter: MyCustomPainter(points: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            points.clear();
                          });
                        },
                        icon: const Icon(
                          Icons.layers_clear,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    child: Center(
                      child: Container(
                        height: 256,
                        width: 256,
                        child: imageOutput,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
