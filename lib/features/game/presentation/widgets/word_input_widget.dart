import 'package:flutter/material.dart';

class WordInputWidget extends StatefulWidget {
  const WordInputWidget({
    super.key,
    required this.requiredLetter,
    required this.enabled,
    required this.onSubmit,
    this.errorMessage,
  });

  final String requiredLetter;
  final bool enabled;
  final void Function(String word) onSubmit;
  final String? errorMessage;

  @override
  State<WordInputWidget> createState() => _WordInputWidgetState();
}

class _WordInputWidgetState extends State<WordInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void didUpdateWidget(WordInputWidget old) {
    super.didUpdateWidget(old);
    // Clear and re-focus whenever the required letter changes (word accepted).
    if (old.requiredLetter != widget.requiredLetter) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Prompt label ──────────────────────────────────────────────────
        Text(
          'کلمه‌ای بنویس که با این حرف شروع شود',
          textDirection: TextDirection.rtl,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),

        // ── Required letter ───────────────────────────────────────────────
        Text(
          '« ${widget.requiredLetter} »',
          textDirection: TextDirection.rtl,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: 20),

        // ── Text field ────────────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,

            // Persian-specific settings
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            autocorrect: false,
            enableSuggestions: false,
            // TextCapitalization is irrelevant for Persian but harmless
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,

            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '${widget.requiredLetter}...',
              hintTextDirection: TextDirection.rtl,
              errorText: widget.errorMessage,
              // Send button on the LEFT side (RTL layout)
              prefixIcon: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: widget.enabled ? _submit : null,
                tooltip: 'ارسال',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
