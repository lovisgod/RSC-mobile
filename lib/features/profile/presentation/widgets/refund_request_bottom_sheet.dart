import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/usecases/request_refund_usecase.dart';

/// Collects a refund reason and submits the request against the order's
/// payment reference. Pops with `true` on success so the opener can show the
/// confirmation snackbar.
class RefundRequestBottomSheet extends StatefulWidget {
  const RefundRequestBottomSheet({super.key, required this.order});

  final OrderHistoryEntity order;

  @override
  State<RefundRequestBottomSheet> createState() =>
      _RefundRequestBottomSheetState();
}

class _RefundRequestBottomSheetState extends State<RefundRequestBottomSheet> {
  final TextEditingController _reasonController = TextEditingController();
  String _reason = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _reason.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      // amountMinor is the raw API value — already in minor units.
      await getIt<RequestRefundUsecase>()(
        widget.order.paymentReference,
        widget.order.totalMinor,
        _reason.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.show(context, message: e.message, type: AppSnackbarType.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.show(
        context,
        message: AppStrings.somethingWentWrong,
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    AppStrings.requestRefund,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${AppStrings.orderTotalLabel} '
                    '${formatNaira(widget.order.total)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.reasonForRefund,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLabel,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _reasonController,
                  hint: AppStrings.refundReason,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  minLines: 3,
                  onChanged: (value) => setState(() => _reason = value),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: AppStrings.submitRequest,
                  backgroundColor: AppColors.error,
                  isLoading: _isSubmitting,
                  onPressed: _reason.trim().isEmpty ? null : _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
