import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_background.png'),
            fit: BoxFit.cover, // Adjust how the image fits the screen
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'cargram',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Geo',
                  ),
                ),

                const Text(
                  'Click Post, n Go!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFFA00000)),
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.8),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF52020F)),
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.8),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                      if (userCredential.user != null) {
                        print(
                          'Login successful! User ID: ${userCredential.user!.uid}',
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                        setState(() {
                          _errorMessage = '';
                        });
                      } else {
                        setState(() {
                          _errorMessage = 'Login failed. Please try again.';
                        });
                      }
                    } on FirebaseAuthException catch (e) {
                      String errorMessage = 'Login failed.';
                      if (e.code == 'user-not-found') {
                        errorMessage = 'No user found for that email.';
                      } else if (e.code == 'wrong-password') {
                        errorMessage = 'Wrong password provided for that user.';
                      } else if (e.code == 'invalid-email') {
                        errorMessage = 'The email address is not valid.';
                      } else if (e.code == 'user-disabled') {
                        errorMessage = 'This user account has been disabled.';
                      }
                      setState(() {
                        _errorMessage = errorMessage;
                      });
                      print('Firebase Auth Error: ${e.code} - ${e.message}');
                    } catch (e) {
                      setState(() {
                        _errorMessage =
                            'An unexpected error occurred. Please try again.';
                      });
                      print('Unexpected Error: $e');
                    }
                  },
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    print('Go to Registration');
                  },
                  child: const Text(
                    'Don\'t have an account? Register here.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
