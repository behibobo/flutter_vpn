import 'dart:async';
import 'package:http/http.dart' as http;

const baseUrl = "https://vpn.coding-lodge.com/api";

class API {
  static Future getServers() {
    var url = baseUrl + "/servers";
    return http.get(url);
  }
}
