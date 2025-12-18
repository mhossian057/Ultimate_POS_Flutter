import 'dart:convert';

import '../apis/api.dart';
import '../helpers/http_client.dart';
import '../models/system.dart';

class ShipmentApi extends Api {
  //get sell by shipment status
  getSellByShipmentStatus(String status, String date) async {
    String url = this.apiUrl + "sell/?start_date=$date&shipping_status=$status";
    var token = await System().getToken();
    var response = [];
    await LoggedHttpClient
        .get(Uri.parse(url), headers: this.getHeader('$token'))
        .then((value) {
      response = jsonDecode(value.body)['data'];
    });
    return response;
  }

  //update shipment status in api
  updateShipmentStatus(data) async {
    String url = this.apiUrl + "update-shipping-status";
    var token = await System().getToken();
    var body = jsonEncode(data);
    var response;
    await LoggedHttpClient
        .post(Uri.parse(url), headers: this.getHeader('$token'), body: body)
        .then((value) {
      response = jsonDecode(value.body);
    });
    return response;
  }
}
