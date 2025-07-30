import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/constants.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "registerScreen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please agree to the terms to continue")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: "tempPassword",
        );

        final uid = userCredential.user?.uid;

        // ✅ Save user data in Firestore
        await _firestore.collection('users').doc(uid).set({
          'name': _nameController.text.trim().isEmpty
              ? 'no-data-provided'
              : _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'cellnumber': 'no-data-provided',
          'avatar': 'no-data-provided',
          'society': 'no-data-provided',
        });

        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Account created successfully!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacementNamed(context, 'homeScreen');

      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);

        String message = "Something went wrong";
        if (e.code == 'email-already-in-use') {
          message = "This email is already registered.";
        } else if (e.code == 'invalid-email') {
          message = "Please enter a valid email address.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Create Your Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Join Tingungu and connect with your society.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  /// ✅ FORM
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Please enter your name" : null,
                        ),
                        const SizedBox(height: 20),

                        /// Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                          value!.contains("@") ? null : "Enter a valid email",
                        ),
                        const SizedBox(height: 20),

                        /// ✅ Terms & Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() => _agreedToTerms = value!);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsScreen(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: const TextSpan(
                                    text: "By creating an account, you agree to our ",
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                    children: [
                                      TextSpan(
                                        text: "Terms of Service, Data Privacy Policy & POPIA.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Constants.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// ✅ REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Register", style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ✅ ALREADY HAVE ACCOUNT?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'loginScreen');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ✅ FOOTER
                  const Text(
                    "Developed by Jaspa\n© 2025",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// ✅ SPINKIT LOADER OVERLAY
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(
                        color: Colors.white,
                        size: 60.0,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Creating your account...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
