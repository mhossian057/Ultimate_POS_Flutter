import 'dart:convert';

import '../models/system.dart';
import '../helpers/http_client.dart';
import 'api.dart';

class Tax extends Api {
  var taxes;

  Future<List> get() async {
    try {
      String url = this.apiUrl + "tax";
      var token = await System().getToken();
      var response =
          await LoggedHttpClient.get(Uri.parse(url), headers: this.getHeader('$token'));
      taxes = jsonDecode(response.body);
      var taxList = taxes['data'];
      System().insert('tax', jsonEncode(taxList));
      return taxList;
    } catch (e) {
      return [];
    }
  }
}
