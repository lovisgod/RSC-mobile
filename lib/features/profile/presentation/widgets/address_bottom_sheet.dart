import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/create_address_request_model.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/enums/address_label.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key, this.existingAddress});

  final DeliveryAddressEntity? existingAddress;

  static Future<void> show(
    BuildContext context, {
    DeliveryAddressEntity? existingAddress,
  }) {
    final cubit = context.read<AddressCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: AddressBottomSheet(existingAddress: existingAddress),
      ),
    );
  }

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  late AddressLabel _selectedLabel;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  bool _isDefault = false;

  bool get _isEditMode => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAddress;
    _selectedLabel = existing != null
        ? AddressLabelExtension.fromString(existing.label)
        : AddressLabel.home;
    _addressLineCtrl = TextEditingController(text: existing?.addressLine ?? '');
    _cityCtrl = TextEditingController(text: existing?.city ?? '');
    _stateCtrl = TextEditingController(text: existing?.state ?? '');
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _addressLineCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final request = CreateAddressRequestModel(
      label: _selectedLabel.displayName,
      addressLine: _addressLineCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? 'Lagos' : _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim().isEmpty ? 'Lagos' : _stateCtrl.text.trim(),
      latitude: CreateAddressRequestModel.placeholderLatitude,
      longitude: CreateAddressRequestModel.placeholderLongitude,
      isDefault: _isDefault,
    );

    final cubit = context.read<AddressCubit>();
    if (_isEditMode) {
      cubit.updateAddress(widget.existingAddress!.id, request);
    } else {
      cubit.createAddress(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressCubit, AddressState>(
      listenWhen: (previous, current) =>
          previous.isSubmitting && !current.isSubmitting,
      listener: (context, state) {
        if (state.error == null) {
          Navigator.of(context).pop();
          AppSnackbar.show(
            context,
            message: _isEditMode
                ? AppStrings.addressUpdated
                : AppStrings.addressSaved,
            emoji: '',
            backgroundColor: AppColors.navy,
          );
        } else {
          AppSnackbar.show(
            context,
            message: state.error!,
            type: AppSnackbarType.error,
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditMode ? AppStrings.editAddress : AppStrings.addAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 20),

                // ── Label selector ──────────────────────────────────────────
                const _FieldLabel(AppStrings.addressLabelSection),
                const SizedBox(height: 8),
                Row(
                  children: AddressLabel.values
                      .map(
                        (label) => _LabelChip(
                          label: label,
                          isSelected: _selectedLabel == label,
                          onTap: () => setState(() => _selectedLabel = label),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                // ── Address line ────────────────────────────────────────────
                const _FieldLabel(AppStrings.addressLine),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _addressLineCtrl,
                  hint: AppStrings.hintAddressLine,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // ── City / State ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(AppStrings.labelCity),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _cityCtrl,
                            hint: AppStrings.hintCity,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(AppStrings.labelState),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _stateCtrl,
                            hint: AppStrings.hintState,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Set as default ──────────────────────────────────────────
                Row(
                  children: [
                    Switch(
                      value: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                      activeThumbColor: AppColors.navy,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        AppStrings.setAsDefaultAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Coordinates note ────────────────────────────────────────
                const Text(
                  AppStrings.coordinatesAutoSet,
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
                const SizedBox(height: 24),

                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) {
                    final canSave = _addressLineCtrl.text.trim().isNotEmpty;
                    return AppButton(
                      label: AppStrings.saveAddress,
                      isLoading: state.isSubmitting,
                      backgroundColor: AppColors.navy,
                      onPressed: canSave && !state.isSubmitting
                          ? _submit
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AddressLabel label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy : AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                label.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textLabel,
        letterSpacing: 0.5,
      ),
    );
  }
}
