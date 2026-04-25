import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/slider_model.dart';

class SliderApiService extends BaseApiService {
  Future<ApiResult<List<SliderModel>>> getSliders() async {
    return get<List<SliderModel>>(
      NetworkConstantsUtil.slider,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) =>
                  SliderModel.fromJson(item as Map<String, dynamic>))
              .where((slider) => slider.isEnabled)
              .toList();
        }
        return [];
      },
    );
  }
}
