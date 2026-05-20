import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required IStorageService storageService})
      : _storageService = storageService,
        super(const HomeInitial());

  final IStorageService _storageService;

  Future<void> loadHighScore() async {
    emit(const HomeLoading());
    final highScore = await _storageService.getHighScore();
    emit(HomeLoaded(highScore: highScore));
  }
}
