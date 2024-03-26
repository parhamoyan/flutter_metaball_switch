import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class MetaballSwitch extends StatefulWidget {
  const MetaballSwitch({Key? key}) : super(key: key);

  @override
  _MetaballSwitchState createState() => _MetaballSwitchState();
}

class _MetaballSwitchState extends State<MetaballSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Future<FragmentProgram> _fragmentProgramFuture;

  late Animation<double> leftCircleXAnimation;
  late Animation<double> rightCircleXAnimation;
  late Animation<double> leftCircleRadiusAnimation;
  late Animation<double> rightCircleRadiusAnimation;
  late Animation<Color?> colorAnimation;

  double leftCircleX = 48;
  double rightCircleX = 48;
  double leftCircleRadius = .6;
  double rightCircleRadius = .6;

  Color toggleBodyColor = const Color(0xFF727272);
  Color toggyBodySecondColor = const Color(0xFF6FE7F9);

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _fragmentProgramFuture = _initFragmentProgram();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    rightCircleXAnimation = Tween<double>(
      begin: 48,
      end: 164,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    leftCircleXAnimation = Tween<double>(
      begin: 48,
      end: 164,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    leftCircleRadiusAnimation = Tween<double>(
      begin: 0.6,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 0.9, curve: Curves.easeInOutSine),
      ),
    );

    rightCircleRadiusAnimation = Tween<double>(
      begin: 0.6,
      end: 0.7,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    colorAnimation = ColorTween(
      begin: toggleBodyColor,
      end: toggyBodySecondColor,
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<FragmentProgram> _initFragmentProgram() async {
    return FragmentProgram.fromAsset('assets/shaders/metaball_shader.frag');
  }

  void _animate() {
    if (isChecked) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    isChecked = !isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363C3D),
      body: FutureBuilder<FragmentProgram>(
        future: _fragmentProgramFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SizedBox());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final fragmentProgram = snapshot.data!;
            return _buildSwitch(fragmentProgram);
          }
        },
      ),
    );
  }

  Widget _buildSwitch(FragmentProgram fragmentProgram) {
    return Center(
      child: GestureDetector(
        onTap: () {
          _animate();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(208, 90),
              painter: MyCustomPainter(
                Colors.green,
                fragmentProgram: fragmentProgram,
                leftCircleX: leftCircleXAnimation.value,
                rightCircleX: rightCircleXAnimation.value,
                leftCircleRadius: leftCircleRadiusAnimation.value,
                rightCircleRadius: rightCircleRadiusAnimation.value,
                toggleBodyColor: colorAnimation.value!,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter(
    this.color, {
    required this.fragmentProgram,
    required this.leftCircleX,
    required this.rightCircleX,
    required this.leftCircleRadius,
    required this.rightCircleRadius,
    required this.toggleBodyColor,
  }) : shader = fragmentProgram.fragmentShader(); // Register animation controller for repaint

  final Color color;
  final FragmentProgram fragmentProgram;
  final FragmentShader shader;
  final double leftCircleX;
  final double rightCircleX;
  final double leftCircleRadius;
  final double rightCircleRadius;
  final Color toggleBodyColor;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width); // iResolution x
    shader.setFloat(1, size.height); // iResolution y
    shader.setFloat(2, leftCircleX); // left circle x pos
    shader.setFloat(3, rightCircleX); // right circle x pos
    shader.setFloat(4, leftCircleRadius); // left circle radius
    shader.setFloat(5, rightCircleRadius); // right circle radius

    Paint rrectPaint = Paint();
    rrectPaint.style = PaintingStyle.fill;
    rrectPaint.color = toggleBodyColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    canvas.drawRRect(rrect, rrectPaint);
    Paint paint = Paint()..shader = shader;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
