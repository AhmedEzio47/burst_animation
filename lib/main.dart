import 'dart:async';
import 'dart:math';

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
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Color> colors = [
    const Color(0xFF7E57C2),
    const Color(0xFF5E35B1),
    const Color(0xFF4527A0),
    const Color(0xFF311B92)
  ];
  final GlobalKey _boxKey = GlobalKey();
  final Random random = Random();
  final double gravity = 9.81,
      dragCof = 0.47,
      airDensity = 1.1644,
      fps = 1 / 24;
  late Timer timer;
  Rect boxSize = Rect.zero;
  List<Particle> particles = [];
  dynamic counterText = {"color": const Color(0xFF7E57C2)};

  @override
  void dispose() {
    // Cancel and Dispose off timer and Animation Controller
    timer.cancel();
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // AnimationController for initial Burst Animation of Text
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    // Getting the Initial size of Container as soon as the First Frame Renders
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Size size = _boxKey.currentContext!.size!;
      boxSize = Rect.fromLTRB(0, 0, size.width, size.height);
    });

    // Refreshing State at Rate of 24/Sec
    timer = Timer.periodic(
        Duration(milliseconds: (fps * 1000).floor()), frameBuilder);

    super.initState();
  }

  _animationListener() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  frameBuilder(dynamic timestamp) {
    // Looping though particles to calculate their new position
    particles.forEach((pt) {
      //Calculating Drag Force (DRAG FORCE HAS TO BE NEGATIVE - MISSED THIS IN THE TUTORIAL)
      double dragForceX =
          -0.5 * airDensity * pow(pt.velocity.x, 2) * dragCof * pt.area;
      double dragForceY =
          -0.5 * airDensity * pow(pt.velocity.y, 2) * dragCof * pt.area;

      dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
      dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;

      // Calculating Acceleration
      double accX = dragForceX / pt.mass;
      double accY = gravity + dragForceY / pt.mass;

      // Calculating Velocity Change
      pt.velocity.x += accX * fps;
      pt.velocity.y += accY * fps;

      // Calculating Position Change
      pt.position.x += pt.velocity.x * fps * 100;
      pt.position.y += pt.velocity.y * fps * 100;

      //TODO uncomment this to make particles vanish beyond boundaries
      boxCollision(pt);
    });

    if (particles.isNotEmpty) {
      setState(() {});
    }
  }

  burstParticles() {
    // Removing Some Old particles each time FAB is Clicked (PERFORMANCE)
    if (particles.length > 200) {
      particles.removeRange(0, 75);
    }

    _animationController.forward();
    _animationController.addListener(_animationListener);

    double colorRandom = random.nextDouble();

    Color color = colors[(colorRandom * colors.length).floor()];
    Color prevColor = counterText['color'];
    counterText['color'] = color;
    int count = random.nextInt(25).clamp(15, 25);

    for (int x = 0; x < count; x++) {
      double randomX = random.nextDouble() * 4.0;
      if (x % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = random.nextDouble() * -7.0;
      Particle p = Particle();
      p.radius = (random.nextDouble() * 10.0).clamp(2.0, 5.0);
      p.color = prevColor;
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX, randomY);
      particles.add(p);
    }
  }

  boxCollision(Particle pt) {
    // Collision with Right of the Box Wall
    if (pt.position.x > boxSize.width - pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = boxSize.width - pt.radius;
    }
    // Collision with Bottom of the Box Wall
    // Collision with Bottom of the Box Wall
    if (pt.position.y > boxSize.height - pt.radius) {
      pt.velocity.y *= pt.jumpFactor;
      pt.position.y = boxSize.height - pt.radius;
    }
    // Collision with Left of the Box Wall
    if (pt.position.x < pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = pt.radius;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 250,
          width: 250,
          key: _boxKey,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple, width: 1)),
          child: Stack(
            children: [
              ...particles.map((pt) {
                return Positioned(
                    top: pt.position.y,
                    left: pt.position.x,
                    child: Container(
                      width: pt.radius * 2,
                      height: pt.radius * 2,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: pt.color),
                    ));
              }).toList()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: burstParticles,
        backgroundColor: counterText['color'],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PVector {
  double x, y;

  PVector(this.x, this.y);
}

class Particle {
  String text = "";
  PVector position = PVector(0.0, 0.0);
  PVector velocity = PVector(0.0, 0.0);
  double mass = 10.0; //Kg
  double radius = 10 / 100; // 1m = 100 pt or px
  double area = 0.0314; //PI x R x R;
  double jumpFactor = -0.6;
  Color color = Colors.deepPurple;
}
