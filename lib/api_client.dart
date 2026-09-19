import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;

  // A bit longer than the server's own evaluateTimeout (90s as of
  // this writing, in cmd/api/main.go), so the server has a chance to
  // return its own error/result first instead of the client giving
  // up early. If you change the server's timeout, update this too.
  static const _requestTimeout = Duration(seconds: 100);

  ApiClient({required this.baseUrl});

  Future<EvaluationResult> evaluate({
    required String description,
    required double budget,
  }) async {
    final uri = Uri.parse('$baseUrl/api/evaluate');

    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'description': description,
              'budget': budget,
            }),
          )
          .timeout(_requestTimeout);
    } on Exception {
      throw ApiException(
        'Could not reach the server. Check the server URL and that it is running.',
      );
    }

    switch (response.statusCode) {
      case 200:
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return EvaluationResult.fromJson(decoded);
      case 400:
        throw ApiException('Invalid request: ${response.body}');
      case 503:
        throw ApiException('Server is busy right now. Try again shortly.');
      default:
        throw ApiException(
          'Request failed (${response.statusCode}): ${response.body}',
        );
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }
}
