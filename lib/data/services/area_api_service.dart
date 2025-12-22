import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/area_model.dart';

/// API Service for Area-related endpoints
class AreaApiService extends BaseApiService {
  /// Fetch list of all available areas
  Future<ApiResult<List<AreaModel>>> getAreas() async {
    return get<List<AreaModel>>(
      NetworkConstantsUtil.area,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => AreaModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Fetch details of a specific area
  Future<ApiResult<AreaModel>> getAreaInfo(String areaId) async {
    return get<AreaModel>(
      NetworkConstantsUtil.areaInfo,
      queryParams: {'areaId': areaId},
      parser: (data) => AreaModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
