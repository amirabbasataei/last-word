import 'package:flutter/material.dart';

class WordInputWidget extends StatefulWidget {
  const WordInputWidget({
    super.key,
    required this.requiredLetter,
    required this.enabled,
    required this.onSubmit,
    this.errorMessage,
    this.isValidWord,
  });

  final String requiredLetter;
  final bool enabled;
  final void Function(String word) onSubmit;
  final String? errorMessage;

  /// Optional synchronous lookup called on every keystroke.
  /// Returns true if the typed word exists in the dictionary.
  final bool Function(String word)? isValidWord;

  @override
  State<WordInputWidget> createState() => _WordInputWidgetState();
}

class _WordInputWidgetState extends State<WordInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// null  → field is empty, show no indicator
  /// true  → word found in dictionary
  /// false → word not found in dictionary
  bool? _wordExists;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void didUpdateWidget(WordInputWidget old) {
    super.didUpdateWidget(old);
    // Clear and re-focus whenever the required letter changes (word accepted).
    if (old.requiredLetter != widget.requiredLetter) {
      _controller.clear();
      // _onTextChanged will fire via the listener and reset _wordExists.
      _focusNode.requestFocus();
    }
  }

  void _onTextChanged() {
    final text = _controller.text.trim();

    if (text.isEmpty || widget.isValidWord == null) {
      if (_wordExists != null) setState(() => _wordExists = null);
      return;
    }

    final exists = widget.isValidWord!(text);
    if (exists != _wordExists) {
      setState(() => _wordExists = exists);
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
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Suffix icon based on real-time dictionary check ──────────────────
    Widget? suffixIcon;
    if (_wordExists != null) {
      suffixIcon = Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Icon(
          _wordExists!
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          color: _wordExists!
              ? Colors.green.shade600
              : theme.colorScheme.error,
          size: 22,
        ),
      );
    }

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
              // ✓ / ✗ on the RIGHT side (RTL layout = visually on the left)
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
