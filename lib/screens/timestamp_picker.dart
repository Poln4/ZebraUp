import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows a date + time picker bottom sheet, returning the chosen DateTime
/// or null if cancelled.
///
/// Defaults [initial] to now. Constrains to not be in the future.
Future<DateTime?> pickTimestamp({
  required BuildContext context,
  required DateTime initial,
  required Color contrastColor,
  required Color inverseContrastColor,
}) async {
  DateTime working = initial;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CUÁNDO OCURRIÓ",
                      style: TextStyle(
                          color: contrastColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: contrastColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(Icons.calendar_today, color: contrastColor),
                          label: Text(
                            DateFormat('EEE, d MMM y').format(working),
                            style: TextStyle(color: contrastColor),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: working,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                working = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  working.hour,
                                  working.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: contrastColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(Icons.access_time, color: contrastColor),
                          label: Text(
                            DateFormat('HH:mm').format(working),
                            style: TextStyle(color: contrastColor),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.fromDateTime(working),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                working = DateTime(
                                  working.year,
                                  working.month,
                                  working.day,
                                  picked.hour,
                                  picked.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickPresetChip(
                        label: 'Ahora',
                        contrastColor: contrastColor,
                        onTap: () =>
                            setSheetState(() => working = DateTime.now()),
                      ),
                      _QuickPresetChip(
                        label: 'Hace 1h',
                        contrastColor: contrastColor,
                        onTap: () => setSheetState(() => working =
                            DateTime.now().subtract(const Duration(hours: 1))),
                      ),
                      _QuickPresetChip(
                        label: 'Hace 3h',
                        contrastColor: contrastColor,
                        onTap: () => setSheetState(() => working =
                            DateTime.now().subtract(const Duration(hours: 3))),
                      ),
                      _QuickPresetChip(
                        label: 'Anoche (10pm)',
                        contrastColor: contrastColor,
                        onTap: () {
                          final n = DateTime.now();
                          setSheetState(() => working = DateTime(
                              n.year, n.month, n.day - 1, 22, 0));
                        },
                      ),
                      _QuickPresetChip(
                        label: 'Ayer',
                        contrastColor: contrastColor,
                        onTap: () {
                          final n = DateTime.now();
                          setSheetState(() => working = DateTime(
                              n.year, n.month, n.day - 1, n.hour, n.minute));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: contrastColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('CANCELAR',
                              style: TextStyle(color: contrastColor)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: contrastColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // Guard against future timestamps
                            final final_ = working.isAfter(DateTime.now())
                                ? DateTime.now()
                                : working;
                            Navigator.pop(ctx, final_);
                          },
                          child: Text('GUARDAR',
                              style: TextStyle(
                                  color: inverseContrastColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _QuickPresetChip extends StatelessWidget {
  final String label;
  final Color contrastColor;
  final VoidCallback onTap;
  const _QuickPresetChip({
    required this.label,
    required this.contrastColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: Colors.transparent,
      side: BorderSide(color: contrastColor.withValues(alpha: 0.5)),
      label: Text(label, style: TextStyle(color: contrastColor, fontSize: 12)),
      onPressed: onTap,
    );
  }
}