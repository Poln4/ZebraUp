import 'package:flutter/material.dart';

/// Generic search/filter text field with a clear button. Extracted from
/// botiquin_tab.dart's private `_SearchField` when sintomas_tab.dart (Baúl
/// de síntomas) became a second real host for the same pattern — filtering
/// is view-only, transient session state; callers are responsible for not
/// mutating the underlying data order.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color contrastColor;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.contrastColor,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cc.withValues(alpha: 0.15)),
    );
    return TextField(
      controller: controller,
      style: TextStyle(color: cc, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: cc.withValues(alpha: 0.4), fontSize: 13),
        prefixIcon: Icon(
          Icons.search,
          size: 18,
          color: cc.withValues(alpha: 0.5),
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: cc.withValues(alpha: 0.5),
                ),
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
              ),
        filled: true,
        fillColor: cc.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cc, width: 1.5),
        ),
      ),
    );
  }
}
