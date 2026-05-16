import 'package:flutter/material.dart';

/// A reusable input field with the app's signature pill-shaped design.
///
/// Use it for text inputs, numeric inputs, multi-line notes, and even
/// read-only fields (like date pickers) by providing [onTap] and [trailing].
class StyledInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? prefixText;
  final String? valueText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int? maxLines;
  final double? height;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;

  const StyledInputField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixText,
    this.valueText,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines,
    this.height,
    this.trailing,
    this.onTap,
    this.validator,
    this.contentPadding,
    this.borderRadius = 100,
  });

  /// Whether this field is a multi-line text area (for label alignment)
  bool get _isMultiLine => (maxLines ?? 1) > 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: height ?? 70,
        padding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              _isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    _isMultiLine ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller != null)
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        readOnly: readOnly,
                        keyboardType: keyboardType,
                        maxLines: maxLines ?? 1,
                        validator: validator,
                        decoration: InputDecoration(
                          hintText: hintText,
                          prefixText: prefixText,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          fillColor: theme.colorScheme.surface.withValues(
                            alpha: 0,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: textTheme.bodyLarge?.copyWith(
                          height:
                              maxLines != null && maxLines! > 1 ? 1.5 : null,
                        ),
                      ),
                    )
                  else if (valueText != null)
                    Text(
                      valueText!,
                      style: textTheme.bodyLarge?.copyWith(
                        color: readOnly
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.only(
                  top: _isMultiLine ? 4 : 0,
                ),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
