import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/services/api_service.dart';

class BinService {
  static Future<Map<String, dynamic>> getBins(String token) async {
    return ApiService.get(url: ApiConstants.bins, token: token);
  }

  static Future<Map<String, dynamic>> getBin(int pk, String token) async {
    return ApiService.get(url: ApiConstants.binDetail(pk), token: token);
  }

  static Future<Map<String, dynamic>> createBin({
    required String token,
    required String color,
    required String location,
    required String status,
  }) async {
    return ApiService.post(
      url:   ApiConstants.binCreate,
      token: token,
      body:  {'color': color, 'location': location, 'status': status},
    );
  }

  static Future<Map<String, dynamic>> updateBin({
    required int    pk,
    required String token,
    required String color,
    required String location,
    required String status,
  }) async {
    return ApiService.patch(
      url:   ApiConstants.binUpdate(pk),
      token: token,
      body:  {'color': color, 'location': location, 'status': status},
    );
  }

  static Future<Map<String, dynamic>> deleteBin(int pk, String token) async {
    return ApiService.delete(url: ApiConstants.binDelete(pk), token: token);
  }
}