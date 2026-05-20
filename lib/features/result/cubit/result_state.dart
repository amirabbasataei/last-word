import 'package:equatable/equatable.dart';

sealed class ResultState extends Equatable {
  const ResultState();

  @override
  List<Object?> get props => [];
}

final class ResultLoading extends ResultState {
  const ResultLoading();
}

final class ResultLoaded extends ResultState {
  const ResultLoaded({
    required this.score,
    required this.words,
    required this.highScore,
    required this.isNewRecord,
  });

  final int score;
  final List<String> words;
  final int highScore;
  final bool isNewRecord;

  @override
  List<Object?> get props => [score, words, highScore, isNewRecord];
}
