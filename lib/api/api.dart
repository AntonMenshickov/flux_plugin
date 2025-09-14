import 'package:dart_either/dart_either.dart';
import 'package:flux_plugin/model/event_message.dart';

class ApiConfig {
  ///Generated app token
  final String token;

  ///flux server url e.g. http://127.0.0.1:4000
  final String url;

  ApiConfig({required this.token, required this.url});
}

class Api {
  late final String _token;
  late final String _host;

  Api(ApiConfig options) : _token = options.token, _host = options.url;

  Future<Either<Error, void>> uploadEventsBatch(
    Iterable<EventMessage> events,
  ) async {
    return Right(null);
  }
}
