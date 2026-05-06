import os

filepath = "/Users/sibusiso/Projects/tingungu/lib/screens/register_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add imports
imports_old = "import 'package:flutter_spinkit/flutter_spinkit.dart';"
imports_new = "import 'package:flutter_spinkit/flutter_spinkit.dart';\nimport 'package:google_sign_in/google_sign_in.dart';"
content = content.replace(imports_old, imports_new)

# Update _registerUser fields
fields_old = """        await _firestore.collection('users').doc(uid).set({
          'name': _nameController.text.trim().isEmpty
              ? 'no-data-provided'
              : _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'cellnumber': 'no-data-provided',
          'avatar': 'no-data-provided',
          'society': 'no-data-provided',
        });"""
fields_new = """        await _firestore.collection('users').doc(uid).set({
          'displayname': _nameController.text.trim().isEmpty ? 'New User' : _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'cellnumber': '',
          'avatar': '',
          'society': '',
          'dob': '',
          'profile_completed': false,
        });"""
content = content.replace(fields_old, fields_new)

# Add _signInWithGoogle method
google_signin_method = """
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'displayname': user.displayName ?? 'New User',
            'email': user.email,
            'avatar': user.photoURL ?? '',
            'cellnumber': '',
            'society': '',
            'dob': '',
            'profile_completed': false,
          });
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override"""
content = content.replace("  @override\n  Widget build(BuildContext context) {", google_signin_method + "\n  Widget build(BuildContext context) {")

# Add Google Sign In Button
buttons_old = """                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(

                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Register", style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 15),"""
buttons_new = """                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Continue with Email", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("OR", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF3B0D11)),
                      label: const Text("Continue with Google", style: TextStyle(fontSize: 16, color: Color(0xFF3B0D11))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF3B0D11)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),"""
content = content.replace(buttons_old, buttons_new)

with open(filepath, "w") as f:
    f.write(content)
