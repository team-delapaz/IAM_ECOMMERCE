import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class CheckoutApi {
  CheckoutApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<CheckoutData?>> checkout({
    required String fullName,
    required String mobileNo,
    required String emailAddress,
    required String paymentProviderCode,
    required String country,
    required String province,
    required String city,
    required String barangay,
    required String streetAddress,
    required String postalCode,
    required String completeAddress,
    required String notes,
    required int fulfillmentTypeId,
    String? areaCode,
  }) {
    return _client.post<CheckoutData?>(
      ApiEndpoints.checkout,
      body: {
        'fullName': fullName,
        'mobileNo': mobileNo,
        'emailAddress': emailAddress,
        'paymentProviderCode': paymentProviderCode,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'streetAddress': streetAddress,
        'postalCode': postalCode,
        'completeAddress': completeAddress,
        'notes': notes,
        'fulfillmentTypeId': fulfillmentTypeId,
        'areaCode': areaCode,
      },
      fromJsonData: CheckoutData.fromJson,
    );
  }

  /// Compute shipping/processing fees before final checkout.
  Future<ApiResponse<ComputeFeesData?>> computeFees({
    required String paymentProviderCode,
    required String country,
    required String province,
    required String city,
    required int fulfillmentTypeId,
  }) {
    return _client.post<ComputeFeesData?>(
      ApiEndpoints.checkoutComputeFees,
      body: {
        'paymentProviderCode': paymentProviderCode,
        'country': country,
        'province': province,
        'city': city,
        'fulfillmentTypeId': fulfillmentTypeId,
      },
      fromJsonData: ComputeFeesData.fromJson,
    );
  }
}

