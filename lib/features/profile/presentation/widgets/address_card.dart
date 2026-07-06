import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/enums/address_label.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import 'address_bottom_sheet.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address});

  final DeliveryAddressEntity address;

  @override
  Widget build(BuildContext context) {
    final label = AddressLabelExtension.fromString(address.label);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (address.isDefault) const _DefaultBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address.addressLine,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${address.city}, ${address.state}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, state) {
              final isSettingDefault = state.settingDefaultId == address.id;
              return Row(
                children: [
                  if (!address.isDefault)
                    _ActionButton(
                      label: AppStrings.setAsDefault,
                      color: AppColors.primary,
                      isLoading: isSettingDefault,
                      onTap: isSettingDefault
                          ? null
                          : () => context
                                .read<AddressCubit>()
                                .setDefaultAddress(address.id),
                    ),
                  _ActionButton(
                    label: AppStrings.edit,
                    color: AppColors.navy,
                    onTap: () => AddressBottomSheet.show(
                      context,
                      existingAddress: address,
                    ),
                  ),
                  _ActionButton(
                    label: AppStrings.delete,
                    color: AppColors.error,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteAddress),
        content: Text(
          '${AppStrings.removeAddressConfirmPrefix}${address.label}'
          '${AppStrings.removeAddressConfirmSuffix}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteAddress(address.id);
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        AppStrings.defaultAddressBadge,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
    );
  }
}
