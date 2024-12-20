import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String skills,
    required String location,
    required int salaryExpected,
    required int salaryCurrent,
  }) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase.from('profile').upsert([
        {
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'phone_no': phoneNumber,
          'skills': skills,
          'salary_ex': salaryExpected,
          'salary_current': salaryCurrent,
          'location': location,
        }
      ]).select();
    } catch (e) {
      throw Exception("Error creating/updating profile: $e");
    }
  }

  Future<String> uploadResume(File file, {required String fileName}) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final uploadPath = '$userId/$fileName';
      final response = await supabase.storage.from('pdfprofile').upload(
            uploadPath,
            file,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );
      final publicUrl =
          supabase.storage.from('pdfprofile').getPublicUrl(uploadPath);
      return publicUrl;
    } catch (e) {
      throw Exception("Error uploading resume: $e");
    }
  }

  Future<void> updateResumeUrl(String resumeUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profile')
          .update({'resume_url': resumeUrl}).match({'user_id': userId});
    } catch (e) {
      throw Exception("Error updating resume URL: $e");
    }
  }

  Future<void> deleteProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profile')
          .delete()
          .match({'user_id': userId}).select();
    } catch (e) {
      throw Exception("Error deleting profile: $e");
    }
  }
}
