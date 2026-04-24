import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class WalletApi {
  WalletApi(this._client);

  final ApiClient _client;

  ApiResponse<T> _unauthorized<T>() {
    return ApiResponse<T>(
      status: 401,
      success: false,
      message: 'Authorization required. Please login again.',
      data: null,
    );
  }

  Future<ApiResponse<WalletBalanceData?>> getBalance() {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<WalletBalanceData?>());
    return _client.get<WalletBalanceData?>(
      ApiEndpoints.walletBalance,
      fromJsonData: WalletBalanceData.fromJson,
    );
  }

  Future<ApiResponse<WalletOrderPaymentData?>> validateOrder({
    required num amount,
    required String orderRefNo,
    String? remarks,
  }) {
    if (!_client.hasAuthToken) {
      return Future.value(_unauthorized<WalletOrderPaymentData?>());
    }
    return _client.post<WalletOrderPaymentData?>(
      ApiEndpoints.walletValidateOrder,
      body: {
        'amount': amount,
        'orderRefNo': orderRefNo,
        'remarks': remarks ?? '',
      },
      fromJsonData: WalletOrderPaymentData.fromJson,
    );
  }

  Future<ApiResponse<WalletOrderPaymentData?>> payOrder({
    required num amount,
    required String orderRefNo,
    String? remarks,
  }) {
    if (!_client.hasAuthToken) {
      return Future.value(_unauthorized<WalletOrderPaymentData?>());
    }
    return _client.post<WalletOrderPaymentData?>(
      ApiEndpoints.walletPayOrder,
      body: {
        'amount': amount,
        'orderRefNo': orderRefNo,
        'remarks': remarks ?? '',
      },
      fromJsonData: WalletOrderPaymentData.fromJson,
    );
  }

  Future<ApiResponse<dynamic>> getTransaction(String tranno) {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<dynamic>());
    return _client.get<dynamic>(
      ApiEndpoints.walletTransaction(tranno),
    );
  }

  /// POST `/Wallet/SendOtp` — Willl add DTO control laterrrr (response shape TBD).
  Future<ApiResponse<dynamic>> sendOtp({required String orderRefNo}) {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<dynamic>());
    return _client.post<dynamic>(
      ApiEndpoints.walletSendOtp,
      body: {'orderRefNo': orderRefNo},
    );
  }

  /// POST `/Wallet/ValidateOtp` — Willl add DTO control laterrrr (response shape TBD).
  Future<ApiResponse<dynamic>> validateOtp({
    required String orderRefNo,
    required String otpCode,
  }) {
    if (!_client.hasAuthToken) return Future.value(_unauthorized<dynamic>());
    return _client.post<dynamic>(
      ApiEndpoints.walletValidateOtp,
      body: {
        'orderRefNo': orderRefNo,
        'otpCode': otpCode,
      },
    );
  }
}
