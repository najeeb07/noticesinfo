import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart'; // Import the ApiService
import 'package:noticesinfo/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:noticesinfo/main.dart'; // Import LoginScreenWrapper from main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:noticesinfo/widgets/side_menu.dart'; // Removed as SideMenu is now in MainScreen

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleScreen;
  final VoidCallback onLoginSuccess; // New callback for successful login
  const LoginScreen({super.key, required this.onToggleScreen, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _fullPhoneNumber = ''; // To store the E.164 formatted phone number
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  GoogleSignIn? _googleSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Lazy initialization of GoogleSignIn to avoid early native plugin init issues on iOS 26
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  String _verificationId = '';
  String _smsCode = '';
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  String _otpErrorMessage = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _fullPhoneNumber, // Use the E.164 formatted number
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval of SMS code on Android
        await _auth.signInWithCredential(credential);
        final String? idToken = await _auth.currentUser?.getIdToken();
        if (idToken != null) {
          await _firebasePhoneLogin(idToken);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.message}')),
        );
        print('Verification Failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        _showOtpDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _showOtpDialog() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpErrorMessage = ''; // Clear previous error message

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Prevent dismissal on outside clicks
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea( // Use SafeArea to avoid overlapping with device navigation keys
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: SingleChildScrollView( // Allow content to scroll if it overflows
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _otpControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                counterText: '', // Hide the counter
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                                setModalState(() {
                                  _smsCode = _otpControllers.map((c) => c.text).join();
                                });
                              },
                            ),
                          );
                        }),
                      ),
                      if (_otpErrorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            _otpErrorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          setModalState(() {
                            _otpErrorMessage = ''; // Clear error on new attempt
                          });
                          if (_smsCode.length == 6) {
                            Navigator.of(context).pop();
                            setState(() {
                              _isLoading = true;
                            });
                            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                              verificationId: _verificationId,
                              smsCode: _smsCode,
                            );
                            try {
                              await _auth.signInWithCredential(credential);
                              final String? idToken = await _auth.currentUser?.getIdToken();
                              if (idToken != null) {
                                await _firebasePhoneLogin(idToken);
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              setModalState(() {
                                _otpErrorMessage = 'Incorrect OTP. Please try again.';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error signing in with OTP: ${e.message}')),
                              );
                              print('Error signing in with OTP: ${e.message}');
                              // Re-show the bottom sheet if OTP was incorrect
                              _showOtpDialog();
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error signing in with OTP: $e')),
                              );
                              print('Error signing in with OTP: $e');
                            }
                          } else {
                            setModalState(() {
                              _otpErrorMessage = 'Please enter a 6-digit OTP.';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Verify OTP',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _firebasePhoneLogin(String idToken) async {
    final result = await _apiService.firebasePhoneLogin(
      idToken,
      _phoneNumberController.text,
      _fullNameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In aborted by user.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // For Firebase authentication with Google Sign-In v6.x
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final result = await _apiService.firebaseLogin(idToken);

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          widget.onLoginSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get Firebase ID token.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $e')),
      );
      print('Error during Google Sign-In: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'assets/image/notices_logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log In with Phone Number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              autofillHints: [AutofillHints.name],
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            IntlPhoneField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              initialCountryCode: 'IN', // Default to India
              onChanged: (phone) {
                _fullPhoneNumber = phone.completeNumber;
                print(_fullPhoneNumber);
              },
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _verifyPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Log In with Phone Number',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 20),
            const Center(child: Text('or')),
            const SizedBox(height: 20),
            SignInButton(
              Buttons.google,
              text: "Log In with Google",
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
