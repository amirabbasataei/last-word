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
    'سلام',    // ends با م
    'کتاب',    // ends با ب
    'خانه',    // ends با ه
    'درس',     // ends با س
    'آموزش',   // ends با ش
    'روز',     // ends با ز
    'دوست',    // ends با ت
    'کار',     // ends با ر
    'بازی',    // ends با ی
    'ماشین',   // ends با ن
    'نان',     // ends با ن
    'چای',     // ends با ی
    'باران',   // ends با ن
    'آتش',     // ends با ش
    'دریا',    // ends با ا
    'کوه',     // ends با ه
    'گل',      // ends با ل
    'مرغ',     // ends با غ
    'پرنده',   // ends با ه
    'زمین',    // ends با ن
    'آسمان',   // ends با ن
    'رنگ',     // ends با گ
    'میز',     // ends با ز
    'صندلی',   // ends با ی
    'پنجره',   // ends با ه
  ];
}
