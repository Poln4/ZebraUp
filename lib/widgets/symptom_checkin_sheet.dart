// 2026-07-22 — same-day continuation check-in for regular vault symptoms
// (SymptomEvent). Mirrors the structural pain check-in pattern
// (structural_checkin_sheet.dart, 2026-07-18): tapping a symptom that was
// already logged TODAY opens this instead of a brand-new severity-menu
// flow, so a symptom that improves-but-doesn't-resolve doesn't produce a
// duplicate row for the same day. Deliberately diverges from the
// structural sheet's coarse same/better/worse/resolved labels: SymptomEvent
// always carries a real severity value (structural's is optional, only
// present on the quick-log path), so the check-in reuses the same
// SeverityDotPicker used to log in the first place — the severity
// trajectory itself expresses "better"/"worse"/"same".
//
// Scope is same-day only (see SymptomEvent.resolvedAt doc in models.dart)
// — there is no cross-day "ongoing since" carry-forward here.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import 'severity_picker.dart';

class SymptomCheckInResult {
  final SymptomSeverity? newSeverity;
  final bool resolved;

  const SymptomCheckInResult.severity(SymptomSeverity sev)
    : newSeverity = sev,
      resolved = false;

  const SymptomCheckInResult.resolved() : newSeverity = null, resolved = true;
}

Future<SymptomCheckInResult?> showSymptomCheckInSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required String symptomName,
  required SymptomSeverity currentSeverity,
  required DateTime loggedAt,
}) {
  final cc = contrastColor;
  final ic = inverseContrastColor;
  final l10n = context.l10n;
  final loggedAtLabel = DateFormat('HH:mm').format(loggedAt);

  return showModalBottomSheet<SymptomCheckInResult>(
    context: context,
    backgroundColor: ic,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                l10n.symptomCheckInTitle(symptomName),
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.symptomCheckInSubtitle(loggedAtLabel),
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SeverityDotPicker(
                anchor: currentSeverity,
                showLabels: true,
                showFunctionalAnchor: true,
                excludeNone: true,
                contrastColor: cc,
                onSelect: (sev) => Navigator.pop(
                  ctx,
                  SymptomCheckInResult.severity(sev),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () =>
                      Navigator.pop(ctx, const SymptomCheckInResult.resolved()),
                  child: Text(
                    l10n.symptomCheckInResolvedButton,
                    style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    l10n.symptomCheckInSkip,
                    style: TextStyle(color: cc.withValues(alpha: 0.6)),
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
