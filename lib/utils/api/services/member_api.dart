import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class MemberApi {
  MemberApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<MemberPayload?>> getMember() {
    return _client.get<MemberPayload?>(
      ApiEndpoints.member,
      fromJsonData: MemberPayload.fromJson,
    );
  }
}

