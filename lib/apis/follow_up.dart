import 'dart:convert';

import '../models/system.dart';
import '../helpers/http_client.dart';
import 'api.dart';

class FollowUpApi extends Api {
  //get specific follow up detail
  Future<Map> getSpecifiedFollowUp(id) async {
    try {
      var followUps;
      String url = this.apiUrl + "crm/follow-ups/$id";
      var token = await System().getToken();
      var response =
          await LoggedHttpClient.get(Uri.parse(url), headers: this.getHeader('$token'));

      followUps = jsonDecode(response.body);
      var followUpList = followUps['data'][0];
      return followUpList;
    } catch (e) {
      return {};
    }
  }

  //add follow up
  addFollowUp(Map followUp) async {
    try {
      String url = this.apiUrl + "crm/follow-ups";
      var body = json.encode(followUp);
      var token = await System().getToken();
      var response = await LoggedHttpClient.post(Uri.parse(url),
          headers: this.getHeader('$token'), body: body);
      return response.statusCode;
    } catch (e) {}
  }

  //update follow up
  update(Map followUp, id) async {
    try {
      String url = this.apiUrl + "crm/follow-ups/$id";
      var body = json.encode(followUp);
      var token = await System().getToken();
      var response = await LoggedHttpClient.put(Uri.parse(url),
          headers: this.getHeader('$token'), body: body);
      return response.statusCode;
    } catch (e) {}
  }

  //post call_logs to api
  Future<bool> syncCallLog(Map callLogs) async {
    try {
      String url = this.apiUrl + "crm/call-logs";
      var body = json.encode(callLogs);
      var token = await System().getToken();
      var response = await LoggedHttpClient.post(Uri.parse(url),
          headers: this.getHeader('$token'), body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //get follow up categories
//get specific follow up detail
  Future<List<dynamic>> getFollowUpCategories() async {
    try {
      var followUpCategories;
      String url = this.apiUrl + "taxonomy?type=followup_category";
      var token = await System().getToken();
      var response =
          await LoggedHttpClient.get(Uri.parse(url), headers: this.getHeader('$token'));

      followUpCategories = jsonDecode(response.body);
      List<dynamic> followUpCategoryList = followUpCategories['data'];
      return followUpCategoryList;
    } catch (e) {
      return [];
    }
  }
}
