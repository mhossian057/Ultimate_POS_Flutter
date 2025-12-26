import 'dart:convert';

import '../models/system.dart';
import '../helpers/http_client.dart';
import 'api.dart';

class PreviousPriceApi extends Api {
  Future<Map<String, dynamic>?> getPreviousPrice({
    required int variationId,
    required int customerId,
    required int locationId,
  }) async {
    try {
      String url = '${this.apiUrl}variation-prev-price?variation_id=$variationId&customer_id=$customerId&location_id=$locationId';
      var token = await System().getToken();
      
      var response = await LoggedHttpClient.get(
        Uri.parse(url), 
        headers: this.getHeader('$token'),
      );
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}