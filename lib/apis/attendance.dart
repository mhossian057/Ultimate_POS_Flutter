import 'dart:convert';

import '../apis/api.dart';
import '../helpers/http_client.dart';
import '../models/system.dart';

class AttendanceApi extends Api {
  //check-In/Out through api
  Future<Map<String, dynamic>?> checkIO(data, bool check) async {
    var endUrl;
    (check) ? endUrl = "clock-in" : endUrl = "clock-out";
    try {
      String url = this.apiUrl + "$endUrl";
      var token = await System().getToken();
      var response = await LoggedHttpClient.post(Uri.parse(url),
          headers: this.getHeader('$token'), body: jsonEncode(data));
      var info = jsonDecode(response.body);
      return info;
    } catch (e) {
      return null;
    }
  }

  //get user attendance
  getAttendanceDetails(int userId) async {
    try {
      String url = this.apiUrl + "get-attendance/$userId";
      var token = await System().getToken();
      var response =
          await LoggedHttpClient.get(Uri.parse(url), headers: this.getHeader('$token'));
      var info = jsonDecode(response.body);
      var result = info['data'];
      return result;
    } catch (e) {
      return null;
    }
  }
}
