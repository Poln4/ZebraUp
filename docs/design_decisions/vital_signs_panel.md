# Panel de Signos Vitales — decisiones de diseño

**Sprint:** Sin asignar (diseño en curso, análogo a Multi-Observer Profiles: diseñado, aún no es sprint activo)
**Estado:** En discusión con la usuaria (2026-07-16). Sin implementar — este documento congela las decisiones tomadas hasta ahora en la conversación. Campos exactos de los modelos nuevos son borrador, no spec cerrada (ver §8).
**Última actualización:** 16-jul-2026

Este documento consolida la base y las decisiones de diseño para unificar el seguimiento de fiebre, HRV, presión arterial y respuesta ortostática. No es una capa de detalle por síntoma (ver `symptom_detail_laters.md` para ese patrón) — es un conjunto de modelos nuevos más una vista/servicio de agregación.

---

## 1. Motivación

Paulina (desarrolladora y paciente con clEDS + disautonomía) señaló que los pacientes con disautonomía no están siendo tomados en serio por el diseño actual de la app. La auditoría de código confirmó una asimetría real, no solo percibida:

- **Fiebre**: pipeline completo (valor cuantitativo, sitio, contexto de medicación, servicio de análisis de tendencia/episodios, chip de estado en Hoy).
- **HRV**: solo valor crudo (RMSSD) + contexto + fuente. Sin baseline personal, sin interpretación.
- **Presión arterial**: no existe en absoluto.
- **Respuesta ortostática** (la señal que de hecho diagnostica POTS): no existe en absoluto.

Lo notable: los umbrales clínicos ya están documentados por Paulina en `assets/condition_codes.json` (entradas POTS e Hipotensión Ortostática, ambas de las 12 entradas de alto riesgo con `content_source` verificado) — el conocimiento existe, simplemente no hay ningún widget que lo capture.

## 2. Estado del código verificado antes de diseñar

- `FeverReading` (`lib/models/models.dart:3086-3157`): `temperatureC`, `site` (`FeverSite` enum), `antipyreticTaken`, `antipyreticName`, `note`. Vinculado a `ActionTaken` vía `LinkedEventType.fever`. Servicio propio: `lib/services/fever_analysis.dart`.
- `HrvReading` (`lib/models/models.dart:2911-2967`): `rmssdMs`, `context` (`HrvContext` enum), `source` (default `'manual'`, campos ya preparados para `'oura'/'whoop'/'welltory'/'polar'/'healthkit'`), `note`. Sin campo de FC en reposo, sin baseline, sin simulador — confirma como cierta la incertidumbre que el propio CLAUDE.md marcaba sobre este punto.
- `services/correlation_engine.dart`: scaffold explícito, sin reglas concretas todavía (el archivo declara textualmente que las reglas llegan en iteraciones posteriores).
- Ningún hit para presión arterial/sistólica/diastólica en `lib/` ni `assets/` — confirmado greenfield.
- Ningún hit para ortostatismo/NASA lean test/tilt table/presíncope salvo dos enums descriptivos no relacionados con captura de datos (`FatigueType.orthostatic`, `HeadachePosturalPattern`). D.3 (Presíncope) confirmado como backlog vacío — sin modelo, sin widget, sin servicio.
- `MovementMetric`/`SleepEntry`/`HydrationEntry` no tienen campos de FC. `HydrationEntry` sí tiene `sodium: SodiumSource?`, relevante para manejo de POTS pero no es una lectura de signo vital en sí.

## 3. Colisión de nombres evitada

"Envelope"/"envelope band" ya es un concepto definido en el proyecto para ritmo/pacing de movimiento (`docs/PHASE_5_ROADMAP.md` ítems 6.5/6.8, y `docs/competitive_analysis-2.md`): banda de energía gateada a 14 días de datos, detección de boom-bust a ±1.5σ. Se descartó ese término para signos vitales para no sobrecargarlo con un segundo significado. Nombre elegido: **"Panel de Signos Vitales"** (prefijo en código: `VitalSign*`).

## 4. Decisión arquitectónica: modelos separados, unificación en capa de vista/servicio

Se descartó fusionar fiebre/HRV/PA/ortostatismo en un único modelo polimórfico nuevo. Razón: `FeverReading` y `HrvReading` ya tienen datos reales de beta testers, y la regla de retrocompatibilidad del proyecto es explícita — ningún campo se elimina o renombra sin migración Hive. Forzar un modelo unificado habría requerido migrar el schema de fiebre sin necesidad clínica real para hacerlo.

Arquitectura acordada:

- **Capa de datos**: `FeverReading` y `HrvReading` sin tocar. Dos modelos nuevos (§5), mismo patrón de archivo-por-feature que ya usa el proyecto.
- **Capa de unificación**: un enum `VitalSignKind` (fiebre/HRV/PA/ortostatismo) puramente de presentación — no reemplaza los modelos tipados, solo permite que el panel itere y agrupe. Un servicio nuevo de agregación (`vital_signs_service.dart`, o extensión del scaffold de `correlation_engine.dart`) que junta la última lectura de cada tipo para el dashboard, reusando el patrón de tendencia que ya tiene `fever_analysis.dart`.

## 5. Modelos nuevos (borrador, no cerrado)

### 5.1 `BloodPressureReading`

Lectura suelta, cotidiana (no asociada a una prueba ortostática):

```
systolic, diastolic, heartRate (opcional), position (sentada/acostada/de pie), timestamp, note
```

### 5.2 `OrthostaticTest`

Versión simplificada del NASA lean test — no la versión clínica completa de 7 tiempos. Decisión deliberada: exigir 7 mediciones a una paciente ya fatigada contradice el diseño trauma-informado documentado en el resto del proyecto. Se capturan 4 tiempos: línea base (reposo ≥5 min) + 1 min + 3 min + 10 min de pie (el "dentro de 10 min" del criterio POTS que ya está en `condition_codes.json` fija el límite superior).

```
id, timestamp
readings: [
  { phase: baseline,      heartRate, systolic?, diastolic?, symptoms: [] },
  { phase: standing1min,  heartRate, systolic?, diastolic?, symptoms: [] },
  { phase: standing3min,  heartRate, systolic?, diastolic?, symptoms: [] },
  { phase: standing10min, heartRate, systolic?, diastolic?, symptoms: [] },
]
note
```

Getters calculados:

- `heartRateDelta` — máxima FC de pie menos FC de línea base.
- `meetsPotsThreshold` — ≥30 lpm, o ≥40 lpm si `Profile.dateOfBirth` indica menor de 19 años (primer uso clínico real de ese campo, agregado en Phase4.A sin UI de consumo hasta ahora). También true si cualquier FC de pie supera 120 lpm absoluto.
- `meetsOrthostaticHypotensionThreshold` — caída de PA ≥20 mmHg sistólica o ≥10 mmHg diastólica.

Copy de cualquier resultado sigue la regla de humildad epistémica ya codificada en el proyecto: "esto puede sugerir un patrón compatible con POTS, considera mencionárselo a tu médico" — nunca "tienes POTS" ni "esto confirma".

## 6. Ubicación en navegación

Sección dentro del tab Síntomas, junto a las demás capas de detalle (cefalea, fatiga, abdomen, y la nueva de dolor estructural) — no como tab nuevo de primer nivel, ni como extensión de Hoy.

## 7. Consideración de seguridad — pendiente de confirmar con Paulina

La prueba ortostática de pie conlleva riesgo real de síncope en pacientes con POTS severo. Queda pendiente que Paulina confirme si el flujo debe incluir explícitamente una advertencia previa ("siéntate de inmediato si te sientes mal") y un botón de "detener prueba" visible en todo momento durante la prueba, o si esto se da por sentado como parte del diseño trauma-informado general y no necesita tratamiento especial en este documento.

## 8. Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| Confirmación del punto de seguridad (§7) | Pendiente respuesta directa de Paulina. |
| Cross-referencing entre los 4 tipos de vitals (ej. correlación fiebre+FC elevada) | Explícitamente fuera de esta ronda de diseño — el scaffold de `correlation_engine.dart` ya anticipa reglas concretas para una iteración posterior. |
| Red flags específicos de signos vitales | No discutidos todavía; evaluar necesidad en una ronda aparte, mismo criterio que se aplicó a la capa de dolor estructural (ver `symptom_detail_laters.md` §12.6). |
| Campos exactos finales de `BloodPressureReading`/`OrthostaticTest` | Borrador de esta conversación, no verificado contra una segunda revisión ni implementado. |
