import '../core/api_client.dart';
import '../core/api_response.dart';
import '../endpoints/api_endpoints.dart';
import '../responses/response_prep.dart';

class HelpCenterApi {
  HelpCenterApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<List<HelpTopicItem?>>> getTopics() {
    return _client.get<List<HelpTopicItem?>>(
      ApiEndpoints.helpCenterTopics,
      fromJsonData: (dynamic v) {
        if (v == null) return null;
        final list = v is List ? v : [];
        return list.map((e) => HelpTopicItem.fromJson(e)).toList();
      },
    );
  }
}
