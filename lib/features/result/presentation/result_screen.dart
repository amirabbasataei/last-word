import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/services/storage_service.dart';
import '../cubit/result_cubit.dart';
import '../cubit/result_state.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.words,
    this.isNewRecord = false,
  });

  final int score;
  final List<String> words;
  final bool isNewRecord;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResultCubit(
        storageService: StorageService(),
        score: score,
        words: words,
        isNewRecord: isNewRecord,
      )..load(),
      child: const _ResultView(),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ResultCubit, ResultState>(
          builder: (context, state) {
            if (state is ResultLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ResultLoaded) {
              return _ResultContent(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.state});

  final ResultLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),

          // ── New record badge ────────────────────────────────────────
          if (state.isNewRecord) ...[
            Center(child: _NewRecordBadge()),
            const SizedBox(height: 24),
          ],

          // ── Big score ──────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  '${state.score}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 88,
                    color: theme.colorScheme.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.score == 1 ? 'word' : 'words',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Stat cards ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Best score',
                  value: '${state.highScore}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.link_rounded,
                  label: 'Chain length',
                  value: '${state.words.length - 1}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Word chain scroll ──────────────────────────────────────
          if (state.words.length > 1) ...[
            Text(
              'Your chain',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.words.length - 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final word = state.words[i + 1];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      word,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const Spacer(flex: 2),

          // ── Actions ────────────────────────────────────────────────
          FilledButton(
            onPressed: () => context.go(AppRouter.game),
            child: const Text('Play again'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(AppRouter.home),
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }
}

class _NewRecordBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Text(
            'New record!',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
