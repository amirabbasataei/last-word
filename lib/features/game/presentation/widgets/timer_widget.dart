import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({
    super.key,
    required this.timeLeft,
    required this.progress,
  });

  final double timeLeft;

  /// A value from 0.0 (empty) to 1.0 (full), used to draw the arc.
  final double progress;

  Color _resolveColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (progress > 0.5) return scheme.primary;
    if (progress > 0.25) return Colors.orange.shade600;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);

    return SizedBox.square(
      dimension: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 120,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            timeLeft.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
