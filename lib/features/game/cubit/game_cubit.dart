import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/dictionary_service.dart';
import '../../../core/services/storage_service.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit({
    required IDictionaryService dictionaryService,
    required IStorageService storageService,
  })  : _dictionaryService = dictionaryService,
        _storageService = storageService,
        super(const GameState());

  final IDictionaryService _dictionaryService;
  final IStorageService _storageService;
  Timer? _countdownTimer;

  // ─── Public API ────────────────────────────────────────────────────────────

  void startGame() {
    _cancelTimer();
    final seed = _randomSeed();
    final maxTime = _calculateMaxTime(0);

    emit(GameState(
      status: GameStatus.playing,
      currentWord: seed,
      requiredLetter: _lastLetterOf(seed),
      usedWords: [seed],
      score: 0,
      timeLeft: maxTime,
      maxTime: maxTime,
    ));

    _startCountdown();
  }

  Future<void> submitWord(String raw) async {
    if (state.status != GameStatus.playing) return;

    // Persian words are not case-sensitive, but normalise whitespace
    final word = raw.trim();
    if (word.isEmpty) return;

    // ── Local checks ──────────────────────────────────────────────────────
    if (!word.startsWith(state.requiredLetter)) {
      emit(state.copyWith(wordError: WordError.wrongLetter));
      return;
    }
    if (state.usedWords.contains(word)) {
      emit(state.copyWith(wordError: WordError.alreadyUsed));
      return;
    }

    // ── Pause timer & validate ────────────────────────────────────────────
    _cancelTimer();
    emit(state.copyWith(
      status: GameStatus.validating,
      clearWordError: true,
    ));

    final isReal = _dictionaryService.isValidWord(word);
    if (isClosed) return;

    if (!isReal) {
      emit(state.copyWith(
        status: GameStatus.playing,
        wordError: WordError.notAWord,
      ));
      _startCountdown();
      return;
    }

    // ── Accept the word ───────────────────────────────────────────────────
    final newScore = state.score + 1;
    final newMax = _calculateMaxTime(newScore);
    final nextLetter = _lastLetterOf(word);

    emit(state.copyWith(
      status: GameStatus.playing,
      currentWord: word,
      requiredLetter: nextLetter,
      usedWords: [...state.usedWords, word],
      score: newScore,
      timeLeft: newMax,
      maxTime: newMax,
      clearWordError: true,
    ));

    _startCountdown();
  }

  // ─── Timer ─────────────────────────────────────────────────────────────────

  void _startCountdown() {
    _cancelTimer();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.timerTickMilliseconds),
      (_) {
        final next =
            state.timeLeft - AppConstants.timerTickMilliseconds / 1000;
        if (next <= 0) {
          _cancelTimer();
          _endGame();
        } else {
          emit(state.copyWith(timeLeft: next));
        }
      },
    );
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> _endGame() async {
    final currentScore = state.score;
    final highScore = await _storageService.getHighScore();
    await _storageService.saveHighScoreIfBeaten(currentScore);
    if (isClosed) return;
    emit(state.copyWith(
      status: GameStatus.gameOver,
      isNewRecord: currentScore > highScore,
    ));
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  double _calculateMaxTime(int score) {
    return (AppConstants.initialTimerSeconds -
            score * AppConstants.timerDecrementPerWord)
        .clamp(AppConstants.minTimerSeconds, AppConstants.initialTimerSeconds);
  }

  /// Returns the last meaningful letter of a Persian word.
  /// Strips trailing ZWNJ (U+200C) and whitespace first, since some
  /// word lists include a trailing zero-width non-joiner that is not a letter.
  String _lastLetterOf(String word) {
    final cleaned = word.trimRight().replaceAll('\u200C', '');
    return cleaned[cleaned.length - 1];
  }

  String _randomSeed() {
    final rng = Random();
    return AppConstants.seedWords[rng.nextInt(AppConstants.seedWords.length)];
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
