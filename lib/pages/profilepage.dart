import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_service.dart';
import '../supabaseservice.dart';
import 'loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();
  final _salaryExpectedController = TextEditingController();
  final _salaryCurrentController = TextEditingController();
  final _locationController = TextEditingController();
  final _supabaseService = SupabaseService();

  bool _isProfileCreated = false;
  String? _resumeUrl;
  final authService = AuthService();

  void logout() async {
    try {
      await authService.signOut();
      Get.offAll(() => const LoginPage());
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      final userId = _supabaseService.supabase.auth.currentUser!.id;
      final response = await _supabaseService.supabase
          .from('profile')
          .select()
          .match({'user_id': userId}).single();

      setState(() {
        _isProfileCreated = true;
        _firstNameController.text = response['first_name'] ?? '';
        _lastNameController.text = response['last_name'] ?? '';
        _phoneController.text = response['phone_no'] ?? '';
        _skillController.text = response['skills'] ?? '';
        _salaryExpectedController.text =
            response['salary_ex']?.toString() ?? '';
        _salaryCurrentController.text =
            response['salary_current']?.toString() ?? '';
        _locationController.text = response['location'] ?? '';
        _resumeUrl = response['resume_url'];
      });
    } catch (e) {
      setState(() {
        _isProfileCreated = false;
      });
    }
  }

  Future<void> _uploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        final resumeUrl = await _supabaseService.uploadResume(File(file.path!),
            fileName: file.name);
        await _supabaseService.updateResumeUrl(resumeUrl);
        setState(() {
          _resumeUrl = resumeUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resume uploaded successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading resume: $e")),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _supabaseService.createProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
          skills: _skillController.text,
          salaryExpected: int.tryParse(_salaryExpectedController.text) ?? 0,
          salaryCurrent: int.tryParse(_salaryCurrentController.text) ?? 0,
          location: _locationController.text,
        );

        setState(() {
          _isProfileCreated = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile created successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = _supabaseService.supabase.auth.currentUser!.id;
        await _supabaseService.supabase.from('profile').update({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone_no': _phoneController.text,
          'skills': _skillController.text,
          'salary_ex': int.tryParse(_salaryExpectedController.text) ?? 0,
          'salary_current': int.tryParse(_salaryCurrentController.text) ?? 0,
          'location': _locationController.text,
        }).match({'user_id': userId});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    try {
      await _supabaseService.deleteProfile();

      setState(() {
        _isProfileCreated = false;
        _firstNameController.clear();
        _lastNameController.clear();
        _phoneController.clear();
        _skillController.clear();
        _salaryExpectedController.clear();
        _salaryCurrentController.clear();
        _locationController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting profile: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _skillController,
                labelText: 'Skills',
                icon: Icons.work,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your skills';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _salaryExpectedController,
                labelText: 'Expected Salary',
                icon: Icons.money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your expected salary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _salaryCurrentController,
                labelText: 'Current Salary',
                icon: Icons.money_off,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current salary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                labelText: 'Location',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton.icon(
                onPressed: _uploadResume,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_resumeUrl != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Resume Uploaded',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Delete Profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
