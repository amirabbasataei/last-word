import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'result_state.dart';

class ResultCubit extends Cubit<ResultState> {
  ResultCubit({
    required IStorageService storageService,
    required int score,
    required List<String> words,
    required bool isNewRecord,
  })  : _storageService = storageService,
        _score = score,
        _words = words,
        _isNewRecord = isNewRecord,
        super(const ResultLoading());

  final IStorageService _storageService;
  final int _score;
  final List<String> _words;
  final bool _isNewRecord;

  Future<void> load() async {
    final highScore = await _storageService.getHighScore();
    emit(ResultLoaded(
      score: _score,
      words: _words,
      highScore: highScore,
      isNewRecord: _isNewRecord,
    ));
  }
}
