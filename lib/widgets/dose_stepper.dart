// =============================================================================
// DoseQuantityStepper — − [n] + with 0.5 increments.
//
// Used wherever the user picks "how many of this form": dose logging,
// MedicationGroup entries (phase 2C), titration sheets.
//
// Pure visual widget — no model imports. Caller passes value + onChanged.
// Pluralization is best-effort Spanish: "1 pastilla" / "2 pastillas".
// =============================================================================

import 'package:flutter/material.dart';

class DoseQuantityStepper extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  /// Singular form label, e.g. 'pastilla', 'cápsula', 'gota', 'parche'.
  /// The widget pluralizes by appending 's' for values != 1.
  final String formLabel;
  final Color contrastColor;
  final double min;
  final double max;
  final double step;

  const DoseQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.formLabel,
    required this.contrastColor,
    this.min = 0.5,
    this.max = 20,
    this.step = 0.5,
  });

  String get _displayValue {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String get _displayForm {
    if (formLabel.isEmpty) return '';
    if (value == 1.0) return formLabel;
    // Spanish: most forms pluralize with 's'. 'spray' stays 'sprays' which is fine.
    return '${formLabel}s';
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min;
    final canIncrement = value < max;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: contrastColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            enabled: canDecrement,
            contrastColor: contrastColor,
            onTap: () => onChanged((value - step).clamp(min, max)),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayValue,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
                if (_displayForm.isNotEmpty)
                  Text(
                    _displayForm,
                    style: TextStyle(
                      fontSize: 10,
                      color: contrastColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          _StepperButton(
            icon: Icons.add,
            enabled: canIncrement,
            contrastColor: contrastColor,
            onTap: () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color contrastColor;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.contrastColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? contrastColor.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: contrastColor.withValues(alpha: enabled ? 1.0 : 0.25),
          ),
        ),
      ),
    );
  }
}
