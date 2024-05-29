import 'dart:async';

import 'package:flutter/material.dart';

import 'widgets/custom_shape_border.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  final destination = GlobalKey();
  final elementKeyOne = GlobalKey();
  final elementKeyTwo = GlobalKey();
  late AnimationController _topController;
  late AnimationController _itemController;
  late AnimationController _targetController;
  late AnimationController _hintController;
  late Animation<double> _zoomAnimation;
  late Animation<double> _zoomTargetAnimation;
  late Animation<double> _zoomContainerTargetAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _floatAnimation;
  Timer? _timer;
  double _turns = 0.0;
  bool _isChangeColor = false;
  bool _visibleTop = false;
  bool _visibleBottom = false;
  bool _moving = false;
  Offset _offset = Offset.zero;
  int maxValue = 10;
  int currentValue = 2;
  Offset _offsetOne = Offset.zero;
  Offset _offsetTwo = Offset.zero;

  @override
  void initState() {
    super.initState();
    _topController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _itemController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _targetController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _zoomAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.9)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
    ]).animate(_itemController);

    _zoomTargetAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.8)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.8)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
    ]).animate(_targetController);

    _zoomContainerTargetAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.95)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.95, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.95)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.95, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
    ]).animate(_targetController);

    _opacityAnimation = Tween(begin: 0.5, end: 1.0).animate(_topController);

    _floatAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 10, end: 0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 10)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1),
    ]).animate(_hintController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _phaseOne();
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        _phaseTwo();
      });
      Future.delayed(const Duration(milliseconds: 2500), () {
        _phaseThree();
      });
      Future.delayed(const Duration(milliseconds: 3300), () {
        _phaseFour();
      });
      Future.delayed(const Duration(milliseconds: 4000), () {
        setState(() {
          _visibleBottom = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _topController.dispose();
    _itemController.dispose();
    _targetController.dispose();
    _hintController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _phaseOne() {
    _topController.forward(from: 0.0);
    setState(() {
      _offset = const Offset(0, -0.1);
      _visibleTop = !_visibleTop;
    });
  }

  void _phaseTwo() {
    final RenderBox renderBoxOne =
        elementKeyOne.currentContext?.findRenderObject() as RenderBox;
    final onePos = renderBoxOne.localToGlobal(Offset.zero);
    final RenderBox renderBoxTwo =
        elementKeyTwo.currentContext?.findRenderObject() as RenderBox;
    final twoPos = renderBoxTwo.localToGlobal(Offset.zero);

    setState(() {
      _offsetOne = Offset(onePos.dx, onePos.dy);
      _offsetTwo = Offset(twoPos.dx, twoPos.dy);
    });

    _itemController.forward(from: 0.0);
    _itemController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _turns = -0.02;
        });
      }
    });
  }

  void _phaseThree() {
    final RenderBox renderBoxDes =
        destination.currentContext?.findRenderObject() as RenderBox;
    final desPos = renderBoxDes.localToGlobal(Offset.zero);
    setState(() {
      _moving = true;
      _offsetOne = Offset(desPos.dx, desPos.dy);
      _offsetTwo = Offset(desPos.dx, desPos.dy);
      currentValue += 2;
    });
  }

  void _phaseFour() {
    _startColorChange();
    _targetController.forward(from: 0.0);
    _hintController.forward(from: 0.0);
    _hintController.repeat();
  }

  void _startColorChange() {
    int colorChangeCount = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _isChangeColor = !_isChangeColor;
      });
      colorChangeCount++;
      if (colorChangeCount == 4) {
        _timer?.cancel();
      }
    });
  }

  void _reset() {
    setState(() {
      _turns = 0.0;
      _visibleTop = false;
      _moving = false;
      _offset = Offset.zero;
      maxValue = 10;
      currentValue = 2;
      _offsetOne = Offset.zero;
      _offsetTwo = Offset.zero;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _phaseOne();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _phaseTwo();
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      _phaseThree();
    });
    Future.delayed(const Duration(milliseconds: 3300), () {
      _phaseFour();
    });
  }

  Widget _buildAnimatedImage(
    String assetPath,
    Animation<double> opacityAnimation,
    Key key,
  ) {
    return Opacity(
      key: key,
      opacity: 0.5,
      child: Image.asset(
        assetPath,
        width: 100,
        height: 100,
      ),
    );
  }

  Widget _buildNonAnimatedImage(
    String assetPath,
    Animation<double> opacityAnimation,
  ) {
    return Opacity(
      opacity: 0.5,
      child: Image.asset(
        assetPath,
        width: 100,
        height: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSlide(
                  offset: _offset,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: _visibleTop ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Animation',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Example',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white24,
                                Colors.black12,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildAnimatedImage(
                                'assets/new.png',
                                _opacityAnimation,
                                elementKeyOne,
                              ),
                              _buildAnimatedImage(
                                'assets/new.png',
                                _opacityAnimation,
                                elementKeyTwo,
                              ),
                              _buildNonAnimatedImage(
                                'assets/new.png',
                                _opacityAnimation,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AnimatedSlide(
                  offset: _offset,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: _visibleTop ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _targetController,
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _zoomContainerTargetAnimation.value,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                child: Container(
                                  height: 100,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: _isChangeColor
                                        ? Colors.black26
                                        : Colors.black12,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('$currentValue / $maxValue'),
                                      SizedBox(
                                        width: 250,
                                        child: TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                              milliseconds: 1900),
                                          curve: Curves.easeInOut,
                                          tween: Tween<double>(
                                            begin: 0.2,
                                            end: currentValue / maxValue,
                                          ),
                                          builder: (context, value, _) =>
                                              LinearProgressIndicator(
                                            minHeight: 10,
                                            color: Colors.purple,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            value: value,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: AnimatedBuilder(
                            animation: _targetController,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _zoomTargetAnimation.value,
                                child: Image.asset(
                                  'assets/new.png',
                                  key: destination,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _offsetOne != Offset.zero,
            child: AnimatedPositioned(
              top: _offsetOne.dy,
              left: _offsetOne.dx,
              duration: const Duration(milliseconds: 900),
              child: AnimatedScale(
                scale: _moving ? 0 : 1.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedRotation(
                  turns: _turns,
                  alignment: Alignment.centerLeft,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedBuilder(
                    animation: _itemController,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _zoomAnimation.value,
                        child: Image.asset('assets/new.png',
                            width: 100, height: 100),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _offsetTwo != Offset.zero,
            child: AnimatedPositioned(
              top: _offsetTwo.dy,
              left: _offsetTwo.dx,
              duration: const Duration(milliseconds: 900),
              child: AnimatedScale(
                scale: _moving ? 0 : 1.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedRotation(
                  turns: _turns,
                  alignment: Alignment.centerLeft,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedBuilder(
                    animation: _itemController,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _zoomAnimation.value,
                        child: Image.asset('assets/new.png',
                            width: 100, height: 100),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _visibleBottom,
            child: Positioned(
              bottom: 50,
              left: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedBuilder(
                    animation: _hintController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Can you perfect your design?',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Center(
                          child: CustomPaint(
                            painter: TrianglePainter(
                              strokeColor: Colors.white,
                              strokeWidth: 0,
                              paintingStyle: PaintingStyle.fill,
                            ),
                            child: const SizedBox(
                              height: 15,
                              width: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white, // Text color
                          side: const BorderSide(
                              color: Colors.red), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16), // Rounded rectangle shape
                          ),
                        ),
                        onPressed: _reset,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.red,
                              ),
                              // SizedBox(width: 10),
                              Text(
                                'Redesign',
                                style: TextStyle(color: Colors.red), // Red text
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16), // Rounded rectangle shape
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: const Center(
                            child: Text(
                              'Continue',
                              style:
                                  TextStyle(color: Colors.white), // White text
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
