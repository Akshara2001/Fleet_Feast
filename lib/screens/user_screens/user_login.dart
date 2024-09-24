import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_screens/user_homepage.dart';
import 'package:flutter_application_1/screens/user_screens/user_signup.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';
import 'package:flutter_application_1/utility/auth.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';
import 'package:flutter_application_1/theme/colors.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late BuildContext buildContext;
  bool _obscureText = true; // Track password visibility
  Color _signupColor = AppColors.orange200; // Default color for Sign Up
  Color _resetLinkColor = AppColors.orange200; // Same color for Forgot Password

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      await signInWithEmail(email, password, buildContext);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserHomepage()),
      );
    } catch (error) {
      print(error);
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content:
              const Text("Reset password link sent to registered email id"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return CustomScaffold(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 25.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.orange100,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomeScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 60.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20.0),
                      const Text("Welcome Back",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange200,
                          )),
                      const SizedBox(height: 3.0),
                      const Text("Login to your account",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w100,
                            color: AppColors.grey,
                          )),
                      const SizedBox(height: 40.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                      ),
                      const SizedBox(height: 17.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            _showResetPasswordDialog(); // Show dialog on tap
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w100,
                              color: _resetLinkColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.orange200,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: login,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _signupColor = AppColors.grey;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserSignup()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account?",
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w100,
                              color: AppColors.grey,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Sign Up ',
                                style: TextStyle(
                                  color: _signupColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.orange200,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
