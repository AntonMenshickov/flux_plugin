import 'dart:convert';

import 'package:flux_plugin/model/event_message.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  ///Generated app token
  final String token;

  ///flux server url e.g. http://127.0.0.1:4000
  final String url;

  ApiConfig({required this.token, required this.url});
}

class Api {
  late final String _token;
  late final String _url;

  Api(ApiConfig options) : _token = options.token, _url = options.url;

  Future<void> uploadEventsBatch(Iterable<EventMessage> events) async {
    return _sendPostRequest(
      '/events/add',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _sendPostRequest(String apiPath, String body) async {
    final url = Uri.parse('$_url/api$apiPath');
    final jwtToken = _token;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: body,
    );

    if (response.statusCode == 204) {
    } else {
      print(response.body);
      throw response;
    }
  }
}
