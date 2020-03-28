import 'package:flutter/material.dart';
import 'package:flutter_opencv/opencv.dart' as cv;
import 'package:camera/camera.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'native_lib.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  DeviceList _devices;

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
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
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
              Tab(text: 'Home', icon: Icon(Icons.home)),
              Tab(
                  text: 'Alerts',
                  icon: BadgedIcon(icon: Icons.error, counter: 100)),
              Tab(text: 'Settings $a', icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Stack(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final size = MediaQuery.of(context).size;
                      print(size);
                      print(_controller.value.aspectRatio);

                      // If the Future is complete, display the preview.
                      return NativeDeviceOrientationReader(
                          useSensor: true,
                          builder: (context) {
                            NativeDeviceOrientation orientation =
                                NativeDeviceOrientationReader.orientation(
                                    context);
                            print("Received new orientation: $orientation");

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

							final aspectRatio = _controller.value.aspectRatio;
                            return Transform.scale(
                              scale: _controller.value.aspectRatio /
                                  size.aspectRatio,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: RotatedBox(
                                      quarterTurns: turns,
                                      child: CameraPreview(_controller)),
                                ),
                              ),
                            );
                          });
                      // return Container(width: size.width, height: size.height, color: Colors.blue);
                    } else {
                      // Otherwise, display a loading indicator.
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: Column(
                    children: [
                      Padding(
                        child: Text('Rotation: $rotation°',
                            style: const TextStyle(fontSize: 18)),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      Container(
                        child: Text('Remaining: $remaining',
                            style: const TextStyle(fontSize: 18)),
                        padding: EdgeInsets.only(bottom: 16.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Center(
              child: Text(
                'No alerts',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            Center(
              child: Text(
                'No setting ?',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
