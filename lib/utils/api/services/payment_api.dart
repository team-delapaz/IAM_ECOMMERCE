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
}

