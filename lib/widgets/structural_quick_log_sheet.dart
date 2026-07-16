// §12.6 — Zone-history quick-log sheet.
//
// Shown instead of the 4-group funnel when the zone being logged
// already has a saved StructuralZoneHistoryEntry — the whole point of
// saving a known antecedent is to skip re-describing it every time.
// Captures severity (0-4, reusing SymptomSeverity/SeverityDotPicker) plus
// an optional "¿distinto a lo usual?" comparison. Also offers an escape
// hatch — "¿es un problema nuevo o distinto?" — for when the current
// episode isn't the known antecedent at all (e.g. a new knee issue after
// a prior knee surgery); that returns isNewIssue instead of a severity,
// so the caller can route to the full funnel rather than bucketing it
// under the saved history's kind.

import 'package:flutter/material.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../models/structural_detail.dart';
import 'severity_picker.dart';

typedef StructuralQuickLogResult = ({
  SymptomSeverity? severity,
  StructuralComparisonToUsual? comparedToUsual,
  bool isNewIssue,
});

Future<StructuralQuickLogResult?> showStructuralQuickLogSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
}) {
  return showModalBottomSheet<StructuralQuickLogResult>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _StructuralQuickLogBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class _StructuralQuickLogBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;

  const _StructuralQuickLogBody({
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_StructuralQuickLogBody> createState() =>
      _StructuralQuickLogBodyState();
}

class _StructuralQuickLogBodyState extends State<_StructuralQuickLogBody> {
  SymptomSeverity? _severity;
  StructuralComparisonToUsual? _comparedToUsual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.structuralQuickLogTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.structuralQuickLogSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => Navigator.pop(context, (
                  severity: null,
                  comparedToUsual: null,
                  isNewIssue: true,
                )),
                child: Text(
                  l10n.structuralQuickLogNewIssueLink,
                  style: TextStyle(
                    color: cc,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SeverityDotPicker(
                  selected: _severity,
                  excludeNone: true,
                  showLabels: true,
                  contrastColor: cc,
                  onSelect: (v) => setState(() => _severity = v),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StructuralComparisonToUsual.values.map((c) {
                  final label = switch (c) {
                    StructuralComparisonToUsual.worse =>
                      l10n.structuralComparedToUsualWorse,
                    StructuralComparisonToUsual.normal =>
                      l10n.structuralComparedToUsualNormal,
                    StructuralComparisonToUsual.better =>
                      l10n.structuralComparedToUsualBetter,
                  };
                  final selected = _comparedToUsual == c;
                  return InkWell(
                    onTap: () => setState(
                      () => _comparedToUsual = selected ? null : c,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? cc : Colors.transparent,
                        border: Border.all(color: cc),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? ic : cc,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _severity == null
                    ? null
                    : () => Navigator.pop(context, (
                        severity: _severity!,
                        comparedToUsual: _comparedToUsual,
                        isNewIssue: false,
                      )),
                child: Text(
                  l10n.actionSave,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.actionSkip,
                    style: TextStyle(color: cc.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
