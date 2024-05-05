import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/routes/routes_constants.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';

class Userinterface extends StatefulWidget {
  const Userinterface({Key? key}) : super(key: key);

  @override
  _UserinterfaceState createState() => _UserinterfaceState();
}

class _UserinterfaceState extends State<Userinterface>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: 400)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFFE3AC96)),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/Photos/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: _animation.value,
                        height: _animation.value,
                        child: Image.asset('lib/assets/Photos/logowithoutbackground.png'),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    child: Appbuttons(
                      text: "Request Authentication",
                      routeName: '/Speechtotext',
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    child: Appbuttons(
                      text: "voice record",
                      onPressed: () =>
                          Navigator.pushReplacementNamed(
                            context,
                            RoutesConstants.voiceRecording,
                            arguments: VoiceRecordParams(isFirstTime: false),
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    child: Appbuttons(
                      text: "Log Out",
                      routeName: '/LandPage',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
