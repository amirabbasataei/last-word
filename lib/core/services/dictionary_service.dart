import 'package:http/http.dart' as http;

abstract class IDictionaryService {
  Future<bool> isValidWord(String word);
}

class DictionaryService implements IDictionaryService {
  DictionaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Returns true if [word] is a real English word.
  /// Falls back to true on network errors to avoid punishing players on slow connections.
  @override
  Future<bool> isValidWord(String word) async {
    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(word.toLowerCase())}');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      // Offline or timeout — accept the word
      return true;
    }
  }
}
