// Sprint G.B.2 — Flare mode chip + banner.
//
// Two public widgets replacing the G.B FlareControl (which combined
// both roles in a single widget rendered top-right of Hoy).
//
//   • FlareChip — inline chip for the _HoyHeader Wrap, next to the
//     potato day pacing chip. Only visible when profile.state.flare
//     == null. Semantic grouping: both chips are "day state"
//     toggles that affect banner visibility downstream.
//
//   • FlareBanner — full-width banner above the Header. Only visible
//     when profile.state.flare != null. Preserves prominence during
//     crisis (where visibility matters most).
//
// Icon distinction to avoid collision with potato day's
// Icons.shield family:
//   • FlareChip: Icons.pause_circle_outline (inactive UI, subtle)
//   • FlareBanner: Icons.pause_circle (active UI, filled)
// Semantics: pause metaphor = "I'm pausing everything optional".
//
// Both widgets guard their state change with confirmation dialogs.
// Contrast-only palette (F.E2 constraint). No red — flare mode is
// user choice, not medical emergency.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/profile_state.dart';

// ============================================================
// FlareChip — inline in _HoyHeader Wrap
// ============================================================

class FlareChip extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onActivate;

  const FlareChip({
    super.key,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    // Chip hides when flare mode is active; banner takes over.
    if (profile.state.flare != null) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () => _confirmActivate(context),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: contrastColor.withValues(alpha: 0.06),
          border: Border.all(
            color: contrastColor.withValues(alpha: 0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline, size: 16, color: contrastColor),
            const SizedBox(width: 6),
            Text(
              'Modo crisis',
              style: TextStyle(
                fontSize: 12,
                color: contrastColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmActivate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: inverseContrastColor,
        title: Text(
          '¿Activar modo crisis?',
          style: TextStyle(
            color: contrastColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Marcaremos el día como descanso y ocultaremos los banners '
          'y sugerencias opcionales. Las alertas urgentes (anafilaxia, '
          'thunderclap y otras) siguen apareciendo.',
          style: TextStyle(color: contrastColor, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: contrastColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onActivate();
            },
            child: Text(
              'Activar',
              style: TextStyle(
                color: contrastColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FlareBanner — full-width above Header
// ============================================================

class FlareBanner extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onDeactivate;

  const FlareBanner({
    super.key,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final flare = profile.state.flare;
    if (flare == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: contrastColor.withValues(alpha: 0.08),
          border: Border.all(color: contrastColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.pause_circle, color: contrastColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo crisis activo',
                    style: TextStyle(
                      color: contrastColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Desde hace ${_formatDuration(flare.duration)}',
                    style: TextStyle(
                      color: contrastColor.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _confirmDeactivate(context),
              style: TextButton.styleFrom(
                backgroundColor: contrastColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
              ),
              child: Text(
                'Salir',
                style: TextStyle(
                  color: inverseContrastColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: inverseContrastColor,
        title: Text(
          '¿Salir de modo crisis?',
          style: TextStyle(
            color: contrastColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Los banners y sugerencias opcionales van a volver a '
          'aparecer en Hoy. El día seguirá marcado como descanso '
          '(la historia se mantiene honesta).',
          style: TextStyle(color: contrastColor, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: contrastColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDeactivate();
            },
            child: Text(
              'Salir',
              style: TextStyle(
                color: contrastColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Duration formatter — LatAm tuteo neutro
// ============================================================

String _formatDuration(Duration d) {
  if (d.inMinutes < 60) {
    final m = d.inMinutes < 1 ? 1 : d.inMinutes;
    return '$m ${m == 1 ? "minuto" : "minutos"}';
  }
  if (d.inHours < 24) {
    final h = d.inHours;
    return '$h ${h == 1 ? "hora" : "horas"}';
  }
  final days = d.inDays;
  final remainingHours = d.inHours - days * 24;
  if (remainingHours == 0) {
    return '$days ${days == 1 ? "día" : "días"}';
  }
  return '$days ${days == 1 ? "día" : "días"} '
      '$remainingHours ${remainingHours == 1 ? "hora" : "horas"}';
}
