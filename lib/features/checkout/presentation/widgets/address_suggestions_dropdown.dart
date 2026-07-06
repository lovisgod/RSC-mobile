import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/nominatim_result.dart';
import '../../../../core/theme/app_colors.dart';

class AddressSuggestionsDropdown extends StatelessWidget {
  const AddressSuggestionsDropdown({
    super.key,
    required this.suggestions,
    required this.isSearching,
    required this.onSelect,
  });

  final List<NominatimResult> suggestions;
  final bool isSearching;
  final ValueChanged<NominatimResult> onSelect;

  static const double _maxHeight = 220;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Material(
        elevation: 6,
        color: AppColors.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _maxHeight),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isSearching && suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 10),
            Text(
              AppStrings.searchingAddresses,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          AppStrings.noAddressesInZone,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: suggestions.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final result = suggestions[index];
        final subtitle = result.displayName.length > 50
            ? '${result.displayName.substring(0, 50)}...'
            : result.displayName;
        return ListTile(
          dense: true,
          leading: const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 18,
          ),
          title: Text(
            result.shortAddress,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () => onSelect(result),
        );
      },
    );
  }
}
