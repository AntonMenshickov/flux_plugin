import 'dart:convert';
import 'dart:io';

import 'package:flux_plugin/src/model/event_message.dart';
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

  Future<void> uploadEventsBatch({
    required Iterable<EventMessage> events,
    required String platform,
    required String bundleId,
    required String deviceId,
  }) async {
    return _sendPostRequest(
      '/events/add',
      jsonEncode({
        "events": events.map((e) => e.toJson()).toList(),
        "platform": platform,
        "bundleId": bundleId,
        "deviceId": deviceId,
      }),
    );
  }

  Future<void> _sendPostRequest(String apiPath, String body) async {
    final url = Uri.parse('$_url/api$apiPath');
    final jwtToken = _token;

    final utf8Body = utf8.encode(body);

    final gzipBody = gzip.encode(utf8Body);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
        'Content-Encoding': 'gzip',
      },
      body: gzipBody,
    );

    if (response.statusCode == 204) {
    } else {
      print(response.body);
      throw response;
    }
  }
}
