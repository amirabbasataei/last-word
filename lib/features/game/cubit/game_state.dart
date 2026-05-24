import 'package:equatable/equatable.dart';

enum GameStatus { initial, playing, validating, gameOver }

enum WordError { wrongLetter, alreadyUsed, notAWord }

class GameState extends Equatable {
  const GameState({
    this.status = GameStatus.initial,
    this.currentWord = '',
    this.requiredLetter = '',
    this.usedWords = const [],
    this.score = 0,
    this.timeLeft = 5.0,
    this.maxTime = 5.0,
    this.wordError,
    this.isNewRecord = false,
  });

  final GameStatus status;

  /// The last accepted word — new words must start with its last letter.
  final String currentWord;

  /// The letter the player must start their next word with (uppercase).
  final String requiredLetter;

  final List<String> usedWords;
  final int score;

  /// Seconds remaining in the current round.
  final double timeLeft;

  /// Maximum seconds for the current round (used to draw the progress ring).
  final double maxTime;

  /// Non-null when the player's input was rejected.
  final WordError? wordError;

  final bool isNewRecord;

  double get timerProgress => (timeLeft / maxTime).clamp(0.0, 1.0);

  String? get wordErrorMessage {
    return switch (wordError) {
      WordError.wrongLetter => 'کلمه باید با «$requiredLetter» شروع شود',
      WordError.alreadyUsed => 'این کلمه قبلاً استفاده شده!',
      WordError.notAWord => 'این کلمه در فرهنگ لغت یافت نشد',
      null => null,
    };
  }

  GameState copyWith({
    GameStatus? status,
    String? currentWord,
    String? requiredLetter,
    List<String>? usedWords,
    int? score,
    double? timeLeft,
    double? maxTime,
    WordError? wordError,
    bool clearWordError = false,
    bool? isNewRecord,
  }) {
    return GameState(
      status: status ?? this.status,
      currentWord: currentWord ?? this.currentWord,
      requiredLetter: requiredLetter ?? this.requiredLetter,
      usedWords: usedWords ?? this.usedWords,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      maxTime: maxTime ?? this.maxTime,
      wordError: clearWordError ? null : (wordError ?? this.wordError),
      isNewRecord: isNewRecord ?? this.isNewRecord,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentWord,
        requiredLetter,
        usedWords,
        score,
        timeLeft,
        maxTime,
        wordError,
        isNewRecord,
      ];
}
