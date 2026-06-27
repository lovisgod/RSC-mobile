import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../menu/domain/entities/modifier_group.dart';

class ModifierGroupCard extends StatelessWidget {
  const ModifierGroupCard({
    super.key,
    required this.group,
    required this.selectedIds,
    required this.onToggle,
  });

  final ModifierGroup group;

  /// Set of modifier IDs currently selected in this group.
  final Set<String> selectedIds;

  /// Called with (modifierId, selected) — consumer updates state.
  final void Function(String modifierId, bool selected) onToggle;

  bool get _isSingleSelect => group.isRequired && group.maxSelections == 1;
  bool get _maxReached => selectedIds.length >= group.maxSelections;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  group.isRequired ? AppStrings.required : AppStrings.optional,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: group.isRequired
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // ── Modifier rows ──────────────────────────────────────────────
          ...group.modifiers.asMap().entries.map((entry) {
            final index = entry.key;
            final mod = entry.value;
            final isSelected = selectedIds.contains(mod.id);
            final isDisabled =
                !isSelected && _maxReached && !_isSingleSelect;

            return Column(
              children: [
                _ModifierRow(
                  name: mod.name,
                  priceDelta: mod.priceDelta,
                  isSelected: isSelected,
                  isSingleSelect: _isSingleSelect,
                  isDisabled: isDisabled,
                  onToggle: (val) {
                    if (_isSingleSelect) {
                      // deselect everything else, select this one
                      for (final m in group.modifiers) {
                        if (m.id != mod.id && selectedIds.contains(m.id)) {
                          onToggle(m.id, false);
                        }
                      }
                      onToggle(mod.id, val);
                    } else {
                      onToggle(mod.id, val);
                    }
                  },
                ),
                if (index < group.modifiers.length - 1)
                  const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: AppColors.divider,
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ModifierRow extends StatelessWidget {
  const _ModifierRow({
    required this.name,
    required this.priceDelta,
    required this.isSelected,
    required this.isSingleSelect,
    required this.isDisabled,
    required this.onToggle,
  });

  final String name;
  final double priceDelta;
  final bool isSelected;
  final bool isSingleSelect;
  final bool isDisabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : () => onToggle(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Checkbox or radio
            if (isSingleSelect)
              _RadioIndicator(isSelected: isSelected, isDisabled: isDisabled)
            else
              _CheckboxIndicator(
                  isSelected: isSelected, isDisabled: isDisabled),

            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDisabled ? AppColors.textHint : AppColors.textPrimary,
                ),
              ),
            ),

            // Price delta
            if (priceDelta > 0)
              Text(
                '+₦${priceDelta.toInt()}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxIndicator extends StatelessWidget {
  const _CheckboxIndicator(
      {required this.isSelected, required this.isDisabled});

  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDisabled ? AppColors.textHint : AppColors.inputBorder),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected, required this.isDisabled});

  final bool isSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.inputBorder,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
