import 'package:flutter/material.dart';
import 'package:last_word/core/services/dictionary_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dictionary = PersianDictionaryService();
  await dictionary.init(); // loads the file once, builds the Set

  runApp(LastWordApp(dictionary: dictionary));
}
