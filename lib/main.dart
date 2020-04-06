import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_opencv/opencv.dart' as cv;
import 'package:camera/camera.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'native_lib.dart';
import 'visualisation.dart';
import 'settings.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key key, @required this.cameras}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCV Ventilator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'OpenCV Ventilator', cameras: cameras),
    );
  }
}

class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int counter;

  const BadgedIcon({Key key, @required this.icon, @required this.counter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (counter == 0) {
      return Icon(icon);
    }
    String badge =
    (counter >= 100) ? '99+' : (counter >= 50) ? '50+' : '$counter';
    return Stack(
      children: <Widget>[
        Container(
          width: 80,
          height: 24,
          child: Icon(icon),
        ),
        Positioned(
          right: 0,
          child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 20,
              minHeight: 12,
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;

  MyHomePage({Key key, @required this.title, @required this.cameras})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  DeviceList _devices;
  SettingsForm _settings;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras.first,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    _devices = NativeLib.listDevices();
    print(_devices);
    _settings = new SettingsForm(
      onUpdate: (context) {
        warn(context, 'bob');
      }
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> warn(BuildContext context, String msg) async {
    await _devices.a(context);
    FlutterRingtonePlayer.playAlarm(volume: 1.0);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Major error'),
          backgroundColor: Colors.red,
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('I\'v check that everything is ok'),
              onPressed: () {
                FlutterRingtonePlayer.stop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int rotation = 0;
    final int remaining = 0;
    final String a = _devices.get(1);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: <Tab>[
              Tab(text: 'Camera', icon: Icon(Icons.camera)),
              Tab(
                  text: 'Sensors',
                  icon: BadgedIcon(icon: Icons.assessment, counter: 100)),
              Tab(text: 'Settings $a', icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Stack(
              children: [
                Container(color: Colors.black),
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final size = MediaQuery
                        .of(context)
                        .size;

                    // If the Future is complete, display the preview.
                    return NativeDeviceOrientationReader(
                      useSensor: true,
                      builder: (context) {
                        NativeDeviceOrientation orientation =
                        NativeDeviceOrientationReader.orientation(
                            context);

                        int turns;
                        switch (orientation) {
                          case NativeDeviceOrientation.landscapeLeft:
                            turns = -1;
                            break;
                          case NativeDeviceOrientation.landscapeRight:
                            turns = 1;
                            break;
                          case NativeDeviceOrientation.portraitDown:
                            turns = 2;
                            break;
                          default:
                            turns = 0;
                            break;
                        }
                        Size imageSize = _controller.value.previewSize;
                        double zoomIfVertical;
                        double zoomIfHorizontal;
                        if (turns % 2 == 1) {
                          zoomIfVertical = size.width / imageSize.width;
                          zoomIfHorizontal = size.height / imageSize.height;
                        } else {
                          zoomIfVertical = size.width / imageSize.height;
                          zoomIfHorizontal = size.height / imageSize.width;
                        }
                        print('v: $zoomIfVertical, h: $zoomIfHorizontal');

                        return Transform.scale(
                          scale: min(1 / zoomIfVertical, 1 / zoomIfHorizontal),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: turns,
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: CameraPreview(_controller),
                              ),
                            ),
                          ),
                        );
                        /*return Container(color: Colors.green, constraints: BoxConstraints(
                            maxHeight: size.height,
                            maxWidth: size.width,
                            minWidth: size.width,
                            minHeight: size.height,
                        ));*/
                      });
                  },
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),
                    child: Column(
                      children: [
                        Text('Rotation: $rotation°',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .body2),
                        new SizedBox(height: 8),
                        Text('Pressure: $remaining mbar',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .body2),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(15.0),
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Pressure (mbar)',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline,
                          ),
                          new SizedBox(
                            height: 200.0,
                            child: TimeSeries.withSampleData(),
                          ),
                          Text(
                            'Measure: 40 mbar',
                            style: Theme
                                .of(context)
                                .textTheme
                                .title,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Airflow (L/min)',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline,
                          ),
                          new SizedBox(
                            height: 200.0,
                            child: TimeSeries.withSampleData(),
                          ),
                          Text(
                            'Measure: 40 L/min',
                            style: Theme
                                .of(context)
                                .textTheme
                                .title,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Plateau pressure (mbar)',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Measure: 30 L/min',
                            style: Theme
                                .of(context)
                                .textTheme
                                .title,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(child: Container(
              padding: EdgeInsets.all(15.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _settings
                ),
              ),
            )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(Icons.pause),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

}
