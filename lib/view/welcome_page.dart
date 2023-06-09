import 'package:appointify/view/sign_in_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'sign_up_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: OnBoarding());
  }
}

class OnBoarding extends StatelessWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: OnBoardingSlider(
        pageBackgroundColor: Colors.white,
        centerBackground: true,
        headerBackgroundColor: const Color(0xFFFF9343),
        finishButtonText: 'Get Started',
        onFinish: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SignInPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = const Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        finishButtonStyle: const FinishButtonStyle(
          backgroundColor: Color(0xFFFF9343),
        ),
        skipTextButton: const Text(
          'Skip',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        trailing: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        trailingFunction: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SignUpPage(),
            ),
          );
        },
        background: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity, // Set the width of the container
                  height: 500, // Set the height of the container
                  decoration: const BoxDecoration(
                    color: Color(
                        0xFFFF9343), // Set the background color of the box
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(300, 150),
                      bottomLeft: Radius.elliptical(300, 150),
                    ),
                    // Set the border radius of the box
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/welcome_logo.png'),
                          const SizedBox(
                            height: 30,
                          ),
                          Image.asset('assets/images/Appointify1.png'),
                        ],
                      )),
                )
              ],
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity, // Set the width of the container
                  height: 500, // Set the height of the container
                  decoration: const BoxDecoration(
                    color: Color(
                        0xFFFF9343), // Set the background color of the box
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(300, 150),
                      bottomLeft: Radius.elliptical(300, 150),
                    ),
                    // Set the border radius of the box
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/welcome_logo2.png'),
                          Image.asset('assets/images/Appointify1.png'),
                        ],
                      )),
                ),
              ],
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity, // Set the width of the container
                  height: 500, // Set the height of the container
                  decoration: const BoxDecoration(
                    color: Color(
                        0xFFFF9343), // Set the background color of the box
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(300, 150),
                      bottomLeft: Radius.elliptical(300, 150),
                    ),
                    // Set the border radius of the box
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/welcome_logo3.png'),
                          const SizedBox(
                            height: 30,
                          ),
                          Image.asset('assets/images/Appointify1.png'),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
        totalPage: 3,
        speed: 1.8,
        pageBodies: [
          Container(
            padding: const EdgeInsets.only(top: 550, left: 30, right: 30),
            child: const Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Seamlessly Connect with Professors,",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "One Appointment at a Time",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 550, left: 30, right: 30),
            child: const Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Your Passport to Hassle-Free",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Appointments",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 550, left: 30, right: 30),
            child: const Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Bridge the Gap and Book",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Your Success",
                  style: TextStyle(fontFamily: 'GothamRnd-book', fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
