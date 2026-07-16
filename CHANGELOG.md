# Changelog — ZebraUp

Historial de desarrollo reconciliado a partir de lo ya documentado en `CLAUDE.md`, `beta_website/web/blog.html`, comentarios de código, `docs/`, el historial de conversaciones de este proyecto en Claude, y — para el origen del proyecto (abril–mayo 2026) — PDFs exportados de conversaciones reales con Gemini y con Claude. La mayoría de las entradas de abril y mayo de 2026 ahora vienen de transcript literal verificado; dos entradas (29 y 31 de mayo) siguen dependiendo únicamente de un resumen que Paulina pidió a Gemini de conversaciones antiguas, sin transcript propio — ver la nota de fuente y confianza en esa sección antes de citar cualquier entrada de mayo externamente. No hay repositorio git en este entorno de trabajo, así que este archivo **no es un log de commits** — es una reconstrucción manual. Donde solo se conoce el mes o un rango (no el día exacto), se marca explícitamente en vez de inventar una fecha. Si aparece nueva información que contradiga una entrada de aquí, esta es la que se corrige — no al revés.

Nota de cobertura del historial de conversaciones: hay sesiones registradas en este proyecto del 2026-06-04/05 al 2026-06-12 y del 2026-07-02 en adelante. **No hay sesiones registradas entre el 2026-06-13 y el 2026-07-01** — el trabajo de ese período probablemente ocurrió en Claude Code u otro entorno, y por eso queda sin fecha por día. El resumen de Gemini aporta dos fechas puntuales dentro de esa ventana (06-15 y 06-17), marcadas como "sin verificar contra código" en sus entradas.

Convención: más reciente primero. La mayoría de las sesiones desde el 2026-07-13 se hicieron sin toolchain de Flutter local (revisión manual de campos/llaves/paréntesis, no compilado) — ver `CLAUDE.md` si una entrada puntual necesita ese detalle.

---

## Estado de Deploy (zebraup.netlify.app)

Log separado del trabajo de código de abajo — "trabajar en X" y "subir X en línea" son eventos distintos, y este proyecto no tiene git ni acceso a Netlify desde este entorno, así que este log **no se puede inferir automáticamente**: depende de que Paulina reporte cada deploy real para que quede registrado aquí. Sin entrada nueva, asumir que el código en este directorio va por delante de lo que está en línea.

**Numeración de versión (iniciada 2026-07-16)**: Paulina fijó **2.3.3** como número base para el último deploy real (~2026-07-15) y **2.3.4** para el deploy de hoy — es un punto de partida elegido por ella, no una continuación orgánica de semver (`pubspec.yaml` decía `1.0.0+1`, sin historial de bumps, hasta este momento). `pubspec.yaml` ya quedó en `2.3.4+1` en este directorio, listo para el deploy de hoy — pendiente de que Paulina lo confirme.

- **v2.3.4 — pendiente de deploy (código listo, `pubspec.yaml` ya en `2.3.4+1`)**: todo lo fechado `2026-07-16` en el log de abajo, más el trabajo de esta sesión que no toca código. Incluye: el rework de zona+tipo combinado del dolor estructural, consolidación de `RedFlagSeverity`, exclusión de medicamentos `basalScheduled` en el selector post-síntoma, persistencia del toggle de orden A-Z del Botiquín, tejido blando (hematomas/sangrado — `StructuralBleedingDetail`), la reconciliación de historial del proyecto (mayo 2026, `CLAUDE.md`/`CHANGELOG.md`/`beta_website/web/blog.html` + `en/blog.html`), y la nueva entrada de blog sobre tejido blando (ver más abajo en esta sesión).
- **v2.3.3 — último deploy confirmado, ~2026-07-15** (aprox. 18h antes de que Paulina lo reportara, hora exacta no registrada) — incluye hasta la primera versión del rediseño de dolor estructural (embudo de 4 grupos, `StructuralDetail`/`structural_detail_sheet.dart`), es decir, la versión que Paulina rechazó al día siguiente (ver entrada `2026-07-16` abajo, "Rework del rediseño... del día anterior").

**Convención para entradas futuras**: cuando Paulina confirme un deploy real, agregar una línea `- **vX.Y.Z — Deploy YYYY-MM-DD**: incluye hasta la entrada [fecha] del log de abajo.` arriba de la más reciente (más reciente primero, igual que el resto de este archivo), y bumpear `pubspec.yaml` en consecuencia para el siguiente ciclo de trabajo.

---

## 2026-07-16

- **Tejido blando (hematomas/sangrado) implementado** — cierra el hilo diferido en §12.6b de `docs/design_decisions/symptom_detail_layers.md`: severidad adaptada del ISTH-BAT por evento (no escala periódica), sin mención de anemia/RDW-CV% en el copy (el hallazgo medible real es disfunción plaquetaria, Artoni 2018). `StructuralBleedingDetail` nuevo (`lib/models/structural_detail.dart`: `BleedingOnset` espontáneo/trauma + `BleedingSeverity` 5 niveles), campo aditivo `bleedingDetail` en `StructuralEvent`, dos grupos nuevos (`bleeding_onset`/`bleeding_severity`) en `assets/symptom_definitions.json`. El embudo zona+tipo bifurca por `kind` (Origen+Gravedad para tejido blando en vez de los 4 grupos de dolor, que no describen bien un hematoma).
- Bug real cerrado de paso: el picker clásico ("Ya sé qué es") nunca pedía severidad para hematoma/contusión/cortes — guardaba directo. Ahora abre `lib/widgets/structural_bleeding_sheet.dart` (nuevo) antes de guardar, para todo tipo de tejido blando salvo quemadura (`burn`, no es sangrado).
- Refactor de reuso: el chip con ícono ⓘ (`_StructuralChip`, antes privado a `structural_detail_sheet.dart`) se extrajo a `lib/widgets/structural_chip.dart` (`StructuralChip` público) para que el sheet nuevo lo comparta en vez de duplicar una variante con long-press.
- Red flags de tejido blando (incluye el tier de riesgo vEDS por ruptura arterial) y el advisory de "tendencia de hematomas" siguen explícitamente diferidos — esta sesión solo cierra la capa de captura.

- **Rework del rediseño de dolor estructural del día anterior**: Paulina rechazó el embudo de 4 grupos (forzaba silenciosamente `kind=painWithoutClearCause`, sin preguntar nunca el tipo real). Reemplazado por un flujo combinado zona+tipo que se puede iniciar por cualquiera de los dos extremos: tocar un chip de zona ahora también pregunta el tipo; escribir texto libre en el baúl ("dolor muscular", "dolor pierna") detecta cuál de las dos piezas ya viene dada y pregunta solo la que falta. "Ya sé qué es" (picker clínico específico) y el quick-log de zonas conocidas quedaron intactos.
- Nuevo `lib/services/structural_text_detector.dart` (detector de zona/tipo por palabras clave sobre texto libre) y `lib/widgets/body_zone_picker_grid.dart` (grilla de zonas extraída para reusarse en el sheet nuevo). `structural_detail_sheet.dart` reescrito como máquina de 3 pasos (zona → tipo → los 4 grupos existentes). 5 tipos placeholder genéricos nuevos en `kStructuralTaxonomy` (uno por kind, mismo patrón que `joint_pain`) + `kGenericStructuralTypeForKind`. 9 claves ARB nuevas en es/en/zh.
- Bug propio encontrado y corregido en la misma sesión: "pierna"/"espalda" sueltas no resolvían ninguna zona específica (ambiguas) ni ningún tipo, así que "dolor pierna" caía al menú genérico en vez de abrir el sheet — contradecía el propio ejemplo de Paulina. Corregido con un flag de señal ambigua que abre el sheet igual, empezando por el paso de zona.
- Se usó plan mode explícitamente (research + diseño + aprobación antes de tocar código) por tratarse de un rework de una feature shippeada el día anterior.

- **Deuda técnica resuelta**: `HeadacheRedFlagSeverity`, `FatigueRedFlagSeverity` y `AbdominalRedFlagSeverity` (triplicados) consolidados en un único `RedFlagSeverity` (`lib/models/red_flag_severity.dart`), reusado por los tres servicios de red flags. Rename `_showAdvisoryFlags` → `_showHeadacheAdvisoryFlags` por simetría.
- **Selector de medicamento post-síntoma** (`action_taken_sheet.dart`, Sprint F.B+C) ahora excluye medicamentos `basalScheduled` — solo muestra `prnRescue | both | undefined`.
- **Botiquín**: el toggle de orden A-Z dejó de resetearse al cambiar de pestaña; ahora persiste en `profile.settings.optionalTrackers['botiquin_sort_alpha']` (sobrevive también a reinicios de la app).
- **Rediseño de dolor estructural implementado** (diseñado el mismo día, ver más abajo): `StructuralDetail` nuevo (`lib/models/structural_detail.dart`), embudo de 4 grupos/18 chips (`structural_detail_sheet.dart`), 7º `StructuralEventKind.painWithoutClearCause`, historial de zona (`StructuralZoneHistoryEntry`, `structural_zone_history_form_sheet.dart`, gestión en `ProfileSettingsScreen`), quick-log para zonas conocidas (`structural_quick_log_sheet.dart`). Ícono del timeline "Registros de hoy" corregido para usar `_iconForKind` en vez de un ⚠️ uniforme. ~24 claves ARB nuevas en es/en/zh/zh_TW.
- **Diseño (sin código)**: cierre del rediseño de dolor estructural en `docs/design_decisions/symptom_detail_layers.md` §12 (tejido blando y red flags estructurales quedan diferidos como hilo propio; el nombre del archivo se escribió mal como "laters" en varias entradas anteriores de este changelog y de CLAUDE.md — el archivo real es `symptom_detail_layers.md`). Diseño del Panel de Signos Vitales (`docs/design_decisions/vital_signs_panel.md`) — unifica fiebre/HRV/presión arterial/respuesta ortostática; la prueba ortostática queda pausada a pedido explícito de Paulina por el punto de seguridad de riesgo de síncope.
- Verificación de citas: De Paepe & Malfait 2004 y Kumskova et al. 2023 (full paper) confirmadas como literatura primaria real para la conexión hematomas/sangrado en EDS; la conexión específica a anemia/RDW-CV% sigue sin cita EDS-directa.

## 2026-07-15

- Bug real corregido en `report_view.dart`: una variable booleana intermedia (`hasTrends`) no permitía que Dart promoviera `trends` a non-null; corregido usando el chequeo directo `if (trends != null && ...)`.
- `_pdfSafe()` extendido de dos símbolos estáticos (⚠/≥) a *todo* el texto dinámico del PDF (nombres de medicamentos, notas de usuaria pueden traer caracteres fuera de WinAnsi, ej. emojis).
- Gráficos reales agregados al reporte in-app: severidad de síntomas en el tiempo, frecuencia de síntomas, ánimo en el tiempo (`lib/services/report_time_series.dart`, `lib/widgets/report_charts.dart`, paquete `fl_chart`). Diferenciación por patrón de guiones + alpha, no color nuevo.
- Segunda pasada tras `flutter analyze` real (primera vez esta sesión verificando contra un compilador real, no solo revisión manual): se sacó `const` de varios constructores de `fl_chart` no const-construibles en la versión resuelta (0.69.2); un error de `MoodQuadrant.valenceSign` "no definido" resultó ser caché de build incremental, no bug real.
- Rediseño de reporte por rango: rangos ≤7 días ahora muestran un registro día-por-día (`_PeriodLog`) en vez de gráficos casi vacíos; rangos más largos mantienen resumen + gráficos. Efectividad de medicamentos ahora se muestra en ambos modos.

## 2026-07-14

- **Botiquín**: filtro de búsqueda + toggle de orden A-Z en la lista de medicamentos; unidad de dosis personalizable (incl. preset "billones" para probióticos); componentes opcionales multi-ingrediente (`MedicationComponent` en `models.dart`).
- **Fase 3a (vademecum), lado de condiciones completado**: `condition_codes.json` v4 con `summary_es`/`notes_es` local-first para 56 condiciones (reemplaza a MedlinePlus como fuente default); `VademecumService.getConditionContent()` con cascada local→MedlinePlus; `condition_info_sheet.dart` reescrito. Todo el contenido nuevo flagueado `content_verify:true`; 12 entradas de alto riesgo tienen además `content_source`/`content_source_note` citando fuentes reales (Orphanet vía mirror, PMC, NIH GARD, Wikipedia).
- **Sprint F.F**: `MedicationDef.medicationType` (`models.dart`) + picker en `MedFormSheet` (`med_form.dart`) — programado/de rescate/ambos.
- **Reporte**: datos de ánimo (`MoodQuadrant`) ahora se agregan en rangos multi-día (antes se descartaban); `symptom_pattern_detector.dart` nuevo (detección de patrones cruzados entre síntomas, compartido entre PDF y reporte in-app).
- Bug corregido en `pdf_report_renderer.dart`: ⚠ y ≥ fuera del rango WinAnsi soportado por la fuente base14 Helvetica, se veían como bloque roto — reemplazados por "(!)" y texto (fix parcial; causa raíz completa se corrigió recién el 2026-07-16).
- Rediseño completo del tab Reporte in-app (`lib/widgets/report_view.dart`, nuevo) — discutido con Paulina antes de codear. `CollapsibleSection` por dominio, listas largas truncadas a 8 con "ver más".
- Marcador de referencia: comentarios de código (`vademecum_service.dart`, `medline_plus_service.dart`, `drug_info_sheet.dart`) sitúan el rename/refactor de `MedlinePlusService` → `VademecumService` como "Phase 3a (June 2026)" — es decir, el lado de *medicamentos* del vademecum ya estaba hecho antes de este día; lo que se completó el 07-14 fue el lado de *condiciones*.

## 2026-07-13

- **Fase 4 (PDF Clinical Export)** shipeado end-to-end: Phase4.A (modelos + `pdf_report_aggregator.dart`), Phase4.B (`pdf_report_renderer.dart`, paquete `pdf: ^3.11.1`), Phase4.C (`pdf_export_sheet.dart`, wireado en tab Reporte), Phase4.D (tarjeta de emergencia compacta). Confirmado que compila (`flutter run -d chrome` verificado por Paulina).
- Campos aditivos nuevos en `Profile`: `allergies`, `emergencyContacts`, `dateOfBirth`.
- Dos bugs de schema no verificado encontrados y corregidos: `profile_settings.dart` tenía contenido duplicado de `pdf_export_config.dart` (rompía la compilación y borraba la clase real `ProfileSettings`); `pdf_report_aggregator.dart` había sido escrito especulando ~20 nombres de campo que no existían en el código real.
- **Sprint P.C**: Drawer de ajustes monolítico (~824 líneas) reemplazado por 5 subpantallas dedicadas en `lib/screens/settings/` (Perfil, Idioma, Tracking, Datos de cuenta, Acerca de). UI de edición nueva para fecha de nacimiento y alergias.
- Auditoría directa de `lib/` confirma que Fase 6 (BowelEvent/HemorrhoidalEvent/SleepEntry/HrvReading/HydrationEntry/MovementMetric) y T0.3 (dashboard de frecuencia) ya estaban implementados en código pese a que los docs de planning decían lo contrario — se adopta la regla "el código manda sobre los docs de planning".
- Beta website: landing en inglés agregada (`beta_website/web/en/`), landing en español actualizada con secciones "Qué hay de nuevo" / "Qué no hace y por qué", voseo corregido.
- `docs/eds_research_notes.md` ampliado con 6 hallazgos nuevos; `docs/business_strategy_notes.md` nuevo (racional de mercado/monetización, con advertencia de señales de "report mill" en la fuente).
- Roadmap: pt-BR agregado a Post-Fase 6; ítem "Reportes médicos" (adjuntos tipo labs/MRI/X-Ray) agregado y pospuesto explícitamente.

## 2026-07-06 → 2026-07-12 (fechas exactas no registradas por sesión)

**Corrección de datación**: los Sprints F (completo), E y G estaban antes listados en este changelog como trabajo de junio, apoyándose en la narrativa del blog. El historial de conversaciones lo contradice: el reordenamiento del roadmap a F → E → G → Fase 4 y la entrega de Sprint F.A ocurrieron en la sesión del 2026-07-02→05 (ver abajo), después de cerrar D.1/D.2. Por lo tanto F.B en adelante, E y G corresponden a esta ventana, sin registro del día exacto (probablemente sesiones en Claude Code):

- **Sprint F (Acciones Transversales)** F.B–F.E3: patrón "¿qué hiciste?" → "¿funcionó?"; pivote de hook proactivo a patrón retro (`RetroSymptomBanner`/`RetroSymptomDialog`); ventana de timing ajustada 30min→90min tras feedback de beta (F.E2). (F.A — modelos base — se entregó el 2026-07-05, ver abajo.)
- **Sprint E (MCAS / Alergias)** E.A–E.E: `MCASDetail`, `mcas_detail_sheet.dart`, `mcas_red_flag_service.dart`, toggle de settings default-off.
- **Sprint G (Flare Mode)** G.A/G.B/G.B.2/G.C/G.E: `FlareState`, `flare_detection_service.dart` (3 reglas heurísticas), supresión de widgets opcionales sin suprimir nunca alertas urgentes, cooldown de 24h, ciclo de check-in de 48h.

## 2026-07-05 → 2026-07-06

- **Análisis competitivo estructural** de 12 apps en dos tandas (Bearable, Visible, Guava, Cara Care, apps MCAS, Flo, Folia Health, Chronic Insights, Wave; luego Clarity DTX, MedM Health Diary, Welltory), sobre 4 dimensiones: modelo de eventos, acción post-evento, fluctuación basal vs. evento agudo, modelo de negocio. Hallazgo central: ninguna implementa nativamente el prompt post-síntoma → acción → efectividad con timing. Welltory "Experiments" y el modelo "what works" de Folia identificados como los contraejemplos más cercanos; el borrado de historial a usuarios free de Welltory identificado como el anti-patrón más dañino para población crónica (posiciona el local-first de ZebraUp como diferenciador de confianza).

## 2026-07-02 → 2026-07-05 (sesión extendida)

- **Symptom Detail Layers D.1 (Fatiga)** completado: 4 grupos, 20 chips, 0 red flags URGENT (solo ADVISORY). Incluyó hotfix estructural D.1.A.fix (mismatch de schema JSON en aliases anidados que rompía `matchesSymptomKey`).
- **Symptom Detail Layers D.2 (Dolor Abdominal)** completado: 5 grupos, 22 chips, 3 red flags (1 diálogo de emergencia in-sheet + 2 post-save). Integración bidireccional con `BowelEvent` (forward tras `_openBowelForm`; reverse vía `_maybeLinkToBowelEvent`, ventana ±1h). Se estableció aquí la lección de naming: `_openBowelForm` (no `_openBowelSheet`), y `accompaniedByPain` no existe en `BowelEvent`.
- `detectAliasVariant` agregado a `SymptomDefinitionsService` (progressive disclosure semántico).
- **Reordenamiento de roadmap** motivado por el análisis competitivo: Sprint F (ActionTaken transversal) → Sprint E (MCAS) → Sprint G (Flare Mode) → Fase 4 (PDF export) → reevaluación de D.3/D.4/D.5.
- **Sprint F.A** entregado: `lib/models/action_taken.dart` con `ActionTaken`/`ActionKind` (12 tipos en F.A; 13 finales)/`EffectivenessRating`/`LinkedEventType` — dos archivos nuevos, cero patches a código existente.

## 2026-06-28

- `assets/symptom_definitions.json` — último `last_updated` registrado en el propio archivo antes de la extensión de contenido estructural del 07-16.

## 2026-06-17 (narrativa de Gemini, sin verificar contra código)

- "Finalización de refactor": transición completa a una base de datos event-based timeseries y arquitectura de tabs ya bloqueada, según el resumen de Gemini. Se superpone temáticamente con Fase 1/2A/2B/2C (2026-06-07) y el batch multi-feature del 2026-06-08, ambas ya verificadas por sesión registrada en este changelog — no hay evidencia de una base de datos de series de tiempo separada de Hive en el código actual.

## 2026-06-16

- `assets/condition_codes.json` v2 liberado (según el historial de versiones dentro del propio archivo).

## 2026-06-15 (narrativa de Gemini, sin verificar contra código)

- Localización multilingüe vía `flutter gen-l10n` (es/en/zh_TW), según el resumen de Gemini. Es probablemente la misma base de i18n que este changelog ya data el 2026-06-10 (`l10n.yaml` + ARB es/en, 45 claves, español como template) a partir de una sesión registrada — esa fecha del 06-10 sigue siendo la más confiable para la base. La entrada del 06-10 no menciona zh_TW; no está claro si zh_TW se agregó en una sesión posterior sin registrar (esta fecha sería candidata) o si la mención de Gemini es imprecisa.

## Junio 2026, ~13 al 30 (sin sesiones registradas en este proyecto; fechas exactas no registradas)

Ítems confirmados como completados antes de julio (por comentarios de código y auditoría de `lib/` del 07-13), pero sin registro del día. El resumen de Gemini aporta dos fechas puntuales dentro de esta ventana (06-15 y 06-17, ver arriba), pero sin poder mapearlas con certeza a estos ítems:

- **Symptom Detail Layer C.4 (Cefalea)** completado: 5 grupos, 19 chips, 1 red flag URGENT (thunderclap).
- **Fase 6, groundwork**: modelos `BowelEvent`/`HemorrhoidalEvent`/`SleepEntry`/`HydrationEntry`/`HrvReading`/`MovementMetric` (6.0), formularios de logging GI/sueño/hidratación/HRV (6.1/6.1b/6.1c/6.6-6.7 parcial), scaffold de `correlation_engine.dart`.
- **Sprint T0**: T0.1 (scorecard de Botiquín), T0.2 (narrativa semanal en tab Hoy), T0.3 (`symptom_frequency_dashboard.dart`).
- **Fase 3a (vademecum), lado de medicamentos**: rename/refactor `MedlinePlusService` → `VademecumService` (según comentarios de código; el lado de condiciones se completó recién el 2026-07-14).
- **Symptom Detail Layers, Batch 2**: `severity_picker.dart` convertido de `StatelessWidget` a `StatefulWidget` (según comentario de código, sin día exacto).
- **Sprint B (infraestructura beta)** cae probablemente en esta ventana (código de acceso `cebrasARRIBAch`, consentimiento de investigación, banner de feedback semanal, landing estática) — sin registro de sesión que lo date.

Nota: Sprint F/E/G ya no figuran en esta sección — ver corrección de datación en la entrada del 2026-07-06→12.

## 2026-06-12

- Sesión de planificación de **Fase 5** con el framework de 4 pasos (relevancia → diseño sin restricciones → factibilidad → calendarización) sobre 5 documentos de investigación: GI, HRV, filosofía de métricas de movimiento; ampliado a sueño, hidratación y diseño trauma-informed.
- Entregables: `README_en.md` extendido (~4.500 palabras, cada decisión con referencias peer-reviewed) y `PHASE_5_ROADMAP.md` (~4.400 palabras, 15 fases 5.0–5.10 con alcance, archivos, riesgos, estimaciones y dependencias).
- Decisiones: GI primero (mayor impacto, sin dependencia de plataforma); deploy móvil como track separado que no bloquea Fase 5; motor de correlación compartido construido una sola vez; simulador HRV educativo en Compendio (no herramienta de medición); pasada transversal trauma-informed (5.10) antes del merge final.
- Exclusiones decididas con racional documentado: tracker dedicado de síntomas de trauma, UI de BSS con fotos, gamificación de movimiento, push notifications en web, medición de HRV por sensor.
- **"Modo cuidadoso"** definido: opción de settings que suprime todas las tarjetas de detección de patrones.
- Correcciones establecidas como estándar: **clEDS = classic-like EDS** (no clásico) — error detectado en `README_en.md`, pendiente de corregir e incorporar a `README_es.md`; migración de schema de 5.0 flaggeada como la operación de mayor riesgo (testear contra exports reales de beta antes de merge).
- Para esta fecha el rename **ZebraUpp → ZebraUp** (una p) y el dominio `zebraup.netlify.app` ya estaban vigentes — el cambio ocurrió entre el 2026-06-10 y el 2026-06-12 (sin registro del día exacto).

## 2026-06-10

- Diagnóstico de **pérdida de datos aparente**: la PWA agregada al home screen de iOS corre en un contenedor IndexedDB aislado de Safari (los datos seguían existiendo en el contexto de Safari); además se identificó un patrón peligroso en `_loadUserProfiles` — un fallo de parseo caía silenciosamente a perfil default y llamaba `_saveData()`, sobrescribiendo datos reales.
- `LateInitializationError` en import rastreado a `FilePicker.platform` (campo `late` estático del plugin, registrant web desactualizado); fix vía `flutter clean && flutter build web --release`.
- **Base de i18n**: `l10n.yaml` + ARB es/en (45 claves, español como locale plantilla, registro LatAm neutro), `flutter gen-l10n`.
- `profile_io_service.dart` reescrito: `ImportException` tipadas, `validateJsonString()` compartido, **import por pegado de texto** como fallback sin plugin para PWA móvil.
- Persistencia agregada para `localeCode` (default `'es'`), `prefDarkMode` y `prefFontScale` (antes se reseteaban en cada recarga de la PWA); toggle de idioma en el drawer.
- Contexto de la sesión: EMA mood tracking (`ema_moods.json`) y un fix de Medline ya habían sido agregados por Paulina justo antes.

## 2026-06-08

- Batch multi-feature grande:
  - Hints de primera sesión en tab Hoy (estado persistido en Hive, lifted al screen padre).
  - **Primera integración de vademecum LatAm** vía MedlinePlus Connect con `condition_codes.json` nuevo (códigos ICD-10), caché Hive de 7 días, sheet de info con `DraggableScrollableSheet`.
  - **Tab Movimiento y Recuperación** (5º ítem de navegación): actividades y terapias como pares, framing anti-kinesiofobia, reconocimiento de pacing, log combinado cronológico, e-VAS de dolor pre/post opcional.
  - **Derechos ARCO**: export como descarga JSON, import con confirmación por preview, wipe en dos pasos con confirmación tipeada — vía `ProfileIoService` nuevo.
  - Sección TodaysDoses arriba del Botiquín con delete por dosis.
  - **LifeEvent**: rangos de fecha, categorías libres con chips de sugerencia, overlay de punto morado en calendario, gestión en drawer.
  - MedlinePlus reubicado del drawer al tab Compendio como sección MIS CONDICIONES; campo `relationship` nullable en `Profile` (soporte a cuidadores).
  - Fix de llaves en `sintomas_tab.dart` (reemplazo completo del archivo); `ABOUT.es.md` y `ABOUT.en.md` (misión, visión, principios, roadmap, nota a clínicos, historia personal).
- Convenciones fijadas en esta sesión: el archivo siempre fue `main_screen.dart` (nunca `main_app_screen.dart`); registro **tuteo neutro LatAm** sin voseo ni chilenismos, aplicable desde el inicio de cada sesión; la nav de 5 tabs queda en su límite práctico; todos los campos nuevos de `Profile` aditivos y backwards-compatible vía keys opcionales en `fromMap`; schema version 1 embebido en exports.

## 2026-06-07

- **Fase 1 (fundación de modelos)**: `SymptomSeverity` de 5 niveles (0–4); `MedicationDef` reestructurado (strength/unit/form/defaultQuantity separados + `id` estable); `DoseEvent` con quantity y snapshot `severityBefore`; `MedicationOutcome` con severidad antes/después (reemplaza enum binario); `MedicationGroup` con logging por lote vía `Profile.logGroup`; `interaction_engine.dart` consolidado como única fuente de verdad, con reglas por condición (EDS/POTS/MCAS/adenomiosis).
- **Fase 2A (rediseño Hoy)**: layout urgency-first con check-ins pendientes primero, `SeverityDotPicker` con visualización de anclas, selector único de 5 caras (reemplaza tres sliders en competencia), acordeón de detalles mentales, resumen narrativo en forma de oración.
- **Fase 2B (rediseño Botiquín)**: `MedFormSheet` completo con todos los campos del schema, `DoseQuantityStepper` con incrementos de 0.5 (titulación por media pastilla), swipe-to-delete preservando historial, edición vía lápiz.
- **Fase 2C**: CRUD completo de `MedicationGroup` vía `GroupFormSheet` (sentinela `kGroupDeleted`), sheet de log por lote con advertencia de entradas huérfanas, rediseño del tab Síntomas con `SeverityDotPicker`, adjuntos de foto vía `image_picker` y link de saltar valoración.
- **Decisión de APIs**: MedlinePlus Connect + Orphadata/Orphanet + SNOMED CT edición en español vía Snowstorm (input LatAm: Argentina/Uruguay), preferidos sobre CIMA (castellano de España) — se vuelve estándar del proyecto.
- Nacen los **patch scripts idempotentes** (`apply_phase1_patches.py`, `apply_phase2b_patches.py`, `apply_phase2c_patches.py`, brace-counting con awareness de comentarios/strings, segundo run reporta SKIP), como respuesta al problema de sync entre el editor web de GitHub y el Codespace.
- Bug introducido y corregido: clase `PubMedSearchResult` duplicada entre `models.dart` y `pubmed_service.dart` (imports ambiguos en `investigacion_tab.dart`).
- Regresiones reportadas al cierre en el rediseño de Síntomas: ZONAS ESTRUCTURALES (8 zonas × 6 tipos de issue EDS) dropeadas, campo inline "+ Añadir síntoma al baúl..." reemplazado por modal multi-paso, secciones EN TENDENCIA y ACTIVIDAD desaparecidas — la sesión terminó a mitad del rewrite de recuperación de `sintomas_tab.dart`. Corrección de copy: "Sabiduría **cebra**" (no "zebra"). Paulina fijó que los chips de actividad se mantienen visibles incluso en días de descanso.

## 2026-06-05 (primera sesión registrada en este proyecto) — ampliada con el transcript completo

*Esta entrada se amplió el 2026-07-16 con el PDF completo de la conversación (antes solo se tenía el resumen de `conversation_search`). El nivel de confianza sube de "resumen" a "transcript literal".*

- La app ya existía deployada (entonces "ZebraUpp", `zebraupp.netlify.app`, ya con timeseries events + catálogo separados, Hive, y el concepto de pacing "Potato Day"). Gaps identificados contra Bearable y Wave: timestamps no editables en registros retroactivos, sin tracking de efectividad de medicamentos, sin tracking mental, sin tracking de actividad (base: rutina Hampton Hybrid Calisthenics modificada de Paulina).
- **Primera pasada de fixes críticos sobre el código ya existente**, previa a la v2: bug de timestamp (`DateTime.now()` se usaba incluso al loguear en fechas pasadas, corrompiendo `getDosesForDay`/`getTrendingSymptoms`/el filtro de Reporte — corregido con un helper `_timestampForLog()` anclado a la fecha seleccionada); motor de interacciones hardcodeado en `_generateClinicalFlags` migrado a un `InteractionEngine` data-driven (`lib/services/interaction_engine.dart`, con la regla Duloxetina + Ibuprofeno → alerta hemorrágica en EDS/adenomiosis, ya coherente con la app blueprint del 05-27); severidad como string libre migrada a enum `SymptomSeverity` con parser retrocompatible con los strings viejos ("Severo", etc.); "sabiduría diaria" corregida para rotar por fecha en vez de fijarse una sola vez en `initState`.
- Tres carriles estratégicos evaluados (deploy móvil / fixes de UX / capa de investigación); se eligió avanzar UX + investigación en paralelo, siguiendo en Flutter + Netlify.
- Decisiones de modelo de datos discutidas antes de codear: una abstracción padre `LoggedEvent` (`id`, `timestamp`, `note`, `linkedEventIds` opcional) para enlazar dosis↔síntoma y permitir que la detección de patrones futura recorra una sola timeline en vez de cuatro — no queda claro en el transcript si se implementó tal cual o se resolvió de otra forma en la v2 entregada.
- Estados de salud mental fijados como lista cerrada de 6, escala 1–5: **Ánimo, Ansiedad, Niebla mental, Disociación, Irritabilidad, Energía emocional** — deliberadamente sin journaling ni prompts tipo "¿querés hablar de esto?".
- Catálogo de actividad (base Hampton Hybrid Calisthenics): Push-ups, Pull-ups, Squats, Bridges, Leg raises, Twists, Estiramiento, Caminata, Yoga gentil — cada registro con sets×reps (o duración), esfuerzo 0–10 (RPE), sensación 1–5, HRR opcional como texto libre, nota opcional. Deliberadamente descriptivo, no prescriptivo — la lógica de "qué ejercicio hacer" se difiere hasta acumular 4–6 semanas de datos cruzados con síntomas.
- Efectividad de medicación, mecánica exacta acordada: al loguear una dosis con un síntoma sin resolver logueado en las últimas 2h, aparece un checkbox opt-in ("¿Trackear si esto ayuda?"); se guarda un `MedicationOutcome` con `checkAt` a 3h; sin notificaciones push — la tarjeta de check-in ("Hace 3h tomaste X para Y. ¿Cómo está ahora?", con Mejor/Igual/Peor/No sé) espera en el tab Hoy hasta ser respondida o hasta 24h (auto "no sé"). `outcomeCheckHours: 3` quedó como default para paracetamol e ibuprofeno.
- Tab Clínica reorganizado en 3 sub-tabs: **Reporte / Compendio / Investigación** — la última corre PubMed automáticamente por cada condición del perfil activo al abrirse.
- **Primera confirmación registrada de las 4 condiciones trackeadas** en el perfil de Paulina en ese momento: **clEDS, Adenomiosis, POTS, Anemia** (`esearch` corría 4 queries separadas de PubMed, una por condición).
- Claude marcó una alerta de integridad sobre el documento de investigación que Paulina subió esa misma sesión ("System Architecture and Integration Framework for Rare Disease Informatics Platforms"): estadísticas muy específicas ("83.4% de casos", NCT numbers, ensayos 2026 puntuales) señaladas como sospechosas de alucinación de LLM y pendientes de verificación antes de construir features que dependieran de ellas — precursor directo del hallazgo de DOIs alucinados que se corrigió más adelante (ver notas de investigación del proyecto).
- **Entrega v2** en 8 archivos: `models.dart` (+`MentalEvent`, `ActivityEvent`, `MedicationOutcome`, enum `MentalState`, `PubMedArticle`, `kExerciseCatalog`, métodos de analítica), `pubmed_service.dart` (E-utilities con rate limit, caché Hive 24h en `pubmed_cache`, fallback offline), `timestamp_picker.dart` compartido (presets "Anoche 10pm", "Ayer"), `hoy_tab.dart` (sliders + chips mentales + tarjeta de check-in de outcome pendiente), `investigacion_tab.dart` (auto-fetch al abrir, abstracts lazy, guardar/abrir/copiar), `main.dart` (abre `pubmed_cache` al inicio), `main_screen.dart` (badges, respuesta de outcomes, log de dosis con outcome opt-in, timestamps editables vía long-press, sección de actividad), `pubspec` (+`http`, `xml`, `url_launcher`).
- Decisiones de arquitectura confirmadas: tarjetas de outcome de medicamentos en Hoy + badge en ícono de Botiquín; salud mental con sliders en Hoy + chips secundarios; PubMed auto-fetch silencioso al abrir el tab Clínica.
- Plan de reclutar amigas como beta testers (familiaridad real con el problema).
- **Narrativa adicional de Gemini para esta fecha (todavía sin verificar)**: introducción de accesibilidad (dark mode, font scaling) y arranque del pivote de página única a arquitectura multi-tab, más un commit grande hacia una "timeseries database". El transcript completo de esta sesión con Claude (recién incorporado) no menciona ninguno de estos ítems — consistente con que hayan ocurrido en otra sesión el mismo día (posiblemente Claude Code, sin registro), o con que la narrativa de Gemini sea imprecisa. Ninguna de las dos opciones puede confirmarse todavía.

## 2026-06-04

Fecha antes registrada aquí como "inicio del proyecto" (según `beta_website/web/blog.html`: *"Empecé este proyecto el 4 de junio de 2026"*) — **superada por la reconstrucción de mayo, más abajo**; se mantiene esta entrada para no perder el dato. Según el resumen de Gemini, el 4 de junio correspondería más bien a un empujón grande de funcionalidad clínica: manejo de diagnóstico, alertas condition-aware, escalas de gravedad dinámicas, transición de diario básico a herramienta de reportes clínicos modulares. Temáticamente se superpone con Fase 1 (fundación de modelos: `SymptomSeverity`, `MedicationOutcome`, `interaction_engine.dart`), que este changelog ya databa el 2026-06-07 a partir de una sesión registrada — esa fecha del 06-07 sigue siendo la más confiable para el detalle técnico específico; no está claro si el 06-04 es una sesión real separada o una imprecisión de la reconstrucción de Gemini.

## Origen del proyecto: mayo 2026 (reconstruido desde historial de conversaciones con Gemini, agregado 2026-07-16)

**Nota de fuente y confianza (v1, 2026-07-16)**: esta sección se reconstruyó originalmente a partir de un resumen que Paulina pidió a Gemini de conversaciones antiguas — sin transcript literal, sin commits, sin el blog público disponibles como respaldo directo (el blog decía "4 de junio", y la entrada de este changelog para el 2026-06-04 decía lo mismo, citándolo). Paulina confirmó entonces confiar en esa reconstrucción de Gemini por sobre esas dos fuentes. Corrección aplicada: el proyecto nació el **27 de mayo de 2026** bajo el nombre **ZebraTracker**, no el 4 de junio.

**Nota de fuente y confianza (v2, misma fecha, actualización posterior)**: Paulina aportó después los PDFs exportados de dos conversaciones reales de Gemini (con fecha verificable en la propia plataforma) más el PDF de la conversación real de Claude del 2026-06-05. Esto sube esas fechas de "resumen sin verificar" a **transcript literal verificado**:
- **2026-04-09, 16:19** (Gemini 3.5 Flash) — exploración pre-proyecto, sin nombre de app; ver nueva entrada "Abril 2026" al final de esta sección.
- **2026-05-27, 21:02** (Gemini, corrido dentro de un "Project" con instrucciones propias de Paulina) — la conversación de origen real, mucho más detallada que la entrada anterior basada solo en el resumen; ver esa entrada, reescrita.
- **2026-06-05** (Claude) — ya databa este changelog por un resumen de `conversation_search`; ahora hay transcript completo con más detalle técnico (ver esa entrada, ampliada).

Las entradas del **29 y 31 de mayo** siguen sin transcript propio — dependen todavía solo del resumen de Gemini y mantienen su nota de "sin verificar". El blog (`beta_website/web/blog.html`, `beta_website/web/en/blog.html`) se corrigió el 2026-07-16 para reflejar el origen del 27 de mayo. El nombre pasó por ZebraTracker → ZebraUpp (confirmado desplegado el 2026-06-05, ver esa entrada) → ZebraUp (rename de una sola p, confirmado entre el 06-10 y el 06-12). La ventana exacta del pivote ZebraTracker → ZebraUpp (en algún punto entre el 27 de mayo, ahora confirmado, y el 5 de junio, ya confirmado) sigue sin evidencia dura del día exacto.

## 2026-05-31

- Análisis de posicionamiento competitivo temprano, enfocado en prevenir sobrecarga cognitiva para usuarios con condiciones complejas multi-sistema. Precursor mucho menos detallado del análisis estructural de 12 apps del 2026-07-05→06 (ver esa entrada, ya verificada y con hallazgos concretos) — no se sabe si cubrió las mismas apps.

## 2026-05-29

- Debugging de problemas iniciales del codebase Flutter. Pivote de trabajo puramente técnico a estrategia de producto: define el público objetivo (pacientes hispanohablantes/mercado mHealth hispanohablante) — precursor directo del enfoque LatAm que el proyecto mantiene hoy.

## 2026-05-27 — origen real, verificado vía transcript de Gemini

Conversación real (no resumen) publicada en Gemini: *"Patient App Blueprint for Chronic Conditions"*, corrida dentro de un "Project" de Gemini con instrucciones propias de Paulina, 21:02 hora de creación. Reemplaza la entrada anterior de este changelog para esta fecha, que se apoyaba solo en el resumen posterior.

- Punto de partida: un documento propio (`Propuesta_Estudio_SED`, .docx) con investigación sobre EDS/HSD que Paulina ya tenía. Pedido explícito: una app que trackee síntomas sin carga manual excesiva, empezando general y customizando a específico; medicación fácil de ajustar; datos optimistas/"fun facts" sobre las condiciones, sin abrumar mentalmente.
- Blueprint de producto propuesto por Gemini, en cuatro piezas:
  1. **Onboarding "Accordion"**: empieza solo con la tríada EDS (hipermovilidad articular, hiperextensibilidad de piel, fragilidad tisular); según respuestas, "despliega" módulos relevantes (ej. marcar mareos activa el tracker de Disautonomia/POTS; marcar urticaria/sensibilidad activa el tracker MCAS); filtro "No soy yo" para ocultar lo que no aplica.
  2. **Gestor dinámico de medicación/suplementos**: alertas de conflicto (ej. Ibuprofeno + Duloxetina por riesgo GI — precursor directo de la regla `kInteractionRules` que aparece ya en producción el 06-05), recordatorios "inteligentes" con contexto (ej. "Día de hierro, tomar con Vitamina C en ayunas"), log rápido "SOS" para medicación de rescate.
  3. **"Zebra Wisdom" feed**: datos optimistas en microlearning (ej. propiocepción y fortalecimiento articular), coach de pacing "Start Low, Go Slow", script para consultas médicas.
  4. **Tracking holístico más allá del dolor**: "wins" funcionales en vez de solo escala de dolor, vista de "Tres Fases" (Hipermóvil / Dolor / Rigidez).
- Contexto personal aportado por Paulina en esta sesión: estudiante, a punto de perder su beca, laptop con memoria limitada, trabajo solo, no gratuito a menos que consiga suscripciones futuras.
- Decisión técnica: **Flutter** (no React Native) vía **GitHub Codespaces** (acceso gratuito de estudiante) en vez de instalar Android Studio/Xcode localmente; almacenamiento local (SQLite/Hive) preferido sobre Firebase/Supabase por privacidad y costo — la decisión "local-first" del proyecto nace en esta sesión.
- **Primer código real**: repositorio creado como "ZebraTracker" en GitHub; `flutter create .` falló por nombre en mayúscula (regla de nombres de paquete de Dart), corregido a `flutter create zebratracker` — el paquete quedó en minúscula desde el primer commit, aunque el repo se siguiera llamando "ZebraTracker".
- Se construyó un `ExpansionTile` funcional (el "Accordion") con 3 categorías iniciales — Joints & Mobility, Skin & Tissue, Systemic (POTS) — cada una con síntomas específicos como checkboxes.
- Sesión de debugging real en vivo: `flutter: command not found` (Flutter no estaba instalado en el Codespace, se instaló manualmente clonando el repo de Flutter), luego `Error: No pubspec.yaml file found` (faltaba correr `flutter create`), un error de compilación profundo del propio SDK de Flutter (`Matrix4` no definida en `semantics.dart`) resuelto con `flutter channel stable && flutter upgrade && flutter clean && flutter pub get`.
- Botones que no reaccionaban al toque (usaban `print()` en vez de lógica real) — corregido agregando navegación real (`Navigator.push`) y un segundo `StatefulWidget` con checkboxes que sí actualizan estado.
- **Pivote a bottom nav de 4 tabs** (Track / Reports / Exercises / Insights), motivado explícitamente porque Paulina pidió algo parecido a la app **Wave** (wavehealth.app) pero con reportes médicos, datos optimistas sobre las condiciones, y enlace con ejercicio — la primera mención registrada de Wave como referencia competitiva, anterior a la comparación Bearable/Wave del 2026-06-05.

## 2026-04-09 — exploración pre-proyecto, verificado vía transcript de Gemini

Conversación real (Gemini 3.5 Flash), 16:19 hora de creación, ~7 semanas antes del inicio real del proyecto (2026-05-27). Sin nombre de app todavía; Paulina pregunta en abstracto qué habilidades técnicas necesita para "una app que ayude a tener motivación y trackear metas, progreso y lesiones (como alguien con una enfermedad crónica)" para iPhone y opcionalmente Android.

- Gemini recomienda inicialmente **React Native** como más "global"/conocido, con Flutter como alternativa; discute Firebase/AWS Amplify como backend, gamificación (streaks, XP) y notificaciones no invasivas, accesibilidad, encriptación y principios GDPR/HIPAA aun para un proyecto personal.
- Paulina revela contexto de fondo que no vuelve a aparecer en sesiones posteriores registradas: formación en **Lingüística Aplicada** (doctorado en curso), conocimientos previos de **Python**, interés en construir apps educativas y juegos además del tracker de salud.
- Se exploran rutas de aprendizaje concretas: DevTalles/Fernando Herrera (Udemy, en español), Scrimba, Galaxies.dev, FreeCodeCamp (certificación de desarrollo de apps + curso de React Native), CS50W de Harvard (Django + JavaScript/React) como complemento al Python ya conocido, y el portal Apple Professional Learning (Swift/SwiftUI, descartado por Paulina por limitarse a iOS nativo sin cubrir Android).
- Ninguna decisión técnica de esta sesión sobrevivió al proyecto real: la sesión del 2026-05-27 (ver arriba) terminó eligiendo **Flutter**, no React Native, y GitHub Codespaces en vez de los cursos discutidos acá. Entrada incluida solo por completitud histórica — es la conversación más antigua que existe sobre la idea del proyecto, previa incluso al nombre "ZebraTracker".