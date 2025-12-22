import 'package:meatwaala_app/core/network/base_api_service.dart';
import 'package:meatwaala_app/core/network/network_constents.dart';
import 'package:meatwaala_app/data/models/company_model.dart';

/// API Service for Company-related endpoints
class CompanyApiService extends BaseApiService {
  /// Fetch company details
  /// This should be called on app launch (Splash screen)
  Future<ApiResult<CompanyModel>> getCompanyDetails() async {
    return get<CompanyModel>(
      NetworkConstantsUtil.company,
      parser: (data) {
        // The API returns the company object directly in 'data'
        return CompanyModel.fromJson(data as Map<String, dynamic>);
      },
    );
  }
}
