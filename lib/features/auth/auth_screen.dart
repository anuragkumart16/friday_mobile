import 'package:flutter/material.dart';
import 'package:friday_mobile/shared/widgets/primary_long_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login to Friday',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 300,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: const TextStyle(color: Colors.white54),

                  filled: true,
                  fillColor: Colors.white12,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.white54),

                  filled: true,
                  fillColor: Colors.white12,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 300,
              height: 50,
              child: PrimaryLongButton(
                text: "Login",
                onPressed: () {
                  print("working");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
