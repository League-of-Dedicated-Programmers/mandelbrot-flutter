import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FragmentShader mandelbrotShader;
  final minX = -2.0;
  final maxX = 0.25;
  final minY = -1.0;
  final maxY = 1.0;

  Offset center = Offset.zero;

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  Offset _offset = Offset.zero;

  Future<FragmentShader> createShader() async {
    final program = await FragmentProgram.fromAsset('shaders/mandelbrot.frag');
    return program.fragmentShader();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (details) {
          _baseScaleFactor = _scaleFactor;
        },
        onScaleUpdate: (details) {
          setState(() {
            if (details.focalPointDelta == Offset.zero) {
              _scaleFactor = _baseScaleFactor * details.scale;
              // _offset = Offset((details.focalPoint.dx / size.width),
              //     (details.focalPoint.dy / size.height) + 1.0);
              return;
            }
            _offset += Offset((details.focalPointDelta.dx) / size.width,
                details.focalPointDelta.dy / size.height);
          });
        },
        child: FutureBuilder<FragmentShader>(
            future: createShader(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('loading');
              }
              return CustomPaint(
                size: size,
                painter: MandelbrotPainter(
                    shader: snapshot.data!,
                    size: size,
                    scale: _scaleFactor,
                    offset: _offset),
              );
            }),
      ),
    );
  }
}

class MandelbrotPainter extends CustomPainter {
  final double scale;
  final Offset offset;
  final Size size;
  final FragmentShader shader;
  MandelbrotPainter(
      {required this.shader,
      required this.size,
      required this.scale,
      required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, 1 / scale);
    shader.setFloat(3, offset.dx);
    shader.setFloat(4, offset.dy);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
