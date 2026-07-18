import 'package:flutter/material.dart';

import '../../features/checkout/data/models/address_suggestion_model.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Address text field whose suggestions render in the app's root [Overlay]
/// rather than the local widget tree, so the dropdown always paints above
/// scroll views, cards, and other siblings regardless of clipping or
/// z-order — the same approach Google's Places Autocomplete widget uses.
class OverlayAddressField extends StatefulWidget {
  const OverlayAddressField({
    super.key,
    required this.controller,
    required this.hint,
    required this.suggestions,
    required this.isSearching,
    required this.isResolving,
    required this.onChanged,
    required this.onSuggestionTapped,
    required this.onClear,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hint;
  final List<AddressSuggestionModel> suggestions;
  final bool isSearching;
  final bool isResolving;
  final ValueChanged<String> onChanged;
  final ValueChanged<AddressSuggestionModel> onSuggestionTapped;
  final VoidCallback onClear;
  final FocusNode? focusNode;

  @override
  State<OverlayAddressField> createState() => _OverlayAddressFieldState();
}

class _OverlayAddressFieldState extends State<OverlayAddressField> {
  final LayerLink _layerLink = LayerLink();
  late final FocusNode _focusNode;
  OverlayEntry? _overlayEntry;

  static const double _dropdownOffsetY = 56;
  static const double _maxSuggestionsHeight = 280;
  static const int _minQueryLength = 3;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant OverlayAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final contentChanged =
        oldWidget.suggestions != widget.suggestions ||
        oldWidget.isSearching != widget.isSearching;
    if (!contentChanged) return;

    // The overlay's OverlayEntry isn't an ancestor of this widget, so
    // rebuilding it synchronously here (still inside this widget's own
    // build phase) trips "markNeedsBuild called during build". Defer to
    // the next frame instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_overlayEntry != null) {
        _updateOverlay();
      } else if (_focusNode.hasFocus && widget.suggestions.isNotEmpty) {
        _showOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final width = context.size?.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, _dropdownOffsetY),
          child: Material(
            type: MaterialType.transparency,
            child: _buildSuggestionsList(),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(14),
            child: Text('🏠', style: TextStyle(fontSize: 18)),
          ),
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.inputBorderFocused,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) {
          widget.onChanged(value);
          if (value.length >= _minQueryLength) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        },
        onTap: () {
          if (widget.suggestions.isNotEmpty) _showOverlay();
        },
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isResolving) return _loadingIndicator();

    if (widget.controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
        onPressed: () {
          widget.onClear();
          _removeOverlay();
        },
      );
    }

    if (widget.isSearching) return _loadingIndicator();

    return null;
  }

  Widget _loadingIndicator() => const Padding(
    padding: EdgeInsets.all(12),
    child: SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _buildSuggestionsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: _maxSuggestionsHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildSuggestionsContent(),
    );
  }

  Widget _buildSuggestionsContent() {
    if (widget.isSearching && widget.suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Text(
              AppStrings.searchingAddresses,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (widget.suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          AppStrings.noAddressesInZone,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.suggestions.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final suggestion = widget.suggestions[index];
        return InkWell(
          onTap: () {
            widget.onSuggestionTapped(suggestion);
            _removeOverlay();
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
