import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class LocationApi {
  LocationApi(this._client);

  final ApiClient _client;

  /// Get all countries
  Future<ApiResponse<List<CountryItem?>>> getCountries() {
    return _client.get<List<CountryItem?>>(
      ApiEndpoints.locationCountries,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => CountryItem.fromJson(e)).toList();
      },
    );
  }

  /// Get provinces by country
  Future<ApiResponse<List<ProvinceItem?>>> getProvinces(String country) {
    return _client.get<List<ProvinceItem?>>(
      ApiEndpoints.locationProvinces(country),
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => ProvinceItem.fromJson(e)).toList();
      },
    );
  }

  /// Get cities by country and province
  Future<ApiResponse<List<CityItem?>>> getCities(String country, String province) {
    return _client.get<List<CityItem?>>(
      ApiEndpoints.locationCities(country, province),
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => CityItem.fromJson(e)).toList();
      },
    );
  }

  /// Get barangays by country, province, and city
  Future<ApiResponse<List<BarangayItem?>>> getBarangays(String country, String province, String city) {
    return _client.get<List<BarangayItem?>>(
      ApiEndpoints.locationBarangays(country, province, city),
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => BarangayItem.fromJson(e)).toList();
      },
    );
  }
}
