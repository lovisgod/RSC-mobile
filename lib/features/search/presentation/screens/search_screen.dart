import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';
import '../widgets/search_result_card.dart';

// ── Results view (shared by Home's inline search) ───────────────────────────

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const _ShimmerResults();
        }
        if (state is SearchEmpty) {
          return _NoResults(query: state.query);
        }
        if (state is SearchLoaded) {
          return _ResultsList(state: state);
        }
        if (state is SearchError) {
          return _ErrorBody(message: state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😶', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              '${AppStrings.noResultsFor} "$query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.trySearchingBy,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Shimmer placeholders ──────────────────────────────────────────────────────

class _ShimmerResults extends StatelessWidget {
  const _ShimmerResults();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: 5,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            ShimmerBox(height: 80, width: 80, radius: 13),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 14, radius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(height: 12, radius: 5),
                  SizedBox(height: 6),
                  ShimmerBox(height: 12, width: 120, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.state});

  final SearchLoaded state;

  @override
  Widget build(BuildContext context) {
    final grouped = state.groupedByOutlet;
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      children: [
        for (final outletId in grouped.keys) ...[
          _OutletGroupHeader(
            outletName: grouped[outletId]!.first.outlet.name,
          ),
          ...grouped[outletId]!.map(
            (r) => SearchResultCard(result: r),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _OutletGroupHeader extends StatelessWidget {
  const _OutletGroupHeader({required this.outletName});

  final String outletName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const Text('📍', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            outletName.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
