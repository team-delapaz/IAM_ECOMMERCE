import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class PaymentApi {
  PaymentApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<List<PaymentMethodItem?>>> getPaymentMethods() {
    return _client.get<List<PaymentMethodItem?>>(
      ApiEndpoints.paymentMethods,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : const [];
        return list.map((e) => PaymentMethodItem.fromJson(e)).toList();
      },
    );
  }

  Future<ApiResponse<List<PaymentProviderItem?>>> getPaymentProviders() {
    return _client.get<List<PaymentProviderItem?>>(
      ApiEndpoints.paymentProviders,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : const [];
        return list.map((e) => PaymentProviderItem.fromJson(e)).toList();
      },
    );
  }

  Future<ApiResponse<PaymentData?>> createPayment({
    required String orderNo,
    required String idno,
    required num amount,
    required String currency,
    required String paymentProvider,
    required String paymentMethod,
    required String description,
    required String clientReferenceNo,
  }) {
    return _client.post<PaymentData?>(
      ApiEndpoints.paymentCreate,
      body: {
        'orderNo': orderNo,
        'idno': idno,
        'amount': amount,
        'currency': currency,
        'paymentProvider': paymentProvider,
        'paymentMethod': paymentMethod,
        'description': description,
        'clientReferenceNo': clientReferenceNo,
      },
      fromJsonData: PaymentData.fromJson,
    );
  }

  Future<ApiResponse<dynamic>> callbackPayment({
    required String paymentTxnId,
    required String refNo,
    required String idno,
    required String paymentProvider,
    required int paymentStatusId,
    required String statusMessage,
    required String gatewayReference,
    required String rawResponseJson,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.paymentCallback,
      body: {
        'paymentTxnId': paymentTxnId,
        'refNo': refNo,
        'idno': idno,
        'paymentProvider': paymentProvider,
        'paymentStatusId': paymentStatusId,
        'statusMessage': statusMessage,
        'gatewayReference': gatewayReference,
        'rawResponseJson': rawResponseJson,
      },
    );
  }

  Future<ApiResponse<dynamic>> getPaymentByTransaction(String transactionId) {
    return _client.get<dynamic>(
      ApiEndpoints.paymentByTransaction(transactionId),
    );
  }

  Future<ApiResponse<dynamic>> getPaymentStatus(String refNo) {
    return _client.get<dynamic>(
      ApiEndpoints.paymentStatusByRef(refNo),
    );
  }
}

