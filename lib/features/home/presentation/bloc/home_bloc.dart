import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/socket_service.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_outlets_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetOutletsUseCase _getOutlets;
  final HomeRepository _homeRepository;
  final SocketService _socketService;

  HomeBloc(this._getOutlets, this._homeRepository, this._socketService)
    : super(const HomeInitial()) {
    on<HomeFetchRequested>(_onFetch);
    on<OutletStatusChanged>(_onOutletStatusChanged);

    // `outlet:status_update` is broadcast to all authenticated clients — no
    // room subscription needed, just register the listener once.
    _socketService.on('outlet:status_update', _handleOutletStatusUpdate);
  }

  void _handleOutletStatusUpdate(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    final outletId = data['outletId'] as String?;
    final isOnline = data['isOnline'] as bool?;
    if (outletId == null || isOnline == null) return;
    add(OutletStatusChanged(outletId: outletId, isOnline: isOnline));
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

  void _onOutletStatusChanged(
    OutletStatusChanged event,
    Emitter<HomeState> emit,
  ) {
    debugPrint(
      '[RSC Socket] Outlet ${event.outletId} isOnline: ${event.isOnline}',
    );
    _homeRepository.updateOutletOnlineStatus(event.outletId, event.isOnline);

    final current = state;
    if (current is HomeLoaded) {
      final outlets = [
        for (final outlet in current.outlets)
          outlet.id == event.outletId
              ? outlet.copyWith(isOnline: event.isOnline)
              : outlet,
      ];
      emit(HomeLoaded(outlets));
    }
  }

  @override
  Future<void> close() {
    _socketService.off('outlet:status_update');
    return super.close();
  }
}
