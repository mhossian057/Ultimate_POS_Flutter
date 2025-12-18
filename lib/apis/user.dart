import 'dart:convert';

import '../helpers/http_client.dart';
import 'api.dart';

class User extends Api {
  Future<Map> get(var token) async {
    String url = apiUrl + "user/loggedin";
    var response =
        await LoggedHttpClient.get(Uri.parse(url), headers: this.getHeader(token));
    var userDetails = jsonDecode(response.body);
    Map userDetailsMap = userDetails['data'];
    return userDetailsMap;
  }
}
