# Changelog — ZebraUp

Historial de desarrollo reconciliado a partir de lo ya documentado en `CLAUDE.md`, `beta_website/web/blog.html`, comentarios de código, `docs/`, y — para las entradas de junio y principios de julio — el historial de conversaciones de este proyecto en Claude. No hay repositorio git en este entorno de trabajo, así que este archivo **no es un log de commits** — es una reconstrucción manual. Donde solo se conoce el mes o un rango (no el día exacto), se marca explícitamente en vez de inventar una fecha. Si aparece nueva información que contradiga una entrada de aquí, esta es la que se corrige — no al revés.

Nota de cobertura del historial de conversaciones: hay sesiones registradas en este proyecto del 2026-06-04/05 al 2026-06-12 y del 2026-07-02 en adelante. **No hay sesiones registradas entre el 2026-06-13 y el 2026-07-01** — el trabajo de ese período probablemente ocurrió en Claude Code u otro entorno, y por eso queda sin fecha por día.

Convención: más reciente primero. La mayoría de las sesiones desde el 2026-07-13 se hicieron sin toolchain de Flutter local (revisión manual de campos/llaves/paréntesis, no compilado) — ver `CLAUDE.md` si una entrada puntual necesita ese detalle.

---

## 2026-07-17

- **Rework del rediseño de dolor estructural del día anterior**: Paulina rechazó el embudo de 4 grupos (forzaba silenciosamente `kind=painWithoutClearCause`, sin preguntar nunca el tipo real). Reemplazado por un flujo combinado zona+tipo que se puede iniciar por cualquiera de los dos extremos: tocar un chip de zona ahora también pregunta el tipo; escribir texto libre en el baúl ("dolor muscular", "dolor pierna") detecta cuál de las dos piezas ya viene dada y pregunta solo la que falta. "Ya sé qué es" (picker clínico específico) y el quick-log de zonas conocidas quedaron intactos.
- Nuevo `lib/services/structural_text_detector.dart` (detector de zona/tipo por palabras clave sobre texto libre) y `lib/widgets/body_zone_picker_grid.dart` (grilla de zonas extraída para reusarse en el sheet nuevo). `structural_detail_sheet.dart` reescrito como máquina de 3 pasos (zona → tipo → los 4 grupos existentes). 5 tipos placeholder genéricos nuevos en `kStructuralTaxonomy` (uno por kind, mismo patrón que `joint_pain`) + `kGenericStructuralTypeForKind`. 9 claves ARB nuevas en es/en/zh.
- Bug propio encontrado y corregido en la misma sesión: "pierna"/"espalda" sueltas no resolvían ninguna zona específica (ambiguas) ni ningún tipo, así que "dolor pierna" caía al menú genérico en vez de abrir el sheet — contradecía el propio ejemplo de Paulina. Corregido con un flag de señal ambigua que abre el sheet igual, empezando por el paso de zona.
- Se usó plan mode explícitamente (research + diseño + aprobación antes de tocar código) por tratarse de un rework de una feature shippeada el día anterior.

## 2026-07-16

- **Deuda técnica resuelta**: `HeadacheRedFlagSeverity`, `FatigueRedFlagSeverity` y `AbdominalRedFlagSeverity` (triplicados) consolidados en un único `RedFlagSeverity` (`lib/models/red_flag_severity.dart`), reusado por los tres servicios de red flags. Rename `_showAdvisoryFlags` → `_showHeadacheAdvisoryFlags` por simetría.
- **Selector de medicamento post-síntoma** (`action_taken_sheet.dart`, Sprint F.B+C) ahora excluye medicamentos `basalScheduled` — solo muestra `prnRescue | both | undefined`.
- **Botiquín**: el toggle de orden A-Z dejó de resetearse al cambiar de pestaña; ahora persiste en `profile.settings.optionalTrackers['botiquin_sort_alpha']` (sobrevive también a reinicios de la app).
- **Rediseño de dolor estructural implementado** (diseñado el mismo día, ver más abajo): `StructuralDetail` nuevo (`lib/models/structural_detail.dart`), embudo de 4 grupos/18 chips (`structural_detail_sheet.dart`), 7º `StructuralEventKind.painWithoutClearCause`, historial de zona (`StructuralZoneHistoryEntry`, `structural_zone_history_form_sheet.dart`, gestión en `ProfileSettingsScreen`), quick-log para zonas conocidas (`structural_quick_log_sheet.dart`). Ícono del timeline "Registros de hoy" corregido para usar `_iconForKind` en vez de un ⚠️ uniforme. ~24 claves ARB nuevas en es/en/zh/zh_TW.
- **Diseño (sin código)**: cierre del rediseño de dolor estructural en `docs/design_decisions/symptom_detail_laters.md` §12 (tejido blando y red flags estructurales quedan diferidos como hilo propio). Diseño del Panel de Signos Vitales (`docs/design_decisions/vital_signs_panel.md`) — unifica fiebre/HRV/presión arterial/respuesta ortostática; la prueba ortostática queda pausada a pedido explícito de Paulina por el punto de seguridad de riesgo de síncope.
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

## 2026-06-16

- `assets/condition_codes.json` v2 liberado (según el historial de versiones dentro del propio archivo).

## Junio 2026, ~13 al 30 (sin sesiones registradas en este proyecto; fechas exactas no registradas)

Ítems confirmados como completados antes de julio (por comentarios de código y auditoría de `lib/` del 07-13), pero sin registro del día:

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

## 2026-06-05 (primera sesión registrada; el proyecto inició el 04)

- La app ya existía deployada (entonces "ZebraUpp", `zebraupp.netlify.app`). Gaps identificados contra Bearable y Wave: timestamps no editables en registros retroactivos, sin tracking de efectividad de medicamentos, sin tracking mental, sin tracking de actividad (base: rutina Hampton Hybrid Calisthenics modificada de Paulina).
- Tres carriles estratégicos evaluados (deploy móvil / fixes de UX / capa de investigación); se eligió avanzar UX + investigación en paralelo, siguiendo en Flutter + Netlify.
- **Entrega v2** en 8 archivos: `models.dart` (+`MentalEvent`, `ActivityEvent`, `MedicationOutcome`, enum `MentalState`, `PubMedArticle`, `kExerciseCatalog`, métodos de analítica), `pubmed_service.dart` (E-utilities con rate limit, caché Hive 24h en `pubmed_cache`, fallback offline), `timestamp_picker.dart` compartido (presets "Anoche 10pm", "Ayer"), `hoy_tab.dart` (sliders + chips mentales + tarjeta de check-in de outcome pendiente), `investigacion_tab.dart` (auto-fetch al abrir, abstracts lazy, guardar/abrir/copiar), `main.dart` (abre `pubmed_cache` al inicio), `main_screen.dart` (badges, respuesta de outcomes, log de dosis con outcome opt-in, timestamps editables vía long-press, sección de actividad), `pubspec` (+`http`, `xml`, `url_launcher`).
- Decisiones de arquitectura confirmadas: tarjetas de outcome de medicamentos en Hoy + badge en ícono de Botiquín; salud mental con sliders en Hoy + chips secundarios; PubMed auto-fetch silencioso al abrir el tab Clínica.
- Plan de reclutar amigas como beta testers (familiaridad real con el problema).

## 2026-06-04

Inicio del proyecto (según `beta_website/web/blog.html`: *"Empecé este proyecto el 4 de junio de 2026"*).