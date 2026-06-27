import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/usecases/search_items_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>()(events.debounce(duration), mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._useCase) : super(const SearchLoading()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 400)),
    );
    on<SearchCleared>(_onCleared);
  }

  final SearchItemsUseCase _useCase;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    emit(const SearchLoading());
    try {
      final results = await _useCase.call(query);
      // Only show empty state when the user actually typed something
      if (results.isEmpty && query.isNotEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchLoaded(results: results, query: query));
      }
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final results = await _useCase.call('');
      emit(SearchLoaded(results: results, query: ''));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }
}
