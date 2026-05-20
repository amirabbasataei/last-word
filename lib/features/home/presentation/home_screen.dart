import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../app/router/app_router.dart';
import '../../../core/services/storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(storageService: StorageService())..loadHighScore(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Title
              Text(
                'Last\nWord',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Type a word starting with the last letter.\nBeat the clock.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              // High score card
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded && state.highScore > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HighScoreCard(highScore: state.highScore),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Play button
              FilledButton(
                onPressed: () => context.go(AppRouter.game),
                child: const Text('Play'),
              ),
              const SizedBox(height: 32),
              // Rules
              _RulesCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighScoreCard extends StatelessWidget {
  const _HighScoreCard({required this.highScore});

  final int highScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'Best score',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          Text(
            '$highScore ${highScore == 1 ? 'word' : 'words'}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
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
          Text(
            'How to play',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const _RuleRow(
            icon: Icons.arrow_forward_rounded,
            text: 'Type a word starting with the last letter of the previous word',
          ),
          const _RuleRow(
            icon: Icons.timer_outlined,
            text: 'Timer shrinks every round — stay sharp',
          ),
          const _RuleRow(
            icon: Icons.block_rounded,
            text: 'No repeated words allowed',
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
