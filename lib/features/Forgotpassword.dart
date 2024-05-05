// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_interfaces/widgets/Apptextfield.dart';

class ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPasswordPage(),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {


  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> verifyEmail() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      // handle error - email field is empty
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset link has been sent to your email"),
          backgroundColor: Colors.green,
        ),
      );
      // handle success - show success message or navigate
    } catch (e) {
      // handle error - show error message
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text("Forgot Password", style: TextStyle(fontSize: 35)),
                SizedBox(height: 12),
                Text(
                  "Please enter your Email to receive your password reset information",
                  style: TextStyle(fontSize: 18, color: Colors.grey[1]),
                ),
                SizedBox(height: 20),
                Text("Email", style: TextStyle(fontSize: 23)),
                Apptextfield(
                    hintText: "name@example.com", controller: emailController,),
                SizedBox(height: 40),


                // Center(
                //   child: Column(
                //     children: [
                //       Appbuttons(
                //         onPressed: verifyEmail,
                //         text: "Reset",
                //         // routeName: '/ResetPassword',
                //       ),
                //       SizedBox(height: 10), // Add some space between the buttons
                //       Appbuttons(
                //         onPressed: () {
                //           Navigator.pushNamed(context, "/Login");
                //           //Navigator.pop(context); // Navigate back to the previous screen
                //         },
                //         text: "Back to Login",
                //         routeName: "/Login", // You can adjust this route as needed
                //       ),
                //     ],
                //   ),
                // )




                Center(
                    child: Appbuttons(
                      onPressed: verifyEmail, // call func
                      text: "Reset",
                      // routeName: '/ResetPassword',
                      //routeName: '/ResetPassword',
                    ))


              ],
            ),
          ),
        ),
      ),
    );
  }
}
