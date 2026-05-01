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

  Future<ApiResponse<LoginData?>> signup({
    required String email,
    required String mobileNo,
    required String password,
    required String firstName,
    required String lastName,
    String? referralId,
  }) {
    return _client.post<LoginData?>(
      ApiEndpoints.authSignup,
      body: {
        'email': email,
        'mobileNo': mobileNo,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (referralId != null && referralId.trim().isNotEmpty)
          'referralId': referralId.trim(),
      },
      fromJsonData: LoginData.fromJson,
    );
  }

  Future<ApiResponse<VerificationResponse?>> resendVerificationCode(String email) {
    return _client.post<VerificationResponse?>(
      ApiEndpoints.authResendVerificationCode,
      body: {'email': email},
      fromJsonData: VerificationResponse.fromJson,
    );
  }

  Future<ApiResponse<VerifyResponse?>> verifyCode({
    required String email,
    required String code,
  }) {
    return _client.post<VerifyResponse?>(
      ApiEndpoints.authVerifyCode,
      body: {
        'email': email,
        'code': code,
      },
      fromJsonData: VerifyResponse.fromJson,
    );
  }

  Future<ApiResponse<dynamic>> forgotPassword(String emailAddress) {
    return _client.post<dynamic>(
      ApiEndpoints.authForgotPassword,
      body: {
        'emailAddress': emailAddress,
      },
    );
  }

  Future<ApiResponse<ValidateResetCodeResponse?>> validateResetCode({
    required String emailAddress,
    required String resetCode,
  }) {
    return _client.post<ValidateResetCodeResponse?>(
      ApiEndpoints.authValidateResetCode,
      body: {
        'emailAddress': emailAddress,
        'resetCode': resetCode,
      },
      fromJsonData: ValidateResetCodeResponse.fromJson,
    );
  }

  Future<ApiResponse<dynamic>> resetPassword({
    required String emailAddress,
    required String resetCode,
    required String newPassword,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.authResetPassword,
      body: {
        'emailAddress': emailAddress,
        'resetCode': resetCode,
        'newPassword': newPassword,
      },
    );
  }
}
