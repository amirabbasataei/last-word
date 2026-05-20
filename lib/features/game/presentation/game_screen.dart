import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/services/dictionary_service.dart';
import '../../../core/services/storage_service.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import 'widgets/timer_widget.dart';
import 'widgets/word_input_widget.dart';
import 'widgets/word_chain_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(
        dictionaryService: DictionaryService(),
        storageService: StorageService(),
      )..startGame(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status && curr.status == GameStatus.gameOver,
      listener: (context, state) {
        context.go(AppRouter.result, extra: {
          'score': state.score,
          'words': state.usedWords,
          'isNewRecord': state.isNewRecord,
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go(AppRouter.home),
            tooltip: 'Quit game',
          ),
          title: BlocSelector<GameCubit, GameState, int>(
            selector: (state) => state.score,
            builder: (context, score) => Text(
              '$score ${score == 1 ? 'word' : 'words'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Timer ──────────────────────────────────────────────
                Center(
                  child: BlocSelector<GameCubit, GameState,
                      ({double timeLeft, double progress})>(
                    selector: (s) =>
                        (timeLeft: s.timeLeft, progress: s.timerProgress),
                    builder: (context, data) => TimerWidget(
                      timeLeft: data.timeLeft,
                      progress: data.progress,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Word input ─────────────────────────────────────────
                BlocSelector<GameCubit, GameState,
                    ({String letter, bool enabled, String? error})>(
                  selector: (s) => (
                    letter: s.requiredLetter,
                    enabled: s.status == GameStatus.playing,
                    error: s.wordErrorMessage,
                  ),
                  builder: (context, data) => WordInputWidget(
                    requiredLetter: data.letter,
                    enabled: data.enabled,
                    errorMessage: data.error,
                    onSubmit: context.read<GameCubit>().submitWord,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Validating indicator ───────────────────────────────
                BlocSelector<GameCubit, GameState, GameStatus>(
                  selector: (s) => s.status,
                  builder: (context, status) => AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: status == GameStatus.validating
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checking…',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.55),
                                  ),
                        ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ),

                const Spacer(),

                // ── Word chain ─────────────────────────────────────────
                BlocSelector<GameCubit, GameState, List<String>>(
                  selector: (s) => s.usedWords,
                  builder: (context, words) => WordChainWidget(words: words),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
