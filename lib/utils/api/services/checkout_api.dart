import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';

class CheckoutApi {
  CheckoutApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<dynamic>> checkout({
    required String fullName,
    required String mobileNo,
    required String emailAddress,
    required String country,
    required String province,
    required String city,
    required String barangay,
    required String streetAddress,
    required String postalCode,
    required String completeAddress,
    String? notes,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.checkout,
      body: {
        'fullName': fullName,
        'mobileNo': mobileNo,
        'emailAddress': emailAddress,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'streetAddress': streetAddress,
        'postalCode': postalCode,
        'completeAddress': completeAddress,
        if (notes != null) 'notes': notes,
      },
    );
  }
}

