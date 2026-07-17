# Peso, estatura y composición corporal — decisión de diseño

**Sprint:** Sin asignar (mismo tratamiento que Multi-Observer Profiles y el Panel de Signos Vitales: diseñado, sin sprint formal asignado)
**Estado:** Implementado (2026-07-17) según el alcance de §3 — ver §7. Sin toolchain de Flutter local — revisado manualmente (balance de llaves/paréntesis por script, JSON de ARB validado con `python3 -c "import json"`), no compilado; pendiente `flutter analyze`/`flutter run -d chrome`.
**Última actualización:** 17-jul-2026

---

## 1. Origen de la conversación

Paulina preguntó si el Panel de Signos Vitales (`vital_signs_panel.md`) debería incluir peso, estatura, IMC y, opcionalmente, composición corporal — y si debería vivir en `movimiento_tab.dart` o en Perfil. Pidió investigación real antes de diseñar nada, dado que es un tema con más carga que el resto del panel (fiebre/HRV/PA/ortostatismo son mediciones que no cargan significado psicológico; peso sí).

Estado del código verificado antes de diseñar: **no existe ningún campo de peso, estatura, IMC o composición corporal en `lib/` ni en `assets/`** — es terreno completamente greenfield, a diferencia de fiebre/HRV donde ya había pipelines parciales que motivaron el Panel de Signos Vitales.

## 2. Grounding de investigación (verificado esta sesión, no de una sesión anterior)

- **Comorbilidad elevada de conducta alimentaria alterada en EDS, específicamente en el subtipo hipermóvil.** Estudio en *Eating and Weight Disorders* (mayo 2026, n=121 mujeres con EDS autoreportado) encontró alta frecuencia de conducta alimentaria alterada y preocupación por el IMC, secundaria a síntomas GI, alergias alimentarias, dolor oral y "comer con miedo/dolor" — restricción no motivada por apariencia sino por que comer literalmente dispara síntomas. DOI/link: [10.1007/s40519-026-01872-2](https://link.springer.com/article/10.1007/s40519-026-01872-2). Estudio relacionado, mismo grupo de síntomas: [10.1007/s40519-021-01146-z](https://link.springer.com/article/10.1007/s40519-021-01146-z).
- **El cambio de peso en EDS/MCAS es fisiológico, no conductual.** Disautonomía GI, malabsorción, reacciones alimentarias por MCAS, efectos de medicamentos, y reducción de actividad por inestabilidad articular mueven el peso en cualquier dirección sin relación con "esfuerzo" o adherencia — un número de peso sin contexto es engañoso por diseño, no solo sensible. Fuente: [The EDS Clinic — Can EDS Cause Weight Gain or Weight Loss?](https://www.eds.clinic/articles/eds-weight-gain-weight-loss).
- **Las apps de tracking de peso tienen evidencia directa de empeorar/gatillar conducta alimentaria alterada**, y el IMC específicamente es señalado como "modelo cuantitativo anticuado e innecesario". Logging diario + framing rojo/verde de "ganancias/pérdidas" genera ansiedad y culpa en usuarias vulnerables — el mismo patrón que la Disciplina de Color de este proyecto ya prohíbe para estados no-urgentes. Fuentes: [The Swaddle — Health Tracking Apps Provide a Worrying Pipeline to Eating Disorders](https://www.theswaddle.com/health-tracking-apps-provide-a-worrying-pipeline-to-eating-disorders-better-tech-design-can-fix-that), [BJPsych Open — Effects of diet and fitness apps on ED behaviours](https://pmc.ncbi.nlm.nih.gov/articles/PMC8485346/), [Mobile Food Tracking Apps: Do They Provoke Disordered Eating?](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11556259/).
- **La conexión POTS↔peso es más débil de lo asumido inicialmente.** Las guías de manejo de POTS se centran en sal (~10g/día) y fluidos (2-3L/día); la hipovolemia se mide por volumen plasmático, no por peso en balanza — el peso corporal no es parte del protocolo diagnóstico ni de manejo. Fuente: [PMC1501099 — The Postural Tachycardia Syndrome (POTS): Pathophysiology, Diagnosis & Management](https://pmc.ncbi.nlm.nih.gov/articles/PMC1501099/).
- **Sí existe un caso de uso clínico legítimo, pero acotado**: pérdida de peso no explicada (>5% en 6 meses) es una señal de alerta real que vale la pena documentar para un especialista — consistente con el fenotipo EDS-GI (Zeitoun 2013/Fikree 2014-2017/Nelson 2015, ya citados en CLAUDE.md para D.2). Es una necesidad de **documentación clínica puntual**, no de auto-monitoreo diario.

## 3. Decisión de alcance (confirmada con Paulina vía preguntas directas, 2026-07-17)

Dado el riesgo específico de esta población (no genérico) y que choca directamente con precedentes ya establecidos en este proyecto (BSS por foto excluido por estigmatizante, gamificación de movimiento excluida por contraproducente, disciplina de color que prohíbe rojo/verde para no-urgente), se descartó tratar peso/estatura/IMC como una entrada más del Panel de Signos Vitales.

**Alcance aprobado: registro clínico acotado, no auto-monitoreo.**

- Registro de peso opcional, off-by-default, **cada entrada requiere una razón clínica** (ej. brote GI, cambio de medicamento, edema/retención de líquido, apetito) — nunca un número suelto sin contexto.
- Sin gráficos, sin línea de tendencia, sin metas ni rangos objetivo.
- **IMC no se calcula ni se muestra en ningún punto de la UI.** Si en el futuro un especialista pide IMC en el reporte clínico, evaluar calcularlo únicamente para el PDF de exportación (Fase 4) — nunca como algo que la paciente ve en su uso diario. Esto queda abierto, no decidido (ver §5).
- Composición corporal (masa muscular, % grasa, etc.): **fuera de alcance**, sin revisar de nuevo salvo necesidad clínica concreta — no hay integración de wearables para esto hoy (`HrvReading.source` es el único precedente y sigue siendo manual/futuro), y el estándar de evidencia es aún menor que para peso.

**Ubicación: Perfil, no Panel de Signos Vitales, no `movimiento_tab.dart`.**

- Estatura: campo estático en `Profile`, mismo patrón que `dateOfBirth`/`allergies` (`lib/models/models.dart:1634-1646`) — aditivo, sin UI de edición hasta que se priorice, valor real de uso diferido (igual que `dateOfBirth` esperó hasta el Panel de Signos Vitales para tener un primer consumo clínico real).
- Peso: lista de entradas fechadas con razón, vive en `Profile` junto a `structuralZoneHistory`/`allergies`, no en el Panel de Signos Vitales — separarlo evita que se bundee bajo el mismo toggle/UI que fiebre/HRV/PA, que no cargan este riesgo y no deberían "prestarle" legitimidad de auto-monitoreo diario a algo que es documentación puntual.
- `movimiento_tab.dart` quedó descartado explícitamente: ese framing es exactamente el patrón "fitness app" que la literatura señala como gatillante, y temáticamente peso no es una métrica de movimiento.

## 4. Modelo propuesto (borrador, no cerrado — mismo estado que §5 de `vital_signs_panel.md`)

```
Profile.heightCm: double?          // estático, opcional, sin UI de edición todavía
Profile.weightEntries: List<WeightEntry>

WeightEntry:
  id, timestamp
  weightKg: double
  reason: WeightChangeReason        // enum: giFlare, medicationChange, fluidRetention,
                                     //       appetiteChange, other
  note: String?                     // texto libre opcional
```

Sin getters calculados de IMC en el modelo. Si se agrega en el futuro, vivir exclusivamente en el servicio de agregación del PDF (`pdf_report_aggregator.dart`), nunca en `WeightEntry`/`Profile` como propiedad de primera clase.

## 5. Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| ¿IMC en el PDF de exportación clínica? | No confirmado con Paulina todavía — depende de si algún especialista lo pide en la práctica. Si se agrega, copy debe evitar cualquier lenguaje de categorización ("bajo peso"/"sobrepeso") y limitarse al número crudo con la fórmula, dejando la interpretación al clínico. |
| Copy exacto de `WeightChangeReason` | Debe seguir las Reglas de Copy en Advisories/Red Flags ya codificadas (sin acrónimos, humildad epistémica) aunque esto no sea un red flag — mismo cuidado de lenguaje. |
| ¿Vale la pena un red flag de "pérdida de peso no explicada >5% en 6 meses"? | Grounding existe (§2), pero no discutido con Paulina todavía — evaluar junto con el resto de red flags de signos vitales, diferidos también en `vital_signs_panel.md` §8. |
| Campos exactos finales de `WeightEntry`/enum `WeightChangeReason` | Borrador de esta conversación, no verificado en una segunda revisión ni implementado. |
| Composición corporal | Fuera de alcance por ahora; revisar solo si surge una necesidad clínica concreta y verificar disponibilidad real de fuente de datos (no hay integración de wearables hoy). |

## 6. Fuera de alcance, explícitamente

- IMC visible en cualquier pantalla de uso diario.
- Gráficos o tendencias de peso.
- Metas, rangos objetivo, o cualquier framing de "progreso".
- Ubicación en `movimiento_tab.dart` o en el Panel de Signos Vitales.
- Composición corporal / % grasa / masa muscular (este pase).
- Integración con básculas inteligentes o wearables.

## 7. Implementación (2026-07-17)

Modelo exactamente como en §4, sin cambios: `WeightChangeReason` enum (5 valores: `giFlare`/`medicationChange`/`fluidRetention`/`appetiteChange`/`other`) + `WeightEntry` (`lib/models/models.dart`, junto a `StructuralZoneHistoryEntry`), y `Profile.weightEntries`/`Profile.heightCm` como campos aditivos (constructor/`toMap`/`fromMap`). Sin getter de IMC en ningún punto del modelo — confirmado, coincide con §3/§6.

UI: toggle `weight_tracking` (off-by-default) en `TrackingSettingsScreen`, mismo patrón `_toggle(...)` que sleep/hydration/hrv. `ProfileSettingsScreen` gana el campo de estatura (siempre visible, sin gating — mismo tratamiento que `dateOfBirth`, ver §3) y una sección "Registros de peso" (lista + agregar/editar/eliminar) que solo se renderiza si `profile.settings.optionalTrackers['weight_tracking'] == true` — la estatura es un dato demográfico estático de bajo riesgo, el log de peso es la parte con carga real y por eso queda detrás del toggle explícito, no agrupado bajo el mismo criterio. Sheet nuevo `lib/widgets/weight_entry_form_sheet.dart` (calcado de `structural_zone_history_form_sheet.dart`): peso + razón (dropdown obligatorio, sin opción de guardar sin razón) + nota opcional + fecha — sin campo de IMC, sin gráfico, sin comparación con entradas anteriores en la propia UI. Callbacks `onAddWeightEntry`/`onEditWeightEntry` inyectados desde `main_screen.dart`, mismo contrato que `onAddStructuralZoneHistory`/`onEditStructuralZoneHistory`.

19 claves ARB nuevas (`settingsModuleWeightTrackingLabel/Description`, `settingsHeightLabel/Hint`, `weightEntrySectionTitle`, `weightEntryEmptyState`, `weightEntryAddAction`, `weightEntryFormTitle/EditTitle`, `weightEntryWeightLabel`, `weightEntryReasonLabel` + 5 opciones de razón, `weightEntryNoteHint`, `weightEntryDateLabel`, `weightEntrySaveAction`) en `app_es.arb`/`app_en.arb`/`app_zh.arb` + getters a mano en `app_localizations.dart` + `_es`/`_en`; en `app_localizations_zh.dart` se agregaron una sola vez dentro de `AppLocalizationsZh` (no duplicadas en `AppLocalizationsZhTw`), mismo patrón confirmado correcto en la sesión de presíncope (ver CLAUDE.md).

Decisiones abiertas de §5 siguen abiertas — nada de eso se decidió ni se implementó en este pase (IMC en PDF, red flag de pérdida de peso no explicada, composición corporal).
