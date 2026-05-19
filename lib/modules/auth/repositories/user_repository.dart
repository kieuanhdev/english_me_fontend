import 'package:dio/dio.dart';

import 'package:englishme/modules/auth/models/user_profile_model.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserProfileResponse> getMe() async {
    final response = await _dio.get('/users/me');
    return UserProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileResponse> updateMe({
    String? displayName,
    String? cefrLevel,
  }) async {
    final response = await _dio.put(
      '/users/me',
      data: {
        if (displayName != null) 'fullName': displayName,
        if (cefrLevel != null) 'cefrLevel': cefrLevel,
      },
    );
    return UserProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
