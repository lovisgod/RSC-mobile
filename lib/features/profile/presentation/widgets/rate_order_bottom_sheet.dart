import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/line_item_entity.dart';
import '../cubit/rating_cubit.dart';
import '../cubit/rating_state.dart';

/// Star-rating sheet for every line item of an order. Expects a [RatingCubit]
/// above it (BlocProvider.value with the singleton from getIt).
class RateOrderBottomSheet extends StatefulWidget {
  const RateOrderBottomSheet({
    super.key,
    required this.lineItems,
    required this.orderId,
  });

  final List<LineItemEntity> lineItems;
  final String orderId;

  @override
  State<RateOrderBottomSheet> createState() => _RateOrderBottomSheetState();
}

class _RateOrderBottomSheetState extends State<RateOrderBottomSheet> {
  /// Selected stars per menuItemId; absent = untouched.
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _comments = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final controller in _comments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _commentController(String menuItemId) =>
      _comments.putIfAbsent(menuItemId, TextEditingController.new);

  Future<void> _submit() async {
    if (_isSubmitting || _ratings.isEmpty) return;
    setState(() => _isSubmitting = true);

    final ratingCubit = context.read<RatingCubit>();
    for (final item in widget.lineItems) {
      final rating = _ratings[item.menuItemId];
      if (rating == null) continue;
      final comment = _comments[item.menuItemId]?.text.trim();
      await ratingCubit.submitRating(
        item.menuItemId,
        rating,
        comment: comment == null || comment.isEmpty ? null : comment,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.show(
      context,
      message: AppStrings.thanksForFeedback,
      emoji: '',
      backgroundColor: AppColors.navy,
    );
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.rateYourOrder,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.howWasYourFood,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < widget.lineItems.length; i++) ...[
                  _ItemRatingRow(
                    item: widget.lineItems[i],
                    rating: _ratings[widget.lineItems[i].menuItemId] ?? 0,
                    commentController: _commentController(
                      widget.lineItems[i].menuItemId,
                    ),
                    onRatingChanged: (stars) => setState(
                      () => _ratings[widget.lineItems[i].menuItemId] = stars,
                    ),
                  ),
                  if (i < widget.lineItems.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
                const SizedBox(height: 16),
                BlocBuilder<RatingCubit, RatingState>(
                  builder: (context, state) => AppButton(
                    label: AppStrings.submitRatings,
                    backgroundColor: AppColors.navy,
                    isLoading: _isSubmitting || state.isSubmitting,
                    onPressed: _ratings.isEmpty ? null : _submit,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.skip,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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

class _ItemRatingRow extends StatelessWidget {
  const _ItemRatingRow({
    required this.item,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
  });

  final LineItemEntity item;
  final int rating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🍽️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemNameSnapshot,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.modifiers.isNotEmpty)
                      Text(
                        item.modifiers.map((m) => m.name).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StarRow(rating: rating, onChanged: onRatingChanged),
            ],
          ),
          if (rating > 0) ...[
            const SizedBox(height: 10),
            AppTextField(
              controller: commentController,
              hint: AppStrings.addComment,
              keyboardType: TextInputType.text,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return GestureDetector(
          onTap: () => onChanged(index + 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 24,
            color: filled ? AppColors.starRating : AppColors.divider,
          ),
        );
      }),
    );
  }
}
