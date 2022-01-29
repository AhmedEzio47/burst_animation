import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: MaterialButton(
          color: Colors.red,
          onPressed: () => Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, animation, _) => const SecondPage(),
              opaque: false)),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TweenAnimationBuilder(
        builder: (context, value, child) {
          return ShaderMask(
              child: child,
              shaderCallback: (rect) {
                return RadialGradient(
                    colors: const [
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                      Colors.transparent
                    ],
                    center: const FractionalOffset(.5, .5),
                    radius: (value as double) * 5,
                    stops: const [0, .55, .66, 1]).createShader(rect);
              });
        },
        child: Container(
          color: Colors.red,
        ),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
