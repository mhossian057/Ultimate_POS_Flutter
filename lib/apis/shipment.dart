import 'dart:convert';

import '../apis/api.dart';
import '../helpers/http_client.dart';
import '../models/system.dart';

class ShipmentApi extends Api {
  //get sell by shipment status with pagination
  Future<Map<String, dynamic>?> getShipments(String url) async {
    try {
      print('ShipmentApi: Getting shipments from - $url');
      var token = await System().getToken();
      print('ShipmentApi: Token retrieved - ${token != null ? "Yes" : "No"}');

      var response = await LoggedHttpClient.get(
        Uri.parse(url),
        headers: this.getHeader('$token')
      );

      print('ShipmentApi: Response status - ${response.statusCode}');
      var result = jsonDecode(response.body);
      print('ShipmentApi: Response parsed successfully');

      return result;
    } catch (e) {
      print('ShipmentApi: Error - $e');
      return null;
    }
  }

  //get sell by shipment status
  Future<List> getSellByShipmentStatus(String status, String date) async {
    try {
      String url = this.apiUrl + "sell/?start_date=$date&shipping_status=$status";
      var token = await System().getToken();
      var response = await LoggedHttpClient.get(
        Uri.parse(url),
        headers: this.getHeader('$token')
      );
      var result = jsonDecode(response.body)['data'];
      return result;
    } catch (e) {
      print('ShipmentApi: Error in getSellByShipmentStatus - $e');
      return [];
    }
  }

  //update shipment status in api
  Future<dynamic> updateShipmentStatus(data) async {
    try {
      String url = this.apiUrl + "update-shipping-status";
      var token = await System().getToken();
      var body = jsonEncode(data);
      var response = await LoggedHttpClient.post(
        Uri.parse(url),
        headers: this.getHeader('$token'),
        body: body
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('ShipmentApi: Error in updateShipmentStatus - $e');
      return null;
    }
  }
}
