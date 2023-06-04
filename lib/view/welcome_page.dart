import 'package:flutter/material.dart';
// import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage("assets/images/background.jpg"),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 180, bottom: 25),
              //   child: Image.asset(
              //     "assets/images/logo.png",
              //     height: 170,
              //     width: 170,
              //   ),
              // ),
              const Text(
                "Appointify",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   PageRouteBuilder(
                          //     pageBuilder:
                          //         (context, animation, secondaryAnimation) =>
                          //             const LoginPage(),
                          //     transitionsBuilder: (context, animation,
                          //         secondaryAnimation, child) {
                          //       var begin = const Offset(0.0, 1.0);
                          //       var end = Offset.zero;
                          //       var curve = Curves.ease;

                          //       var tween = Tween(begin: begin, end: end)
                          //           .chain(CurveTween(curve: curve));

                          //       return SlideTransition(
                          //         position: animation.drive(tween),
                          //         child: child,
                          //       );
                          //     },
                          //   ),
                          // );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                        child: const Text(
                          "   START NOW   ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
