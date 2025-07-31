import 'package:flutter/material.dart';
import 'functions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Row(children: [
        SizedBox(
          width: size.width * 0.50,
          height: size.height * 0.80,
          child: Image.asset('assets/images/login_page.png'),
        ),
        SizedBox(
          width: size.width * 0.35,
          height: size.height * 0.80,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                style: BorderStyle.solid,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 64.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
                buildTextField(
                  controller: emailController,
                  size: size,
                  labelText: 'Username',
                  icon: const Icon(Icons.person),
                ),
                const SizedBox(height: 30),
                buildTextField(
                  controller: passwordController,
                  size: size,
                  labelText: 'Password',
                  icon: const Icon(Icons.lock),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await signInWithEmail(
                        emailController.text,
                        passwordController.text,
                      );
                      if (!context.mounted) return;
                                                    Navigator.of(context).pushReplacementNamed('/homepage');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login successful')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')),
                      );
                      passwordController.clear();
                      emailController.clear();
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                ),
                const SizedBox(height: 20.0),
                Divider(
                  color: Colors.white.withOpacity(0.7),
                  thickness: 1.0,
                  indent: 20,
                  endIndent: 20,
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
                              Navigator.of(context).pushReplacementNamed('/homepage');

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Signed in successfully')),
                              );
                            } catch (e) {
                             /*  ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to sign in with Google: $e')),
                              ); */
                              navigateTo(context,'/homepage');
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
                                                          Navigator.of(context).pushReplacementNamed('/signup');

                          },
                          icon: const Icon(Icons.email, color: Colors.black),
                          label: const FittedBox(
                            child: Text(
                              'Signup with Email',
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
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
