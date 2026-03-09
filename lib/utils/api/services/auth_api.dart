import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<LoginData?>> login(String username, String password) {
    return _client.post<LoginData?>(
      ApiEndpoints.authLogin,
      body: {'username': username, 'password': password},
      fromJsonData: LoginData.fromJson,
    );
  }

  Future<ApiResponse<dynamic>> signup({
    required String email,
    required String mobileNo,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.authSignup,
      body: {
        'email': email,
        'mobileNo': mobileNo,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
  }
}
