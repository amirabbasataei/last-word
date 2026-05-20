import 'package:flutter/services.dart';

abstract class IDictionaryService {
  Future<void> init();
  bool isValidWord(String word);
}

class PersianDictionaryService implements IDictionaryService {
  Set<String> _words = {};

  @override
  Future<void> init() async {
    final raw = await rootBundle.loadString('assets/words_fa.txt');
    _words = raw
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toSet();
  }

  @override
  bool isValidWord(String word) {
    return _words.contains(word.trim());
  }
}