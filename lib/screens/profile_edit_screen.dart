import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/l10n/app_localizations.dart';

class ProfileEditScreen extends StatefulWidget {
  static const routeName = '/profile-edit-screen';

  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _currentProfilePicUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialProfileData();
  }

  Future<void> _loadInitialProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final userName = await _apiService.getUserName();
    final profilePic = await _apiService.getUserProfilePic();

    setState(() {
      _nameController.text = userName ?? '';
      _currentProfilePicUrl = profilePic;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)?.imagePickerError ?? 'Error picking image.';
      });
    }
  }

  Future<void> _submitProfileUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await _apiService.updateProfile(
          name: _nameController.text,
          profilePic: _selectedImage,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? (AppLocalizations.of(context)?.profileUpdatedSuccessfully ?? 'Profile updated successfully!'))),
          );
          Navigator.of(context).pop(true); // Pop with true to indicate success
        } else {
          setState(() {
            _errorMessage = response['message'] ?? (AppLocalizations.of(context)?.failedToUpdateProfile ?? 'Failed to update profile.');
            if (response['errors'] != null) {
              _errorMessage = (_errorMessage ?? '') + '\n' + response['errors'].values.expand((e) => e).join('\n');
            }
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = (AppLocalizations.of(context)?.anErrorOccurred ?? 'An error occurred: ') + e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.editProfile ?? 'Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_currentProfilePicUrl != null && _currentProfilePicUrl!.isNotEmpty
                                ? NetworkImage(_currentProfilePicUrl!)
                                : null) as ImageProvider?,
                        child: _selectedImage == null && (_currentProfilePicUrl == null || _currentProfilePicUrl!.isEmpty)
                            ? Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)?.changeProfilePicture ?? 'Change Profile Picture'),
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.name ?? 'Name',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)?.pleaseEnterYourName ?? 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitProfileUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                AppLocalizations.of(context)?.updateProfile ?? 'Update Profile',
                                style: const TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
