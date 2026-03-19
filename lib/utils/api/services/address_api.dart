import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class AddressApi {
  AddressApi(this._client);

  final ApiClient _client;

  /// Get all addresses
  Future<ApiResponse<List<AddressItem?>>> getAddresses() {
    return _client.get<List<AddressItem?>>(
      ApiEndpoints.address,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => AddressItem.fromJson(e)).toList();
      },
    );
  }

  /// Get address by ID
  Future<ApiResponse<AddressItem?>> getAddress(int autoId) {
    return _client.get<AddressItem?>(
      ApiEndpoints.addressById(autoId),
      fromJsonData: AddressItem.fromJson,
    );
  }

  /// Add new address
  Future<ApiResponse<AddressItem?>> addAddress({
    required String recipientName,
    required String mobileNo,
    required String country,
    required String province,
    required String city,
    required String barangay,
    required String streetAddress,
    required String postalCode,
    required String completeAddress,
    bool isDefault = false,
  }) {
    return _client.post<AddressItem?>(
      ApiEndpoints.address,
      body: {
        'recipientName': recipientName,
        'mobileNo': mobileNo,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'streetAddress': streetAddress,
        'postalCode': postalCode,
        'completeAddress': completeAddress,
        'isDefault': isDefault,
      },
      fromJsonData: AddressItem.fromJson,
    );
  }

  /// Update address
  Future<ApiResponse<AddressItem?>> updateAddress({
    required int autoId,
    required String recipientName,
    required String mobileNo,
    required String country,
    required String province,
    required String city,
    required String barangay,
    required String streetAddress,
    required String postalCode,
    required String completeAddress,
    required bool isDefault,
  }) {
    return _client.put<AddressItem?>(
      ApiEndpoints.addressById(autoId),
      body: {
        'recipientName': recipientName,
        'mobileNo': mobileNo,
        'country': country,
        'province': province,
        'city': city,
        'barangay': barangay,
        'streetAddress': streetAddress,
        'postalCode': postalCode,
        'completeAddress': completeAddress,
        'isDefault': isDefault,
      },
      fromJsonData: AddressItem.fromJson,
    );
  }

  /// Delete address
  Future<ApiResponse<dynamic>> deleteAddress(int autoId) {
    return _client.delete<dynamic>(
      ApiEndpoints.addressById(autoId),
    );
  }

  /// Set address as default
  Future<ApiResponse<dynamic>> setDefaultAddress(int autoId) {
    return _client.put<dynamic>(
      ApiEndpoints.addressDefault(autoId),
    );
  }
}
