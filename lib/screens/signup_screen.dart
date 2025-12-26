import 'package:flutter/material.dart';
// import 'package:noticesinfo/widgets/side_menu.dart'; // Removed as SideMenu is now in MainScreen

class SignupScreen extends StatefulWidget {
  final VoidCallback onToggleScreen;
  const SignupScreen({super.key, required this.onToggleScreen});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // You might want to add TextEditingControllers here for the input fields
  // final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers here if you add them
    // _nameController.dispose();
    // _usernameController.dispose();
    // _emailController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/image/notices_logo.png', // Assuming a logo asset
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              // controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter User Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              // controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter User Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                'Please provide alphanumeric characters (uppercase and lowercase letters or numbers). The username should not be included special characters!@',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              // controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              // controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: const Icon(Icons.visibility_off),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: Text(
                'Your password must be at least 6 characters.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle signup logic here
                // After successful signup, you might want to pop this modal
                // and then show the login modal, or directly log them in.
                // For now, let's just pop and let the main.dart handle the next step.
                Navigator.of(context).pop();
                // If you want to immediately show login after signup, you could call widget.onToggleScreen() here
                // widget.onToggleScreen();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Pop current signup modal
                    widget.onToggleScreen(); // Trigger login modal
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
