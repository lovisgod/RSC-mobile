import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/modifier_group.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/outlet_model.dart';

/// Real implementation of [HomeRepository]. Registered as a SINGLETON so the
/// outlets payload (outlets + their full nested menu) is fetched once and
/// cached in memory, then reused across home / outlet-detail / search without
/// redundant network calls.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  /// In-memory cache of the parsed outlets payload. Null until first fetch.
  List<OutletModel>? _cache;

  // ── Public API ──────────────────────────────────────────────────────────────

  @override
  Future<List<Outlet>> getOutlets() async {
    final outlets = await _outlets();
    return [
      for (var i = 0; i < outlets.length; i++)
        outlets[i].toEntity(isFeatured: i == 0),
    ];
  }

  @override
  Future<List<Outlet>> refreshOutlets() async {
    _cache = null;
    return getOutlets();
  }

  @override
  Future<List<MenuCategory>> getCategoriesForOutlet(String outletId) async {
    final outlet = await _outletById(outletId);
    if (outlet == null) return const [];
    return outlet.sortedCategories.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<MenuItem>> getItemsForCategory(String categoryId) async {
    final outlets = await _outlets();
    for (final outlet in outlets) {
      final items = outlet.itemsForCategory(categoryId);
      if (items.isNotEmpty) return items;
    }
    return const [];
  }

  @override
  Future<List<MenuItem>> getItemsForOutlet(String outletId) async {
    final outlet = await _outletById(outletId);
    if (outlet == null) return const [];
    return outlet.buildMenuItems();
  }

  @override
  Future<List<ModifierGroup>> getModifierGroupsForItem(
    String outletId,
    String menuItemId,
  ) async {
    final outlet = await _outletById(outletId);
    if (outlet == null) return const [];
    return outlet.modifierGroupsForItem(menuItemId);
  }

  // ── Cache + network ─────────────────────────────────────────────────────────

  Future<List<OutletModel>> _outlets() async {
    final cached = _cache;
    if (cached != null) return cached;
    return _cache = await _fetchOutlets();
  }

  Future<OutletModel?> _outletById(String outletId) async {
    final outlets = await _outlets();
    for (final outlet in outlets) {
      if (outlet.id == outletId) return outlet;
    }
    return null;
  }

  Future<List<OutletModel>> _fetchOutlets() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiConstants.outlets);
      final data = (response.data as Map<String, dynamic>?)?['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(OutletModel.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      // The DioClient error interceptor attaches a typed exception; surface it
      // so the bloc shows a clean message instead of a raw Dio error.
      final mapped = e.error;
      if (mapped is Exception) throw mapped;
      throw const ServerException(
        message: 'Could not load outlets. Please try again.',
      );
    }
  }
}
