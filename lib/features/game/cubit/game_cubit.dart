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

    final word = raw.trim().toLowerCase();
    if (word.isEmpty) return;

    // ── Local checks (instant, no network needed) ──
    if (!word.startsWith(state.requiredLetter.toLowerCase())) {
      emit(state.copyWith(wordError: WordError.wrongLetter));
      return;
    }
    if (state.usedWords.contains(word)) {
      emit(state.copyWith(wordError: WordError.alreadyUsed));
      return;
    }

    // ── Pause timer while we hit the API ──
    _cancelTimer();
    emit(state.copyWith(
      status: GameStatus.validating,
      clearWordError: true,
    ));

    final isReal = await _dictionaryService.isValidWord(word);

    if (isClosed) return; // cubit was closed mid-await

    if (!isReal) {
      emit(state.copyWith(
        status: GameStatus.playing,
        wordError: WordError.notAWord,
      ));
      _startCountdown();
      return;
    }

    // ── Accept the word ──
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

  // ─── Timer internals ───────────────────────────────────────────────────────

  void _startCountdown() {
    _cancelTimer();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.timerTickMilliseconds),
      (_) {
        final next = state.timeLeft - AppConstants.timerTickMilliseconds / 1000;
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

  /// Timer shrinks by [timerDecrementPerWord] per correct word, clamped to min.
  double _calculateMaxTime(int score) {
    return (AppConstants.initialTimerSeconds -
            score * AppConstants.timerDecrementPerWord)
        .clamp(AppConstants.minTimerSeconds, AppConstants.initialTimerSeconds);
  }

  String _lastLetterOf(String word) =>
      word[word.length - 1].toUpperCase();

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
