// lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<UserModel> syncUserWithBackend(String idToken) async {
    final response = await _dio.post(
      '/auth/sync',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return UserModel.fromJson(response.data);
  }
}
