import 'package:flutter/material.dart';
import 'functions.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left-side image
          SizedBox(
            width: size.width * 0.50,
            height: size.height * 0.80,
            child: Image.asset('assets/images/login_page.png'),
          ),
          // Right-side form
          SizedBox(
            width: size.width * 0.35,
            height: size.height * 0.80,
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(style: BorderStyle.solid, color: Colors.black),
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.9),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Create account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildTextField(
                        controller: emailController,
                        size: size,
                        labelText: 'email',
                        icon: const Icon(Icons.person, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: passwordController,
                        size: size,
                        labelText: 'password',
                        icon: const Icon(Icons.password, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: confirmPasswordController,
                        size: size,
                        labelText: 'confirm password',
                        icon: const Icon(Icons.password, color: Colors.black),
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (passwordController.text ==
                              confirmPasswordController.text) {
                            try {
                              await signUpWithEmail(
                                emailController.text,
                                passwordController.text,
                              );
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sign-Up successful')),
                              );
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to sign up: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match')),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'signup',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Divider(
                        color: Colors.white
                            .withOpacity(0.7), // White color for the divider
                        thickness: 1.0, // Line thickness
                        indent: 20, // Empty space on the left
                        endIndent: 20, // Empty space on the right
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await signInWithGoogle();
                                    if (!context.mounted) return;

                                    Navigator.of(context)
                                        .pushReplacementNamed('/homepage');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Signed in successfully')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to sign in with Google: $e')),
                                    );
                                  }
                                },
                                icon: ClipOval(
                                  child: Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                label: const FittedBox(
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                                icon: const Icon(Icons.email,
                                    color: Colors.black),
                                label: const FittedBox(
                                  child: Text(
                                    'Login with Email',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
