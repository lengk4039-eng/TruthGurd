import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/models/app_user.dart';
import '../../core/models/policy.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import 'auth_repository.dart';

class DioAuthRepository implements AuthRepository {
  Future<AppUser> _handleAuthResponse(Map<String, dynamic> data) async {
    await TokenStorage.save(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AppUser> login({required String email, required String password}) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post('/auth/login', data: {'email': email, 'password': password});
      return _handleAuthResponse(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      });
      return _handleAuthResponse(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Policy> linkExistingPolicy({required String policyNumber, required String dateOfBirth}) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post('/auth/link-existing-policy', data: {
        'policyNumber': policyNumber,
        'dateOfBirth': dateOfBirth,
      });
      return Policy.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<AppUser?> restoreSession() async {
    final token = await TokenStorage.readAccessToken();
    if (token == null) return null;
    try {
      final response = await ApiClient.instance.get('/users/me');
      return AppUser.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      await TokenStorage.clear();
      return null;
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String nationalIdNumber,
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.put('/users/me', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'nationalIdNumber': nationalIdNumber,
      });
      return AppUser.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<AppUser> uploadAvatar({required Uint8List bytes, required String filename}) {
    return unwrapDioErrors(() async {
      final isPng = filename.toLowerCase().endsWith('.png');
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType('image', isPng ? 'png' : 'jpeg'),
        ),
      });
      final response = await ApiClient.instance.post('/users/me/avatar', data: form);
      return AppUser.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<void> logout() => TokenStorage.clear();
}
