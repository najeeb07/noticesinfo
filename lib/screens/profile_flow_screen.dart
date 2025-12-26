import 'package:flutter/material.dart';
import 'package:noticesinfo/screens/login_screen.dart';
import 'package:noticesinfo/screens/signup_screen.dart';

class ProfileFlowScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess; // New callback for successful login
  const ProfileFlowScreen({super.key, required this.onLoginSuccess});

  @override
  State<ProfileFlowScreen> createState() => _ProfileFlowScreenState();
}

class _ProfileFlowScreenState extends State<ProfileFlowScreen> {
  bool _showLogin = true; // State to toggle between login and signup

  void _toggleScreen() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(
            onToggleScreen: _toggleScreen,
            onLoginSuccess: widget.onLoginSuccess, // Pass the callback
          )
        : SignupScreen(onToggleScreen: _toggleScreen);
  }
}
