import 'package:flutter/material.dart';

class WordChainWidget extends StatefulWidget {
  const WordChainWidget({super.key, required this.words});

  /// All words in the chain so far (index 0 is the seed word).
  final List<String> words;

  @override
  State<WordChainWidget> createState() => _WordChainWidgetState();
}

class _WordChainWidgetState extends State<WordChainWidget> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(WordChainWidget old) {
    super.didUpdateWidget(old);
    if (old.words.length != widget.words.length) {
      // Scroll to the end whenever a new word is added.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Exclude the seed word (index 0) from the visible chain.
    final visibleWords = widget.words.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Word chain',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: visibleWords.isEmpty
              ? Text(
                  'Your words will appear here…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    fontStyle: FontStyle.italic,
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleWords.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isLatest = index == visibleWords.length - 1;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLatest
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: isLatest
                            ? Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              )
                            : null,
                      ),
                      child: Text(
                        visibleWords[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isLatest ? FontWeight.w600 : FontWeight.normal,
                          color: isLatest
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
