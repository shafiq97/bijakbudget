import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _educationLevelController =
      TextEditingController();
  String _gender = 'Select Gender';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> register() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String age = _ageController.text.trim();
    final String educationLevel = _educationLevelController.text.trim();

    if (password == confirmPassword && password.isNotEmpty) {
      try {
        // Create the user with Firebase Auth
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the UID of the newly created user
        String uid = userCredential.user!.uid;

        // Store additional user information in Firestore
        await _firestore.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'age': age,
          'educationLevel': educationLevel,
          'gender': _gender,
        });

        // Handle successful registration, e.g., navigate to the home screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } on FirebaseAuthException catch (e) {
        // Handle errors, such as email already in use or weak password
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _educationLevelController,
              decoration: const InputDecoration(
                labelText: 'Education Level',
              ),
            ),
            DropdownButton<String>(
              value: _gender,
              items: <String>['Select Gender', 'Male', 'Female', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                register();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
