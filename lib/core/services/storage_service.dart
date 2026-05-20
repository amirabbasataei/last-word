import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

abstract class IStorageService {
  Future<int> getHighScore();
  Future<void> saveHighScoreIfBeaten(int score);
}

class StorageService implements IStorageService {
  /// Returns the stored high score, or 0 if none exists.
  @override
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.highScoreKey) ?? 0;
  }

  /// Saves [score] only if it beats the current high score.
  @override
  Future<void> saveHighScoreIfBeaten(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(AppConstants.highScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(AppConstants.highScoreKey, score);
    }
  }
}
