class AppConstants {
  AppConstants._();

  static const String appName = 'Last Word';

  // Game mechanics
  static const double initialTimerSeconds = 15.0;
  static const double minTimerSeconds = 1.5;
  static const double timerDecrementPerWord = 0.2;
  static const int timerTickMilliseconds = 100;

  // Storage keys
  static const String highScoreKey = 'high_score';

  // Seed words (must all be lowercase)
  static const List<String> seedWords = [
    'apple', 'brave', 'cloud', 'dance', 'eagle',
    'flame', 'grape', 'horse', 'igloo', 'jungle',
    'knife', 'lemon', 'magic', 'night', 'ocean',
    'plane', 'queen', 'river', 'storm', 'tiger',
    'ultra', 'voice', 'wheat', 'xenon', 'yacht',
  ];
}
