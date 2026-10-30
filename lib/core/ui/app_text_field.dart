import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// Pole tekstowe (GUI 5.6): 56 dp, promień 16, obrys 2 dp.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.readOnly = false,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;

  /// Etykieta nad polem – tylko w formularzach wielopolowych.
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 2),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label!, style: text.labelMedium),
          ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
          cursorColor: t.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w500, color: t.textMuted),
            errorStyle: text.labelMedium!.copyWith(color: t.danger),
            filled: true,
            fillColor: t.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            constraints: const BoxConstraints(minHeight: 56),
            enabledBorder: border(t.border),
            focusedBorder: border(t.accent),
            errorBorder: border(t.danger),
            focusedErrorBorder: border(t.danger),
          ),
        ),
      ],
    );
  }
}
