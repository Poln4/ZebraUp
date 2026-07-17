// 2026-07-18 — lightweight status check-in for persistent structural
// pain (see Profile.getStructuralActiveForDay in models.dart).
//
// Tapping a zone chip that already has an unresolved StructuralEvent
// opens this instead of a brand-new zone+kind+groups flow — the whole
// point of "persistent" pain is that the patient shouldn't have to
// re-describe it every day just to keep it visible. This sheet updates
// the EXISTING event in place (comparedToUsual, or resolvedAt) rather
// than creating a new StructuralEvent.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/context_ext.dart';

enum StructuralCheckInOutcome { same, better, worse, resolved }

Future<StructuralCheckInOutcome?> showStructuralCheckInSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required String zoneLabel,
  required DateTime since,
}) {
  final cc = contrastColor;
  final ic = inverseContrastColor;
  final l10n = context.l10n;
  final sinceLabel = DateFormat('d MMM').format(since);

  return showModalBottomSheet<StructuralCheckInOutcome>(
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
                l10n.structuralCheckInTitle(zoneLabel),
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.structuralCheckInSubtitle(sinceLabel),
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _CheckInOption(
                label: l10n.structuralCheckInSame,
                cc: cc,
                ic: ic,
                onTap: () =>
                    Navigator.pop(ctx, StructuralCheckInOutcome.same),
              ),
              const SizedBox(height: 8),
              _CheckInOption(
                label: l10n.structuralCheckInBetter,
                cc: cc,
                ic: ic,
                onTap: () =>
                    Navigator.pop(ctx, StructuralCheckInOutcome.better),
              ),
              const SizedBox(height: 8),
              _CheckInOption(
                label: l10n.structuralCheckInWorse,
                cc: cc,
                ic: ic,
                onTap: () =>
                    Navigator.pop(ctx, StructuralCheckInOutcome.worse),
              ),
              const SizedBox(height: 8),
              _CheckInOption(
                label: l10n.structuralCheckInResolved,
                cc: cc,
                ic: ic,
                emphasized: true,
                onTap: () =>
                    Navigator.pop(ctx, StructuralCheckInOutcome.resolved),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
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
    ),
  );
}

class _CheckInOption extends StatelessWidget {
  final String label;
  final Color cc;
  final Color ic;
  final bool emphasized;
  final VoidCallback onTap;

  const _CheckInOption({
    required this.label,
    required this.cc,
    required this.ic,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: emphasized
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cc,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onTap,
              child: Text(
                label,
                style: TextStyle(color: ic, fontWeight: FontWeight.bold),
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cc.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onTap,
              child: Text(label, style: TextStyle(color: cc)),
            ),
    );
  }
}
