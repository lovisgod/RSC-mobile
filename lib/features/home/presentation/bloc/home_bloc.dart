import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_outlets_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetOutletsUseCase _getOutlets;

  HomeBloc(this._getOutlets) : super(const HomeInitial()) {
    on<HomeFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    HomeFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final outlets = await _getOutlets();
      emit(HomeLoaded(outlets));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
