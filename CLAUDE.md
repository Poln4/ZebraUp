ZebraUp Agent Instructions

Propósito y Contexto del Proyecto

ZebraUp es una PWA de salud (mHealth) desarrollada en Flutter Web, dirigida a pacientes hispanohablantes de América Latina con condiciones raras y complejas del tejido conectivo (pacientes "zebra"). Es local-first, se despliega en Netlify, y actualmente está en beta con testers chilenos.

Desarrolladora y paciente: Paulina es la única desarrolladora y también paciente con clEDS (síndrome de Ehlers-Danlos clásico-like, TNXB-relacionado), lo que fundamenta muchas decisiones de diseño.

Origen y nombre del proyecto (reconstruido 2026-07-16 desde historial de conversaciones en Gemini, ver CHANGELOG.md § "Origen del proyecto"): el proyecto nació el 27 de mayo de 2026 bajo el nombre **ZebraTracker**, antes de evolucionar a **ZebraUpp** (confirmado desplegado el 2026-06-05) y luego a **ZebraUp** (rename de una sola p, entre el 06-10 y el 06-12 de 2026). Esta reconstrucción de Gemini reemplazó la fecha de inicio (4 de junio) que decía antes tanto este archivo como el blog público — sin transcript literal ni commits que la respalden directamente, ver la nota de fuente y confianza en CHANGELOG.md antes de citarla externamente.

Objetivos Clave


Generar datos clínicamente útiles y objetivos para pacientes con poco tiempo en citas médicas.
Reducir carga cognitiva; aplicar diseño trauma-informado.
Mantener arquitectura local-first como diferenciador de confianza.
Respaldar una publicación académica peer-reviewed.
Escalar eventualmente a otros mercados (Taiwan, global).



Stack Técnico


Framework: Flutter Web (PWA)
Almacenamiento local: Hive (cajas tipadas)
Hosting: Netlify (app + sitio de landing beta separado)
Dev environment: GitHub Codespaces
Versionamiento: Git + ramas por sprint
Localización: ARB (Spanish template + English + zh_TW); pt-BR (Portugués de Brasil) planeado — ver Post-Fase 6
Arquitectura de datos: Modelos enum + typed detail layers + transversal Actions


Hive Boxes


zebraBox – datos principales (síntomas, medicamentos, eventos, acciones, perfil)
pubmed_cache – caché de búsquedas (24h)
betaAccessBox – estado de acceso (código beta)


APIs Planeadas (no CIMA/España)


MedlinePlus Connect – medicamentos y referencias clínicas LatAm
Orphadata/Orphanet – info de enfermedades raras
SNOMED CT Spanish (Snowstorm) – códigos estandarizados LatAm
PubMed E-utilities – referencias científicas (rate-limited, caché 24h)
MeSpEn dataset + corpora SciELO LatAm – soporte de terminología médica en español (sourcing del vademecum, ver docs/eds_research_notes.md)



Convenciones de Código

Archivos y Estructura


Archivo principal: SIEMPRE main_screen.dart, nunca main_app_screen.dart.
Modelos: models.dart, además de modelos por feature: action_taken.dart, mcas.dart, abdominal_detail.dart, fatigue_detail.dart
Servicios de datos: profile_io_service.dart, pubmed_service.dart, symptom_definitions_service.dart
Servicios por feature: mcas_red_flag_service.dart, flare_detection_service.dart, abdominal_red_flags.dart, abdominal_detail_format.dart, fatigue_red_flags.dart, fatigue_detail_format.dart
Widgets por feature: mcas_detail_sheet.dart, mcas_advisory_dialog.dart, abdominal_detail_sheet.dart, fatigue_detail_sheet.dart, flare_chip.dart (FlareChip/FlareBanner/FlareSuggestionBanner), action_taken_sheet.dart (ActionTakenSheet), retro_symptom_banner.dart (RetroSymptomBanner/RetroSymptomDialog), follow_up_banner.dart (FollowUpBanner/ActionEffectivenessDialog), pdf_export_sheet.dart (PdfExportSheet)
Tabs: sintomas_tab.dart, hoy_tab.dart (minúsculas con guión bajo)
Motor de interacción: interaction_engine.dart
Configuración: condition_codes.json, ema_moods.json, symptom_definitions.json, archivos de alias de síntomas (JSON en assets/)
Settings/Perfil (Sprint P.C, 2026-07-13): lib/screens/settings/ — profile_settings_screen.dart, language_settings_screen.dart, tracking_settings_screen.dart, account_data_screen.dart, about_screen.dart. Cada subsección de Ajustes es su propia pantalla, pusheada desde el menú slim de main_screen.dart (_buildSettingsDrawer). Ver "Reorganización de Settings" más abajo.
Corrección: correlation_engine.dart, bowel_form_sheet.dart, sleep_form_sheet.dart, hemorrhoidal_form_sheet.dart, hrv_form_sheet.dart, hydration_form_sheet.dart, therapy_logger_sheet.dart YA EXISTEN en el código (confirmado 2026-07-13, ver Fase 6) — no están "planeados, aún no creados" como decía una versión anterior de este archivo. Sigue pendiente: progression_suggester.dart, calisthenics_progressions.json.


Nombres de Métodos y Campos

SIEMPRE verifica contra el archivo actual antes de asumir nombres. Errores previos:


Asumió _openBowelSheet cuando es _openBowelForm
Asumió campo accompaniedByPain que no existe en la estructura


Flutter/Dart


Uso de late para inicialización retardada.
Enums tipados: SymptomSeverity (0–4), ActionKind (13 tipos), EffectivenessRating (5), LinkedEventType (4), MCASReactionKind (10), MCASOnsetWindow (6), TriggerKind (7), MCASRedFlag (6), etc.
Pattern matching y sealed classes cuando sea posible.
Comentarios en inglés en código; copy UI en español.
Deserialización: usar xRaw is Map (no map[key] != null) para chequear presencia de sub-objetos anidados — adoptado tras un bug de hotfix en Sprint E.A donde el chequeo != null pasaba silenciosamente con estructuras inválidas.
Deuda técnica resuelta (2026-07-16): HeadacheRedFlagSeverity, FatigueRedFlagSeverity y AbdominalRedFlagSeverity estaban triplicados; consolidados en un único `RedFlagSeverity` (lib/models/red_flag_severity.dart), reusado por los tres servicios de red flags y por sintomas_tab.dart. De paso se renombró `_showAdvisoryFlags` (cefalea) a `_showHeadacheAdvisoryFlags` por simetría con los otros tres métodos `_show*Flags`.


Convención de Parches (Patch Scripts)


Preflight de 5 preguntas antes de tocar symptom_definitions.json u otro JSON de configuración: verificar que el archivo cargó, que las claves son sufijos planos (label_es, def_es, _zh — no _zh_TW anidado), que existe el sub-nodo master requerido, y confirmar con un lookup real antes de asumir éxito. Adoptado tras el bug D.1.A.fix (JSON "cargaba" pero cada lookup devolvía null silenciosamente).
Anchor-drift preflight: antes de parchear un archivo existente, pedir un paste fresco de la región objetivo y verificar nombre/firma exacta de método y existencia real de campos/getters — no confiar en pastes de turnos anteriores que pueden haber quedado desactualizados (lección de D.2.E).
Sentinelas precisas para idempotency: match exacto de instanciación de widget, ej. "_OnboardingGate(child:", no solo nombre de clase. Segunda ejecución del patch debe reportar SKIP, no fallar.
Para insertar en cadenas condicionales (sintomas_tab.dart, main_screen.dart) sin depender de formato exacto: usar la técnica de "balanced-brace / balanced-paren walk" en lugar de matching de texto literal (estándar desde Sprint E y Sprint G).


Disciplina de Color (Design System)

Paleta de solo-contraste (cc/ic con alpha) para estados normales/pendientes. Rojo estrictamente reservado para alertas de emergencia/URGENT — nunca usar colores de acento (ámbar, índigo) para estados "pendientes" u otros no urgentes. Codificado tras feedback de beta en F.E2, donde colores de acento se interpretaban como urgencia falsa.

Retrocompatibilidad

Todos los campos nuevos en Profile deben ser aditivos. Implementar vía claves opcionales en fromMap:

dartprofile.optionalNewField = map['optionalNewField'] as bool? ?? defaultValue;

Nunca eliminar o renombrar campos sin migración Hive.


Convenciones de Español

Idioma Neutro Latinoamericano


Tuteo estándar: "toca", "registra", "escribe", "puedes".
PROHIBIDO: Voseo rioplatense (vos/sos/tenés/podés), slang chileno, regionalismos castellanos.
Verificación: Los scripts de parche incluyen escaneo de voseo; no pasar código con construcciones voseo.
Lenguaje neutro en género: evitar copy con flexión de género (ej. "agotada"). Ejemplo canónico (D.1, chip de fatiga): se rechazó "Agotada pero acelerada" en favor de "No logro descansar aunque el cuerpo está exhausto" — completamente neutro.
Vocabulario GI nuevo (roadmap Fase 6, aún no shippeado): "tránsito intestinal", "estreñimiento", "sangrado anal", "distensión" — requieren revisión de testers chilenos antes de merge.


Terminología Clínica (CRÍTICO)


Correcto: "síndrome de Ehlers-Danlos clásico-like (clEDS, TNXB-relacionado)" o simplemente "clEDS".
INCORRECTO: "Ehlers-Danlos clásico" (eso es COL5A1/A2, genéticamente distinto).
Paulina tiene clEDS, no EDS clásico. Esto va en README, comentarios, y cualquier referencia pública.


Reglas de Copy en Advisories / Red Flags (codificado en D.1, fatiga)


Sin acrónimos en copy dirigido al paciente (PEM, POTS, ME/SFC, HPA) — explicar el mecanismo en lenguaje llano.
Cierre de sugerencia siempre suave ("considera mencionárselo"), nunca imperativo.
Humildad epistémica: "puede indicar", nunca "indica" o "confirma".


Tokens Localizados

Todos los strings UI nuevos van en lib/l10n/app_es.arb (template) con clave única en lowerCamelCase. Luego correr flutter gen-l10n antes de compilar.


Arquitectura de Datos

Modelos Principales

SymptomSeverity (0–4 enum)
MedicationDef, DoseEvent, MedicationOutcome
LifeEvent
ActionTaken (Sprint F) — ActionKind (13 tipos, incluye nothing agregado en F.E), EffectivenessRating (5), LinkedEventType (4)
MCASDetail (Sprint E) — MCASReactionKind (10), MCASOnsetWindow (6), TriggerKind (7), TriggerTag, MCASRedFlag (6)
FlareState / ProfileState.flare (Sprint G) — resultado de flare_detection_service.dart
Profile (con campos aditivos opcionales)

Symptom Detail Layers

Capas tipadas de profundidad clínica creciente. Cobertura actual: 6 de 6 síntomas planeados (100%) — completo.


C.4 (Cefalea): ✓ completado 2026-06. 5 grupos, 19 chips, 1 red flag URGENT (thunderclap).
D.1 (Fatiga): ✓ completado 2026-07-02. 4 grupos, 20 chips, 0 URGENT (solo ADVISORY) — síntomas de fatiga post-esfuerzo, timing, triggers.
D.2 (Dolor Abdominal): ✓ completado 2026-07-02. 5 grupos, 22 chips (excede deliberadamente el techo de ≤20 de Morren 2009), 3 red flags (1 diálogo de emergencia in-sheet "desgarro" + 2 post-save). Integración bidireccional con BowelEvent (linkedBowelEventId, prompt bowel→abdominal y abdominal→bowel), divulgación semántica progresiva para clusters de dolor/hinchazón/gases, estructura de red flags en 3 niveles (in-sheet URGENT / post-save URGENT / post-save ADVISORY).
D.3 (Presíncope): ✓ completado 2026-07-17. 4 grupos, 19 chips, 3 red flags (1 diálogo de confirmación in-sheet "pérdida de consciencia breve" + 2 post-save ADVISORY). Deliberadamente sin componente de medición — `OrthostaticTest` diferido a versión móvil por seguridad. Ver "Sesión 2026-07-17" más abajo y `docs/design_decisions/symptom_detail_layers.md` §13.
D.4 (Dolor pélvico): ✓ completado 2026-07-17 (mismo día que D.3, sesión separada). 5 grupos, 23 chips (excede deliberadamente el techo de ≤20 de Morren 2009, mismo tipo de desviación que D.2), 5 red flags (1 diálogo de confirmación in-sheet "inicio súbito" + 2 post-save URGENT + 2 post-save ADVISORY). Trauma-informed por diseño: chip de ubicación externa con wording suave ("zona íntima", no "genital"), chip de dolor sexual/dispareunia incluido como opcional y skippable — ambas decisiones confirmadas explícitamente con Paulina antes de codear. Grounding: ACOG Practice Bulletin No. 218 (Chronic Pelvic Pain, DOI 10.1097/AOG.0000000000003716), verificado vía WebSearch. Ver "Sesión 2026-07-17 (continuación)" más abajo y `docs/design_decisions/symptom_detail_layers.md` §14.
D.5 (Dolor torácico): ✓ completado 2026-07-17 (mismo día que D.3/D.4, sesión separada). 4 grupos, 21 chips (excede deliberadamente el techo de ≤20 de Morren 2009, mismo tipo de desviación que D.2/D.4), 6 red flags (1 diálogo de confirmación in-sheet "desgarro" + 2 post-save URGENT + 3 post-save ADVISORY) — más que cualquier capa anterior, confirmando la nota "múltiples red flags esperadas" del backlog original. Primera capa cuya copy de red flag se bifurca según `Profile.conditions`: el diálogo in-sheet de "desgarro" muestra texto vEDS-específico (evitar compresiones torácicas, RM/TC cruciales) cuando el perfil coincide con palabras clave de EDS vascular, vía `isLikelyVEDSFromConditions()` — mismo matching por substring que ya usaba `condition_labels.dart`, decisión confirmada explícitamente con Paulina antes de codear. Grounding: Gulati et al. 2021 (AHA/ACC Chest Pain Guideline, DOI 10.1161/CIR.0000000000001029) y Isselbacher et al. 2022 (ACC/AHA Aortic Disease Guideline, DOI 10.1161/CIR.0000000000001106, cubre vEDS explícitamente), ambos verificados vía WebSearch. Sexta y última Symptom Detail Layer — cierra la cobertura 6 de 6. Ver "Sesión 2026-07-17 (segunda continuación)" más abajo y `docs/design_decisions/symptom_detail_layers.md` §15.

Rediseño de dolor estructural (diseñado y shippeado el mismo día, 2026-07-16 — distinto de D.3-D.5, es un rediseño de la taxonomía `kStructuralTaxonomy` ya existente, no un síntoma nuevo de los 6 planeados). Diseño cerrado en `docs/design_decisions/symptom_detail_layers.md` §12: 18 chips en 4 grupos (Lateralidad, Carácter del dolor, Antecedente, Mecánica) sobre 6 de las 7 categorías estructurales, nuevo 7º kind "dolor sin causa estructural clara", antecedente estructural conocido (historial por zona para casos post-quirúrgicos/crónicos). Tejido blando (heridas/hematomas) diferido como hilo propio con grounding real (Kumskova 2023 completo + De Paepe 2004), candidato a adaptar el ISTH-BAT como taxonomía de severidad validada. Mapeo HPO diferido hasta agrupar con D.4/D.5.

Implementado (2026-07-16, ver "Sesión 2026-07-16" más abajo para el detalle completo): `StructuralDetail` nuevo (lib/models/structural_detail.dart), 7º `StructuralEventKind.painWithoutClearCause` + entrada en `kStructuralTaxonomy`, y `StructuralZoneHistoryEntry` + `Profile.structuralZoneHistory`. Tocar zona ahora abre por defecto el embudo de 4 grupos (reemplaza elegir un tipo clínico específico); "Ya sé qué es" sigue abriendo el picker clásico kind→tipo sin cambios; zonas con historial conocido saltan directo a severidad + "¿distinto a lo usual?". El ícono uniforme ⚠️ del timeline "Registros de hoy" (el problema motivador original de §12.1: DOMS con el mismo ícono que una subluxación) quedó corregido — usa `_iconForKind` como ya hacía el picker de creación. Gestión del historial de zona desde Ajustes → Perfil, calcada de la sección de `lifeEvents`. Sin toolchain de Flutter — revisado manualmente, pendiente `flutter analyze`/`flutter run` antes de confiar en que compila. Tejido blando, red flags estructurales y mapeo HPO siguen diferidos, sin cambios.

**Addendum 2026-07-16 (feedback de Paulina, ver "Sesión 2026-07-16" más abajo):** el embudo de 4 grupos forzando silenciosamente `kind=painWithoutClearCause` (sin preguntar nunca el tipo real) quedó identificado como un problema real, no una simplificación aceptable — Paulina lo rechazó explícitamente al día siguiente de shippeado. Reemplazado por un flujo combinado zona+tipo: tocar una zona ahora también pregunta el tipo general (antes de los 4 grupos), y el baúl de texto libre puede iniciar el flujo por cualquiera de los dos extremos ("dolor muscular" → pregunta zona; "dolor pierna" → pregunta zona y tipo). "Ya sé qué es" y el quick-log de zonas conocidas no cambiaron.


Alias Semántico

detectAliasVariant() en SymptomDefinitionsService para divulgación semántica progresiva (ej., paciente dice "debilidad", app aprende es fatiga post-esfuerzo).


Flujos de Trabajo de Desarrollo

Branching


Rama main = versión de producción estable.
Rama develop = integración de sprints.
Por cada sprint, crear rama feature: feature/sprint-F-actions, feature/sprint-E-mcas, etc.
Antes de cambios mayores: crear rama de trabajo y merguear solo después de testing.


Sprint Structure


Labeled A/B/C/D... (ej., "Sprint F.A", "Sprint F.E2").
Después de cada sub-sprint, documentar decisiones en docs/design_decisions/ con cita académica donde aplique.
Cerrar sprints con checklist de verificación (más abajo) y, para features de superficie amplia, con el checklist de QA manual (ver Testing Beta).


Testing Beta


Los testers chilenos reciben actualizaciones via Netlify.
Cada feature sale con template de reporte de bugs (P0/P1/P2 severity).
Resolver bugs antes de pasar a sprint siguiente.
QA manual estructurado: docs/sprint_s1_testing_checklist.md — 8 sesiones (30-60 min c/u, ~4-6 hrs total) cubriendo onboarding cross-browser, persistencia (incluye corrupción manual de Hive vía DevTools y agotamiento de storage quota), edge cases temporales (rollover de medianoche, cambio de timezone, ciclo de check-in de 48h de Flare Mode), flujo completo de Flare Mode (activación, supresión, que las alertas urgentes nunca se supriman, desactivación, auto-sugerencia), banner de feedback + consentimiento, matriz cross-browser (Chrome/Safari desktop+mobile, Firefox), y accesibilidad/performance opcional. Este checklist es complementario al Checklist de Verificación de esta sección — no lo reemplaza.


Deployment


Deploy a zebraup-beta.netlify.app (sitio de landing) desde rama develop.
Deploy a zebraup.netlify.app (app principal) una vez alcanzado hito de fase.

Tracking de deploys reales (agregado 2026-07-16): ver CHANGELOG.md § "Estado de Deploy (zebraup.netlify.app)". "Trabajar en X" (este log) y "subir X en línea" son eventos distintos — no hay git ni acceso a Netlify desde este entorno, así que cada deploy real de zebraup.netlify.app queda registrado ahí solo cuando Paulina lo reporta explícitamente. Por defecto, asumir que el código de este directorio va por delante de lo que está en línea.

Numeración de versión (iniciada 2026-07-16, ver detalle en CHANGELOG.md): Paulina fijó **2.3.3** como número base del último deploy real confirmado (~2026-07-15) y **2.3.4** para el deploy pendiente de hoy — punto de partida elegido por ella, no continuación orgánica de semver (`pubspec.yaml` decía `1.0.0+1` sin historial de bumps hasta este momento). `pubspec.yaml` ya está en `2.3.4+1`, listo para el deploy de hoy — bumpear ahí en cada ciclo de trabajo futuro y reflejarlo en CHANGELOG.md § "Estado de Deploy" cuando Paulina confirme el deploy real.



Checklist de Verificación Antes de Cambios

Antes de tocar cualquier archivo, verificar:

Modelos / Campos


 ¿Es este campo nuevo? Implementar como optional en fromMap.
 ¿Necesita persistencia en Hive? Añadir decorador @HiveField() y regenerar.
 ¿Afecta a Profile? Versionar en profileVersion si es migración de schema.


Copy / Strings


 ¿Todo es tuteo latinoamericano neutro y neutro en género? (sin vos/sos/tenés, sin chilenismos, sin flexión de género)
 ¿Si menciona clEDS, es la terminología exacta?
 ¿Si es copy de advisory/red flag, cumple las reglas de la sección Convenciones de Español (sin acrónimos, cierre suave, humildad epistémica)?
 ¿Los strings nuevos van en .arb con clave única?
 ¿Se corrió flutter gen-l10n?


Archivos Tocados


 ¿Nombre de archivo es el correcto? (ej., main_screen.dart, no main_app_screen.dart)
 ¿Métodos verificados contra código actual? (no asumir nombres; aplicar anchor-drift preflight)
 ¿Se mantiene consistencia con archivos relacionados?
 ¿Sigue la disciplina de color (rojo solo para URGENT)?


Localización


 Si toca l10n/, actualizar todas las claves en app_es.arb, app_en.arb, app_zh_TW.arb.
 Ejecutar flutter gen-l10n para generar app_localizations.dart.


Retrocompatibilidad


 ¿Es un cambio de schema? Documentar en profile_io_service.dart con versionado.
 ¿Hay caché de PubMed? Si se añaden campos a DoseEvent o similar, revisar serializador.


Testing Local


 Probar build web local: flutter run -d chrome (o similar).
 Verificar dark mode (prefDarkMode), font scale (prefFontScale), locale (localeCode) persisten.
 Simular pérdida de datos: limpiar Hive y reiniciar app.



Patrón de Interacción: Post-Symptom → ActionTaken (Diferenciador Principal)

Este es el feature más profundo de ZebraUp: nada en el mercado lo hace de forma nativa (ver Análisis Competitivo). Confirmado tras análisis de 16 apps: ClarityDTX reclama algo similar pero tiene problemas de credibilidad (SKUs de paywall caóticos, discrepancias entre privacy label y marketing, conteos de reseñas no verificables).

Flujo (shippeado, Sprint F.A–F.E3):


Paciente registra síntoma agudo (ej., dolor abdominal, fatiga).
App pregunta: "¿Qué hiciste justo después?" (ActionTaken: descanso, medicamento, cambio postura, nada, etc. — 13 ActionKind).
App registra timestamp y tipo de acción.
Más tarde, paciente vuelve a reportar síntoma → app pregunta: "¿Mejora desde la última vez?" + Likert scale (EffectivenessRating).
Motor de interacción correla acción → outcome con timing (ventana ajustada de 30min a 90min en F.E2 tras feedback de beta).


Nota de pivote (Sprint F.E): el patrón original de hook proactivo por síntoma se revirtió a favor de un patrón retro (RetroSymptomBanner/RetroSymptomDialog) más simple.

Referencia: Welltory's "Experiments" pattern (pre/post), pero nativo en la app de síntomas, no separado.


Roadmap de Sprints y Fases

Sprint F (Acciones Transversales) — ✅ prácticamente completo


F.A ✅ Modelos ActionTaken, ActionKind (13 tipos), EffectivenessRating, LinkedEventType.
F.B+C ✅ Sheet proactivo + hooks para bowel/hemorroidal/fiebre (el hook de síntoma se revirtió después).
F.D ✅ FollowUpBanner + diálogo de efectividad.
F.E ✅ Pivote a patrón retro para síntomas; se agregó ActionKind.nothing.
F.E2 ✅ Refinamientos UX: ventana de timing 30min→90min, reubicación de banner, paleta solo-contraste, gating de BucketNormal en bowel.
F.E3 ✅ Tags retro en lenguaje natural dentro del log de síntomas.
F.F ✅ (2026-07-14) Selector MedicationType en Botiquín: campo `MedicationDef.medicationType` (models.dart) + picker en MedFormSheet (med_form.dart). El toggle de settings para action_taken ya estaba shippeado. El picker de medicamentos de F.B+C (action_taken_sheet.dart) ya filtra por este campo desde el 2026-07-16 — excluye `basalScheduled`, muestra `prnRescue | both | undefined`.


Sprint E (MCAS / Alergias) — ✅ completo (E.A–E.E)


MCASDetail, mcas_detail_sheet.dart integrado en sintomas_tab.dart (mutuamente excluyente con otras detail layers).
mcas_red_flag_service.dart + mcas_advisory_dialog.dart (barrier-dismissible: false).
Toggle de settings "Detalle MCAS / alergias", default off (framing exploratorio).
Diálogo de red flags con título "Señales de alerta".
Deferred: migrar heurística de keywords _isMCASSymptom a symptom_definitions_service.dart.


Sprint G (Flare Mode) — ✅ completo (G.A / G.B / G.B.2 / G.C / G.E)


FlareState/ProfileState.flare, flare_detection_service.dart con 3 reglas heurísticas (acumulación de síntomas severos, red flag MCAS reciente, patrón PEM).
FlareChip/FlareBanner/FlareSuggestionBanner, lógica de supresión (G.C) que oculta 4 widgets opcionales durante brote sin suprimir nunca alertas de seguridad urgentes.
Cooldown de 24h para dismissal de sugerencia; ciclo de check-in de 48h.
G.D (layout UI simplificado): deliberadamente diferido hasta tener más datos de beta.
G.F (check-in de 48h): consolidado dentro de G.E, no se construyó como sub-sprint separado.


Sprint S1 (QA Beta) — en curso

Checklist de testing manual sobre la superficie combinada F+E+G (ver Testing Beta arriba).

Fase 5 — Symptom Detail Layers + Action Capture (tracker vivo: docs/phase_5_roadmap-3.md)

Nombre histórico de lo que hoy son los Sprints F/E/G más Symptom Detail Layers. Estado: en curso, mayormente completo (ver arriba). Incluye además:


Sprint T0 (Tier 0 data leverage): T0.1 Botiquín scorecard ✅, T0.2 narrativa semanal en Hoy ✅, T0.3 dashboard de frecuencia de síntomas — aparece como "queued" en el tracker pero SymptomFrequencyDashboard ya existe y se suprime durante Flare Mode (Sprint G); verificar con Paulina si T0.3 debe marcarse como shippeado.
TZP (The Zebra Project / registro de EDS Society) export interoperability — deferred, track de Fase 4+.
Escalas clínicas estandarizadas (PHQ-9, GAD-7, FIQR, Rand-36) como prompts periódicos opcionales — deferred.


⚠️ Nota histórica de naming: existían dos documentos llamados "Fase 5" con alcances distintos (docs/PHASE_5_ROADMAP.md vs. docs/phase_5_roadmap-3.md). Se resolvió: phase_5_roadmap-3.md conserva el nombre "Fase 5" (ya en curso/completo); el contenido de PHASE_5_ROADMAP.md (GI/sleep/hydration/HRV/movement) pasa a llamarse Fase 6 (ver abajo). Pendiente de verificar en código: PHASE_5_ROADMAP.md trata BowelEvent/HemorrhoidalEvent/SleepEntry como modelos aún no creados (ítem 5.0), pero Sprint F, Sprint G y phase_5_roadmap-3.md ya los referencian como LinkedEventType/lógica de Flare en producción — confirmar si son tipos reales ya existentes o solo placeholders antes de iniciar Fase 6.

Fase 6 — GI Tracking / Sleep / Hydration / HRV / Movement (antes "Fase 5" en docs/PHASE_5_ROADMAP.md)

⚠️ Corrección tras auditar lib/ directamente (2026-07-13): a diferencia de lo que sugerían los docs ("Planning · v1", nada construido), la mayor parte de 6.0–6.1c/6.4(scaffold)/T0.3 YA ESTÁ IMPLEMENTADA en el código. Los docs de docs/ estaban desactualizados respecto al repo — cuando haya duda sobre estado de features, el código manda sobre los docs de planning.


6.0 ✅ Modelos BowelEvent, HemorrhoidalEvent, HrvReading, MovementMetric, SleepEntry, HydrationEntry existen en models.dart, integrados en ProfileState (historiales + getXForDay + fromMap/toMap). Scaffold de motor de correlación (services/correlation_engine.dart) también shippeado: CorrelationResult, CorrelationConfidence, cold-start gating por minimumEvents/windowDays. Reglas concretas (6.4/6.9) aún no implementadas — el archivo explícitamente dice "5.0 ships the scaffold only. Concrete rules arrive in 5.4 (v1) and 5.9 (v2)".
6.1 ✅ GI logging: widgets/bowel_form_sheet.dart, widgets/hemorrhoidal_form_sheet.dart, ambos wireados en sintomas_tab.dart.
6.1b ✅ Sleep EMA: widgets/sleep_form_sheet.dart, wireado en sintomas_tab.dart, toggle settings.optionalTrackers['sleep'].
6.1c ✅ Hydration logging: widgets/hydration_form_sheet.dart, wireado en sintomas_tab.dart, toggle settings.optionalTrackers['hydration'].
6.2 Mecánica de dolor GI + banner de distensión — no confirmado en esta auditoría rápida; revisar abdominal_detail.dart / abdominal_red_flags.dart en detalle si se retoma.
6.3/6.3b/6.3c ✅ (parcial) widgets/therapy_logger_sheet.dart existe y está wireado en movimiento_tab.dart (logging de terapias). Tarjetas de contenido "Compendio" no confirmadas.
6.4 Motor de correlación v1 (reglas concretas) — pendiente, solo el scaffold (6.0) está listo.
6.5 Anti-features de movimiento (sin streaks ni metas fijas; envelope band) — no confirmado en esta auditoría.
6.6/6.7 ✅ widgets/hrv_form_sheet.dart existe, wireado, toggle settings.optionalTrackers['hrv']. No confirmado si incluye baseline personal / simulador.
6.8 Entrada manual de movimiento + envelope band + sugeridor de progresión de calistenia — no confirmado.
6.9 Motor de correlación v2 — pendiente (depende de 6.4).
6.10 Pase de revisión trauma-informado transversal + toggle "modo cuidadoso" — toggle settings.optionalTrackers['careful_mode'] ya existe y está wireado en main_screen.dart; alcance completo del pase de revisión no confirmado.


Explícitamente fuera de alcance: tracker dedicado de PTSD/C-PTSD, texto libre narrativo de trauma, biofeedback durante crisis de pánico, gamificación de movimiento, UI de BSS basada en foto en v1, push notifications en web, HRV basada en sensor (futuro solo-mobile).

Multi-Observer Profiles (diseñado, aún no es sprint activo)

Documentado en docs/multi_observer_profiles.md, referenciado desde docs/phase_5_roadmap-3.md y docs/competitive_analysis-2.md. Sitúa después de Sprint E y G en prioridad; no tiene sprint asignado todavía.


Modelo de permisos de dos capas: Owners (CRUD completo, invitar/revocar observers — ej. padres con custodia legal) vs. Observers (solo agregar, sin editar/borrar datos de otros — ej. madrina, kinesiólogo, profesora, abuela), atribuidos por nombre/rol.
Motivación clínica: el diagnóstico de zebra depende de reportes multi-observador; la fragmentación de información contribuye a los 22.1 años promedio de demora diagnóstica (Daylor 2025). Caso concreto: ahijada de Paulina con sospecha de hEDS, donde Paulina como observadora nota patrones que los padres no ven.
Decisión de modelo de negocio: el compartir multi-observador es gratis, siempre — rechazo explícito del paywall de "$8/mes perfiles familiares ilimitados" de Guava.
Bloqueador: la sincronización entre dispositivos rompe la arquitectura local-first. Tres opciones evaluadas: (A) backend cifrado opt-in, (B) sync P2P vía CRDT (ecosistema Flutter inmaduro), (C) export/import manual. Recomendación: shippear C primero como v1/proof-of-concept, diferir A/B.
Schema propuesto: Profile.owners/Profile.observers/ObserverGrant, campo recordedBy en cada modelo de evento, pairing por QR/token (no login), transferencia de ownership a los 18 años, flujo de revocación, edge cases (padres separados, observer que pasa a owner, fallecimiento del sujeto del perfil). Estimado ~2 semanas de desarrollo para v1 (Opción C).

Panel de Signos Vitales (diseñado 2026-07-16, aún no es sprint activo)

Documentado en `docs/design_decisions/vital_signs_panel.md`. Motivado por asimetría real encontrada en auditoría de código: fiebre tiene pipeline completo (valor, sitio, contexto, servicio de análisis de tendencia), HRV solo tiene valor crudo sin baseline, y presión arterial / respuesta ortostática (la señal que efectivamente diagnostica POTS) no existen en absoluto pese a que los umbrales clínicos ya están escritos en `condition_codes.json`. Arquitectura: modelos nuevos (`BloodPressureReading`, `OrthostaticTest`) separados de `FeverReading`/`HrvReading` existentes por retrocompatibilidad (datos reales de beta ya en fiebre/HRV) — unificación solo en capa de vista/servicio (`VitalSignKind` enum de presentación + servicio de agregación), no en el modelo de datos. Nombre elegido deliberadamente para no colisionar con "envelope" (ya usado para pacing de movimiento en Fase 6). Vive dentro del tab Síntomas. `OrthostaticTest` (NASA lean test simplificado a 4 tiempos: línea base + 1/3/10 min de pie) usa `Profile.dateOfBirth` para el umbral de FC ajustado por edad (≥30 lpm adultos, ≥40 adolescentes) — primer uso clínico real de ese campo desde que se agregó en Phase4.A. Pendiente explícito: el punto de seguridad de la prueba de pie (riesgo de síncope) — Paulina pidió pausarlo unos días para pensarlo con calma antes de cerrar el diseño.

Fase 4 — PDF Clinical Export (en curso)

⚠️ Estado verificado en código el 2026-07-13, no en docs (que la marcaban "queued"). Actualizado el mismo día tras corregir el aggregator y construir el renderer.


Phase4.A ✅ Completo y verificado campo por campo. models/pdf_export_config.dart (PdfSection enum de 9 secciones, PdfTimeRange, PdfExportConfig, PdfExportPreferences), models/clinical_report_data.dart (ClinicalReportData + estructuras por sección, incluye datos de emergency card para Phase4.D), services/pdf_report_aggregator.dart (aggregateClinicalReport(Profile, PdfExportConfig) → ClinicalReportData, función pura sin I/O, trunca a config.topNPerSection). El borrador original de este archivo asumía ~20 nombres de campo que no existían en models.dart/action_taken.dart/mcas.dart (ver "Bug de schema" abajo) — quedó reescrito y verificado. services/report_trends.dart (ReportTrendsService) sigue siendo un agregador de tendencias más antiguo/separado, usado por el reporte de texto plano existente (main_screen.dart _buildReportPlainText); no se tocó, queda como fallback de texto independiente del pipeline PDF.
Phase4.B ✅ Completo (primera versión). Paquete pdf: ^3.11.1 agregado a pubspec.yaml (fuentes base14/Helvetica, cobertura WinAnsi de acentos y ñ, sin necesidad de TTF custom). services/pdf_report_renderer.dart: buildClinicalReportPdf(ClinicalReportData) → PDF multi-página con las 8 secciones + nota clínica obligatoria (ver docs/PHASE_5_ROADMAP.md §5.10: "PDF export carries a clinician-note... data is patient-logged, not clinician-validated"), y buildEmergencyCardPdf(EmergencyCardData) → tarjeta compacta de una página. services/clinical_export_service.dart: ClinicalExportService.exportClinicalReport(Profile, PdfExportConfig) une aggregator + renderer + FileSaver, siguiendo el mismo patrón de descarga que ProfileIoService.exportProfile (JSON). No probado end-to-end en un browser real (sin Flutter SDK disponible en este entorno) — probar flutter run -d chrome antes de confiar en que compila y renderiza correctamente.
Phase4.C ✅ Completo (primera versión, 2026-07-13). lib/widgets/pdf_export_sheet.dart: showPdfExportSheet() — modal bottom sheet donde el usuario elige período (PdfTimeRange como chips), secciones a incluir (chips multi-select sobre PdfSection, excluyendo emergencyCard) y notas libres para el especialista; paleta de solo-contraste (cc/ic), mismo patrón visual que mcas_detail_sheet.dart. Conectado en lib/screens/main_screen.dart dentro del tab Clínica → Reporte (_buildReportContent): botón "EXPORTAR PDF PARA ESPECIALISTA" abre el sheet y llama a ClinicalExportService.exportClinicalReport; botón secundario "Tarjeta de emergencia (PDF compacto)" exporta directo con PdfExportConfig.emergencyCard() sin pasar por el sheet. Errores se muestran con SnackBar, mismo patrón que _exportActiveProfile (export JSON existente).
Phase4.D (emergency card compacta) ✅ Completo end-to-end: renderer (buildEmergencyCardPdf) + botón de exportación directa en el tab Reporte.
Phase4.F (persistencia de PdfExportPreferences en Hive) — deliberadamente diferido, documentado como tal en el propio código.

Bug de schema corregido en esta sesión (2026-07-13): pdf_report_aggregator.dart fue escrito especulando ~20 nombres de campo que nunca existieron en el código real (profile.displayName/dateOfBirth/allergies/emergencyContacts/symptomEvents/medications/doseEvents/structuralEvents/mentalEvents; SymptomEvent.symptomInput; MedicationOutcome.doseEventId/effectivenessRating/outcomeReason; MedicationDef.doseText/isActive; StructuralEvent.region; MentalEvent.states; ActionTaken.recordedAt/effectiveness/detail; el switch completo de ActionKind con 12 valores inventados; los labels de MCASReactionKind/TriggerKind/MCASRedFlag con valores de enum que no existen). Se reescribió el archivo completo verificando cada campo contra models.dart/action_taken.dart/mcas.dart. Además se agregaron tres campos aditivos legítimos a Profile que el reporte necesitaba y que no existían en ningún lado de la app: allergies: List<String>, emergencyContacts: List<String>, dateOfBirth: DateTime? (default vacío/null, sin UI de edición todavía — eso es trabajo de Phase4.C). Para MCASReactionKind/MCASOnsetWindow/TriggerKind el aggregator ahora reusa los helpers ya existentes y correctos de mcas.dart (mcasReactionKindShortLabel, mcasTriggerKindShortLabel) en vez de duplicar switches.

BUG CRÍTICO encontrado y corregido en esta sesión: lib/models/profile_settings.dart tenía el contenido duplicado por error de pdf_export_config.dart (mismas clases PdfSection/PdfExportConfig/PdfExportPreferences), lo que rompía la compilación (colisión de nombres vía pdf_report_aggregator.dart, que importa ambos archivos) y además borraba la clase real ProfileSettings (la que expone optionalTrackers, usada en 20+ sitios: sintomas_tab.dart, main_screen.dart, hoy_tab.dart, mcas.dart, action_taken_sheet.dart). Se reconstruyó profile_settings.dart con la clase ProfileSettings correcta (optionalTrackers: Map<String,bool>, toMap/fromMap), siguiendo el mismo patrón que profile_state.dart.

Lección para el proceso: dos bugs de esta sesión (profile_settings.dart y pdf_report_aggregator.dart) fueron código que nunca se verificó contra el schema real antes de marcarse "completo". Aplica el Checklist de Verificación de este archivo — "¿Métodos verificados contra código actual? (no asumir nombres)" — también a agregadores/servicios nuevos, no solo a parches sobre archivos existentes.

Hallazgo menor (no bloqueante, no corregido): lib/services/medline_plus_service.dart es una copia casi idéntica (dead code, no importado por nadie) de lib/services/vademecum_service.dart, que es el archivo realmente usado en toda la app. No causa conflicto de compilación porque no se importa, pero es candidato a limpieza.

TZP export interoperability (ver nota en Fase 5).

Reorganización de Settings (Sprint P.C, 2026-07-13)

El Drawer de ajustes era una sola función (_buildSettingsDrawer en main_screen.dart) de ~824 líneas mezclando perfil, tracking opcional, idioma y datos de cuenta en un solo scroll con separadores de texto, sin jerarquía real. Se reemplazó por un menú slim con navegación a subpantallas dedicadas en lib/screens/settings/:


ProfileSettingsScreen — nombre, fecha de nacimiento, condiciones, alergias/desencadenantes, relación, eventos de vida, ubicación, añadir/eliminar perfil.
LanguageSettingsScreen — selector de idioma, subsección propia y de primer nivel en el menú (antes vivía enterrado dentro de "Acerca de"; se sacó explícitamente porque es un ajuste que se cambia seguido, no algo que se lee una vez).
TrackingSettingsScreen — todos los toggles de settings.optionalTrackers (sleep, hidratación, HRV, headache/fatigue/abdominal detail, MCAS, seguimiento de acciones, modo cuidadoso).
AccountDataScreen — exportar/importar/borrar todo (ARCO rights).
AboutScreen — nueva, no existía antes. Nombre, tagline, descripción condensada del README, sin idioma (movido a su propia pantalla).


Patrón: cada pantalla recibe Profile por referencia + un VoidCallback onSave (== _saveData de main_screen.dart) y muta los campos directamente; acciones que dependen de helpers privados de main_screen.dart (sheets, diálogos, crear/eliminar perfil) se inyectan como callbacks en vez de duplicarse. Ver el header comment de cada archivo para el razonamiento completo.

allergies y dateOfBirth (agregados a Profile en Phase4.A, ver arriba) ya tienen UI de edición aquí — fecha de nacimiento vía showDatePicker, alergias como chips igual que conditions.

Backlog de Perfil — Contactos de Emergencia

Pendiente, explícitamente diferido por Paulina el 2026-07-13 ("puede ser algo para trabajar a futuro"): Profile.emergencyContacts (ya existe como campo aditivo desde Phase4.A, usado por EmergencyCardData en el export PDF) no tiene UI de edición todavía. Cuando se retome: mismo patrón de chips que allergies/conditions en ProfileSettingsScreen; considerar campos estructurados (nombre + relación + teléfono) en vez de texto libre por línea, ya que hoy List<String> es el formato más simple pero pierde estructura útil para la tarjeta de emergencia.


Post-Fase 6


i18n expansion — English/Chinese speakers can wait, not blocking (sirven mercados fuera de la misión LatAm central).
Portugués (Brasil), pt-BR — agregado 2026-07-13, distinto en prioridad de EN/ZH: Brasil es LatAm, así que un ARB pt-BR sirve directamente la misión central del proyecto (no es expansión a un mercado nuevo, es completar la cobertura regional). Paulina tiene una amiga que puede ayudar con la traducción del ARB. Pendiente: (1) confirmar disponibilidad/tiempos con la colaboradora, (2) crear lib/l10n/app_pt.arb (o app_pt_BR.arb si hace falta distinguir de Portugal) a partir de app_es.arb como template, (3) definir convención de registro neutro para pt-BR análoga a la de "Convenciones de Español" (evitar calcos de portugués europeo), (4) correr flutter gen-l10n y agregar pt a la lista de MaterialApp.supportedLocales y al selector de LanguageSettingsScreen. No hay trabajo de código iniciado todavía — es un ítem de roadmap, no un sprint activo. Racional de mercado (LatAm, Brasil como driver principal, LGPD) documentado en docs/business_strategy_notes.md — mayormente sin verificar, no citar externamente todavía.
Mobile deployment (~1 week config, separate track).
EDS Society outreach (after paper complete).
Reportes médicos (labs, MRI, X-Ray, etc.) — agregado 2026-07-13. Adjuntar/almacenar documentos clínicos externos (resultados de laboratorio, resonancias, radiografías) al perfil del paciente. Guava ya ofrece algo similar (competidor, ver Análisis Competitivo) — no es una feature novedosa, es una secuenciación deliberada. Pospuesto explícitamente por Paulina hasta después de tener datos de beta-testers y poder publicar la app / generar revenue — no es un sprint activo ni tiene diseño todavía. Consideraciones a resolver cuando se retome: (1) almacenamiento de archivos/imágenes es un salto de complejidad vs. el modelo actual de Hive con datos estructurados — evaluar tamaño de Hive box vs. filesystem local; (2) mantiene el principio local-first (¿o requiere backend para archivos grandes, lo cual tensiona con la arquitectura actual?); (3) posible solapamiento con el hallazgo de anemia/RDW-CV% de eds_research_notes.md (labs estructurados) — si se construye tracking de labs primero, reportes médicos como adjuntos podría ser complementario en vez de la misma feature.



Decisiones de Diseño Documentadas

Mental Tracker (Confirmado)


Patrón: Foxtale-style hybrid funnel (referencia: app de journaling de Bearable team).
Paso 1: Picker 2D (valence × arousal circumplex).
Paso 2: App muestra paleta de estados más relevante para ese quadrante (highlighted), pero usuario puede seleccionar de cualquier otra.
Paso 3: Estados cognitivos (niebla mental, disociación, irritabilidad) como chips separados.
Multi-select: Posible seleccionar múltiples paletas en paralelo.


Activity Tracker


Chips de actividad visibles incluso en días de reposo (anima a considerar movimiento).


Modo Cuidadoso


Setting que suprime todos los cards de detección de patrones (para usuarios para quienes esto genera ansiedad). Distinto de "modo crisis" (Flare Mode, Sprint G), que activa supresión de widgets opcionales y sugerencias durante un brote agudo.


Exclusiones (con rationale documentada)


Tracker dedicado de trauma → mejor en terapia + coaching.
UI de BSS basada en foto → too stigmatizing.
Gamificación de movimiento → contraproducente para EDS.
Push notifications en web → not applicable.
Medición HRV basada en sensor → deferred a fase post-mobile.
Community/social features (ver Kalpa en Análisis Competitivo) → explícitamente fuera de alcance, no es lo que ZebraUp necesita construir.


Anti-Patrones de Competencia (Rechazados Explícitamente)

De docs/competitive_analysis-2.md (15 apps + The Zebra Project analizadas):


Welltory: elimina datos históricos en tier gratuito → ZebraUp nunca elimina datos (ver Patrones Anti-Destructivos).
Flo: violaciones de práctica de privacidad (orden FTC 2021, settlement de $56M en 2025).
ClarityDTX: SKUs de paywall caóticos, discrepancia entre privacy label y marketing, conteos de reseñas no verificables — pese a reclamar action-capture similar a ZebraUp.
Bearable: parálisis de setup inicial → respuesta de ZebraUp: templates de inicio por condición.
Chronic Insights: exportación clínica rota.
Wave: pérdida de datos / crashes reportados.
Guava: paywall de perfiles familiares ($8/mes) → informa directamente la decisión de multi-observer gratis siempre.


Nicho MCAS confirmado vacante (valida la inversión de Sprint E): sin competidor serio; "MCAS Tracker" y "MCAS Insight" son productos de escala hobby/template.

The Zebra Project (TZP) — registro oficial longitudinal de EDS Society (app #16 del análisis, distinta de trackers diarios). Posición de ZebraUp: complemento, no competidor. Adoptar sus patrones de escalas clínicas estandarizadas (PHQ-9, GAD-7, FIQR, Rand-36) como opcionales periódicas, y Beighton score / criterios Villefranche 2017 como campos estructurados (futura expansión de Profile.diagnoses). Interoperabilidad de exportación hacia TZP: deferred, track de Fase 4+.

Benchmark de pricing si ZebraUp monetiza en el futuro: US$6-9/mes o ~US$35-78/año (rango Bearable-Guava), con programa de becas; gestión familiar/cuidador siempre gratis.


Research & Paper Track

Validación de Referencias


18+ referencias cross-verificadas en PubMed; DOIs corregidos (ej., Ono 2019 → 10.2196/11398).
Evitar hallucinations de NotebookLM; verificar todos los DOIs antes de incluir.


Estudios Clave Relevantes


Wang 2025 (fascial pathophysiology; framing hEDS/HSD, no clEDS-directo; "stretching contraindicated" requiere reframing; informa Movement tab / redirect de ActionKind.movement).
Ruiz-Maya 2021 (cardiac atrophy; valida Potato Day pacing clínicamente).
Daylor 2025 (24 comorbidities avg, 22.1-year diagnostic delay; JCM 14(16):5636; cifra citada en todo el diseño de Multi-Observer Profiles).
Kumskova 2023 (usar el full paper, no el abstract de 2023 — corrección: no es "2026" como se listaba antes; GPVI/integrin bleeding patterns, alimenta bruising/heavyBleeding en MCAS de Sprint E).
Coussens 2022 (JMNI 22(1):5; hEDS vs. HSD collapse; informa diseño de Profile.conditions — no forzar elección entre hEDS/HSD).
Weiler CR et al. 2019 (consenso MCAS de AAAAI — fundacional para Sprint E).
Mateo LJ et al. 2020 + Jason LA et al. 2010 (ventana PEM 24-72h — fundacional para followUpMinutes=1440 en ActionTaken y Rule 3 de Sprint G).
Palsson et al. 2012/2016, Dale et al. 2024 (simplificación BSS a 3 niveles).
Zeitoun 2013 / Fikree 2014-2017 / Nelson 2015 (fenotipo EDS-GI, fundamento de D.2 abdominal).
Plackett 2014 / Parol 2025 / Sandler 2019 (conexión tejido conectivo EDS-hemorroides).
Mi et al. 2026 (ansiedad de sueño por over-tracking).
Baugher & Coifman 2025 (Sleep-Activity Index).
Krantz et al. 2022 + Riisager et al. 2021 (principio de integración trauma-informada); Krantz 2022 + Short et al. 2022 juntos ahora también documentan el loop bidireccional arousal↔dolor (ver docs/eds_research_notes.md, candidato a regla de correlation_engine.dart).
Petrucci-Nelson et al. 2025 (GWAS; solo contexto, sin impacto directo en features).
Buryk-Iggers et al. 2022 (ejercicio en EDS; programas estructurados deben individualizarse).
Starkoff, Patrick & Lieberman 2026 (wheelchair users + mHealth; step-counters fallan para esta población; audit pendiente de movimiento_tab.dart / Fase 6).
Batch de investigación de producto/UX agregado 2026-07-13 (ver docs/eds_research_notes.md § Product & app-design research): Alzate et al. 2026 (beneficios emocionales predicen retención, no solo funcionalidad), Heiskari et al. 2026 ("autonomy frustration" — valida filosofía Anti-Tracker), Gu et al. 2023 + Lin et al. 2025 (sobrecarga de datos en HCPs — valida diseño de agregación del PDF export), Hatem et al. 2022 (⚠️ cita incompleta, no usar en público hasta verificar).
Anemia / RDW-CV% (⚠️ agregado 2026-07-13 sin cita completa — NO citar ni construir features hasta que Paulina provea autor/año/DOI; ver docs/eds_research_notes.md).


Principios de Research Grounding


Toda decisión de código + diseño documentada con cita peer-reviewed donde aplique.
Framework de brainstorming de 4 pasos: assessment relevancia → unconstrained design → feasibility → scheduled phases.



Patrones Anti-Destructivos

Eliminación de Datos Históricos

NUNCA. Local-first data persistence es el diferenciador de confianza vs. competidores (Welltory elimina datos free-tier). ZebraUp retiene todo localmente indefinidamente.

Schema Migration

Operación de mayor riesgo en roadmap. Testing obligatorio contra exports reales de beta testers antes de merge a main.

Idempotency en Patches


Sentinelas precisas: match exact widget instantiation, ej. "_OnboardingGate(child:", no solo nombre de clase.
Segunda ejecución reporta SKIP, no fallos.



Herramientas y Recursos

Docs + Referencias


Flutter Docs: https://docs.flutter.dev
Hive Docs: https://docs.hivedb.dev
ARB Spec: https://github.com/google/app-resource-bundle
Netlify: https://docs.netlify.com
PubMed E-utilities: https://www.ncbi.nlm.nih.gov/books/NBK25499/
NotebookLM (con verificación web): Para compilación de referencias


Repositorio


GitHub (private)
Branches por sprint
Releases aligned to phases


Assets


assets/condition_codes.json – códigos de condiciones
assets/ema_moods.json – paletas emocionales
assets/symptom_definitions.json – definiciones y alias de síntomas (formato de claves sufijo plano, ver Convención de Parches)
Archivos de alias de síntomas (JSON)


Documentos de Referencia en docs/


docs/PHASE_5_ROADMAP.md – plan de Fase 6 (GI/sleep/hydration/HRV/movement), no iniciado.
docs/phase_5_roadmap-3.md – tracker vivo de Fase 5 (detail layers + action capture) y dependencias de sprint.
docs/sprint_f_part_c.md, docs/sprint_f_transversal_action_taken.md – historial completo de Sprint F.
docs/sprint_e_part_c.md – historial de Sprint E (MCAS).
docs/sprint_g_part_c.md – historial de Sprint G (Flare Mode).
docs/sprint_s1_testing_checklist.md – checklist de QA manual.
docs/report_view_redesign.md – rediseño del tab Reporte (2026-07-14): contexto, decisiones discutidas antes de codear, mapa de archivos, fuera de alcance.
docs/symptom_detail_layers-2.md y docs/design_decisions/symptom_detail_laters.md – historial de detail layers (archivos duplicados, mismo contenido).
docs/multi_observer_profiles.md – diseño de perfiles multi-observador.
docs/competitive_analysis-2.md – análisis de 15 apps competidoras + The Zebra Project.
docs/eds_research_notes.md – notas de investigación clínica y sourcing del vademecum LatAm.
docs/business_strategy_notes.md – notas de mercado/monetización y racional de negocio para pt-BR (2026-07-13). Reporte fuente (Dataintelo, Rare Disease Community App Market Research Report 2034) confirmado real tras recibir el PDF, pero con señales de "report mill" (categoría de mercado no estándar, citas académicas sin autor, mismo template vendido para cualquier industria) — cifras específicas siguen sin verificar. Incluye tensión estratégica real: monetizar como RWE/B2B requiere que los datos salgan del dispositivo, lo cual tensiona con local-first.




Interacción con Claude Code

Modo de Uso Recomendado


Lectura de plan: Pide que lea archivos clave (models.dart, main_screen.dart, archivos relevantes del sprint).
Plan mode: Claude Code propone un plan como doc markdown editable. Revisa y aprueba.
Implementación: Una vez aprobado, edita código. Revisa diffs lado a lado; acepta/rechaza hunks.
Verificación: Pide que busque construcciones voseo, verifique retrocompatibilidad fromMap, aplique el anchor-drift preflight, etc. en la misma tarea.
Testing: Antes de merge, correr tests locales e informar a testers chilenos si es cambio mayor.


Comandos Útiles en Claude Code


/plan – modo plan (propone estrategia antes de editar).
/code-review – auditoría de código contra REVIEW.md (si existe).
/clear – limpia historial de chat (libera tokens para próxima tarea).
@archivo.dart#línea-rango – referencia archivo con rango específico.
/mcp – gestionar servidores MCP conectados.


Checkpoints y Rewind


Claude Code guarda snapshot antes de cada cambio.
Rewind con Esc Esc o /rewind para volver a estado anterior (código, conversación, o ambos).
Úsalo para explorar direcciones sin miedo; git es la red principal.



Principios Transversales

Trauma-Informed Design


Supresión de auto-flagelación: sin gamificación de "deuda de salud".
Validar sin patologizar: "tu cuerpo tiene necesidades reales, no fracasaste".
Modo cuidadoso: usuarios pueden suprimir cards de pattern detection si generan ansiedad (distinto de modo crisis / Flare Mode).
Copy de advisories/red flags: sin acrónimos, cierre siempre suave, humildad epistémica (ver Convenciones de Español).


Diseño Inclusivo LatAm


Neutral Spanish (nada de Castilian, chileno, o voseo), neutro en género.
APIs LatAm-first: MedlinePlus Connect, Orphadata, SNOMED CT Spanish.
Datos locales: zero envío a servidores sin consentimiento explícito.


Investigación Clínica


Paper en progreso; validación peer-reviewed es meta.
Cada feature se fundamenta en literatura; decision logs incluyen DOI.



Contacto y Escaladas

Si algo en estas instrucciones es ambiguo o necesita actualización, documenta en este archivo. Paulina verifica y actualiza regularmente.

Verificación resuelta (2026-07-13, auditoría directa de lib/): BowelEvent/HemorrhoidalEvent/SleepEntry/HrvReading/HydrationEntry/MovementMetric SÍ existen como tipos reales en producción (ver Fase 6 arriba) — los docs de planning estaban desactualizados respecto al código. T0.3 (dashboard de frecuencia de síntomas) SÍ está shippeado: widgets/symptom_frequency_dashboard.dart está wireado en sintomas_tab.dart. Regla general adoptada: ante discrepancia entre docs/ (planning) y lib/ (código), el código es la fuente de verdad — re-auditar docs/phase_5_roadmap-3.md y docs/PHASE_5_ROADMAP.md contra el código antes de confiar en su estado declarado.

Última actualización: Versión de código actual 2.3.5+1 (ciclo listo para deploy — Paulina confirmó que compila y procederá a desplegarlo como v2.3.5; falta su confirmación del deploy real para registrarlo en CHANGELOG.md § "Estado de Deploy". Último deploy real confirmado sigue siendo v2.3.4, 2026-07-17, incluye hasta D.4/weight_tracking). Panel de Signos Vitales: Presión Arterial implementada 2026-07-18 (`BloodPressureReading`, toggle `blood_pressure`, sin `OrthostaticTest` — diferido, punto de seguridad ya resuelto en conversación; ver Sesión 2026-07-18 al final de este documento), más un pase de correcciones UX/beta (nav bar, onboarding scrollable, edición de catálogo en Movimiento, hora de acostarse/despertar en Sueño con Horas/Minutos separados, bebidas personalizadas en Hidratación, opción "Promedio" en HRV, links de cuestionario de seguimiento y Bluesky en Acerca de) — misma sesión. Localización de strings hardcodeados quedó investigada pero explícitamente diferida: el alcance real es mucho mayor de lo estimado (9 archivos sin ninguna integración de l10n + gaps parciales + una segunda capa de helpers de tiempo relativo duplicados en ~8 archivos más), ver detalle en Sesión 2026-07-18. Sprint F (F.A–F.F) completo — F.F (selector MedicationType en Botiquín) shippeado 2026-07-14; el picker de medicamentos de F.B+C filtra por este campo desde el 2026-07-16 (ver Sesión 2026-07-16 más abajo). Sprint E (MCAS/Alergias, E.A–E.E) completo. Sprint G (Flare Mode, G.A/G.B/G.B.2/G.C/G.E) completo — G.D deliberadamente diferido pendiente datos de beta, G.F consolidado en G.E. Sprint S1 (QA checklist manual) en curso sobre esta superficie combinada. Symptom Detail Layers: C.4/D.1/D.2/D.3/D.4/D.5 completos (6 de 6 — cobertura completa, ver Sesión 2026-07-17 y sus continuaciones al final de este documento). Multi-observer profiles diseñado, sin sprint asignado. Fase 6 (GI/sleep/hydration/HRV/movement): modelos, formularios y toggles ya shippeados en código (6.0/6.1/6.1b/6.1c/6.6-6.7 parcial); motor de correlación es solo scaffold (6.4/6.9 pendientes). Fase 4 (PDF export): Phase4.A/B/C/D completos y confirmado que compila (flutter run -d chrome verificado por Paulina el 2026-07-13). Flujo end-to-end: tab Clínica → Reporte → "EXPORTAR PDF PARA ESPECIALISTA" abre pdf_export_sheet.dart → ClinicalExportService agrega + renderiza + descarga vía FileSaver; botón separado exporta la tarjeta de emergencia sin pasar por el sheet. Dos bugs de schema no verificado detectados y corregidos el 2026-07-13: profile_settings.dart (contenido duplicado de pdf_export_config.dart, clase ProfileSettings real perdida) y pdf_report_aggregator.dart (~20 nombres de campo inventados). Se agregaron los campos aditivos Profile.allergies/emergencyContacts/dateOfBirth. allergies y dateOfBirth ya tienen UI de edición (2026-07-13, ver Reorganización de Settings más abajo, ProfileSettingsScreen); emergencyContacts sigue sin UI — ver Backlog de Perfil. Phase4.F (persistir PdfExportPreferences en Hive) sigue diferido. Sprint P.C (2026-07-13): Settings/Perfil reorganizado en 5 subpantallas dedicadas (lib/screens/settings/) con menú slim de navegación, reemplazando el Drawer monolítico de 824 líneas; idioma es ahora su propia subsección de primer nivel; se agregó UI de edición para fecha de nacimiento y alergias en ProfileSettingsScreen. Contactos de emergencia (Profile.emergencyContacts) queda explícitamente en backlog, sin UI todavía. Beta website: agregada versión en inglés simplificada (beta_website/web/en/, captura de email vía Netlify Forms) con selector de idioma ES/EN; landing en español actualizada con secciones "Qué hay de nuevo" y "Qué no hace y por qué", voseo corregido. Roadmap: pt-BR (Portugués de Brasil) agregado a Post-Fase 6 como prioridad distinta de EN/ZH (sirve la misión LatAm central), Paulina tiene colaboradora para el ARB, sin trabajo de código iniciado. docs/eds_research_notes.md ampliado con 6 hallazgos nuevos (2026-07-13): Starkoff 2026 (wheelchair/movimiento), anemia/RDW-CV% (⚠️ sin cita, no citar/construir aún), Krantz+Short 2022 (loop arousal↔dolor), y nueva sección "Product & app-design research" (Alzate, Heiskari, Gu, Lin, Hatem ⚠️ incompleta) — ver también Estudios Clave Relevantes arriba. Roadmap Post-Fase 6: agregado ítem "Reportes médicos" (labs/MRI/X-Ray como adjuntos al perfil, precedente: Guava) — pospuesto explícitamente hasta después de datos de beta-testers + publicación/revenue, sin diseño todavía. Nuevo doc docs/business_strategy_notes.md con el racional de mercado/monetización de la sesión de NotebookLM del 2026-07-13. Actualizado el mismo día tras recibir el PDF real del reporte de Dataintelo: la cita quedó corregida (reporte real, no fabricado — el error era de NotebookLM mezclando dos empresas reales), pero el reporte muestra señales de "report mill" y sus cifras siguen sin verificar independientemente. Agregada sección de tensión estratégica: RWE/B2B requiere que los datos salgan del dispositivo, en conflicto con local-first — evaluar solo post-lanzamiento. Sesión 2026-07-14 (vía Claude Code, sin toolchain de Flutter local — cambios revisados manualmente, no compilados): (1) Botiquín — filtro de búsqueda + toggle de orden A-Z en la lista de medicamentos (botiquin_tab.dart), unidad personalizable en el form (incl. preset 'billones' para probióticos), y componentes opcionales multi-ingrediente en MedicationDef (p.ej. complejo B con dosis por vitamina) — ver MedicationComponent en models.dart. (2) Fase 3a (vademecum) — lado de condiciones completado: condition_codes.json v4 con summary_es/notes_es local-first para las 56 condiciones (reemplaza a MedlinePlus como fuente default, ya no solo el lado de medicamentos); VademecumService.getConditionContent() nuevo con cascada local→MedlinePlus; condition_info_sheet.dart reescrito para ser source-aware y localizado. Contenido flagueado content_verify:true en todas las entradas (no revisado clínicamente por Paulina); 12 entradas de alto riesgo (subtipos EDS, POTS, inestabilidad craneocervical, Chiari, médula anclada, MCAS, lipedema, disfunción plaquetaria) tienen además content_source/content_source_note citando fuentes reales verificadas vía WebSearch/WebFetch (Orphanet via mirror chorobyrzadkie.gov.pl, PMC, NIH GARD, Wikipedia) — orpha.net directo bloqueó los fetches automatizados con un bot-check. (3) Sprint F.F completado (ver arriba). (4) Reporte — datos de ánimo (MoodEntry/MoodQuadrant) ahora llegan a ambos reportes: report_trends.dart agrega moodQuadrantCounts/topMoodWords/totalMoodEntries (antes el rango multi-día los descartaba, solo el día seleccionado los mostraba), y pdf_report_aggregator.dart pobló meanValence/meanArousal en MentalStateSection (existían en el modelo pero siempre eran null). Se agregó detección de patrones cruzados entre síntomas (symptom_pattern_detector.dart, compartido entre PDF y reporte in-app) — Paulina pidió esto como "análisis de interés" tras notar en un PDF que el dolor de pecho se concentraba en las tardes durante un período con amigdalitis. Bug corregido en pdf_report_renderer.dart: ⚠ y ≥ no están en el rango WinAnsi que soporta la fuente base14 Helvetica del PDF y se veían como un bloque; reemplazados por "(!)" y texto. (5) Rediseño completo del tab Reporte in-app (lib/widgets/report_view.dart, nuevo) — discutido con Paulina antes de codear (pidió explícitamente "before coding anything, let's discuss it" tras ver su propio reporte de 30 días ilegible: 18 síntomas y 25 medicamentos en listas planas sin jerarquía). Decisiones tomadas vía preguntas directas: (a) widgets estructurados reales en vez de reformatear texto, (b) toggles de colapso por sesión Y toggles persistentes en Ajustes (report_show_mood/mental/structural en optionalTrackers). Reutiliza CollapsibleSection (ya existía para esto en Síntomas tab) — Resumen siempre visible + una CollapsibleSection por dominio, Fiebre y Patrones expandidos por defecto (únicas excepciones), resto colapsado, listas largas truncadas a 8 con "ver más" (espejando topNPerSection del PDF). _buildReportPlainText() queda intacto, sigue siendo el texto de "Copiar al portapapeles". De paso se corrigió el bug de patrones duplicados que el reporte real de Paulina expuso (dolor pecho aparecía dos veces diciendo esencialmente lo mismo). Detalle completo, contexto y qué quedó fuera de alcance: ver docs/report_view_redesign.md. Sin toolchain de Flutter — todo revisado manualmente (balance de llaves/paréntesis, nombres de campo contra los modelos reales), no compilado; pendiente verificar con flutter run.

Sesión 2026-07-15 (continuación, mismo Claude Code, aún sin toolchain de Flutter — nota aparte: este párrafo de "Última actualización" ya es enorme; considerar partirlo en entradas fechadas separadas en una futura limpieza de este archivo). Paulina reportó que el tab Reporte quedó completamente vacío tras el rediseño de ayer, y que el bug del carácter roto en el PDF seguía presente. (1) Bug real encontrado y corregido: report_view.dart usaba una variable booleana intermedia (`hasTrends = trends != null && !trends.isEmpty`) y luego accedía a `trends.xxx` sin `!` — Dart no promueve un nullable a través de una variable derivada, solo a través de un chequeo directo (`if (trends != null)`) en el mismo scope, así que esa sección probablemente no compilaba. Corregido usando `if (trends != null && !trends.isEmpty) ...[ ... trends.xxx ... ]` directamente, que sí permite la promoción. (2) El arreglo del carácter del PDF de ayer (⚠/≥) solo cubría esos dos símbolos estáticos; el problema real es que cualquier texto ingresado por la usuaria (nombres de medicamentos, notas) puede tener caracteres fuera de WinAnsi — ej. el emoji en "paltomiel 🥑" del propio botiquín de Paulina. Se agregó un filtro general `_pdfSafe()` en pdf_report_renderer.dart aplicado a *todo* el texto dinámico (vía `_cell`/`_kv` más los sitios que llaman `pw.Text` directo: patrones, red flags MCAS y tarjeta de emergencia, línea de eventos estructurales, notas para el especialista) — caracteres no soportados se omiten en vez de mostrarse como bloque roto. (3) Paulina calificó el rediseño de ayer como "no es bueno" y pidió gráficos reales, articulando un principio nuevo: el reporte in-app debe ser donde la paciente ve sus propios datos de forma rica *antes* de decidir compartirlos — el PDF es la versión clínica/exportable, no el lugar donde debería verse mejor por primera vez. Se discutió antes de codear (de nuevo, a pedido explícito): se aprobó agregar `fl_chart` (versión sin verificar contra pub.dev — sin toolchain; correr `flutter pub get` o `flutter pub add fl_chart` para resolver la versión real) y se priorizaron 3 gráficos: severidad de síntomas en el tiempo, frecuencia de síntomas, ánimo en el tiempo (efectividad de medicamentos quedó fuera de este pase). Nuevo: lib/services/report_time_series.dart (serie día-a-día — ReportTrends solo tiene agregados de período, no sirve para gráficos de línea; datos faltantes son huecos reales, no ceros) y lib/widgets/report_charts.dart (aísla la dependencia de fl_chart en un solo archivo: SeverityOverTimeChart, FrequencyBarChart, MoodOverTimeChart). Refactor menor: la lógica de valence/arousal sign que vivía privada en pdf_report_aggregator.dart se promovió a MoodQuadrant.valenceSign/.arousalSign en models.dart (fuente única, ahora compartida por el PDF y el nuevo servicio de series). Disciplina de color: sin hues nuevos — el gráfico de severidad (hasta 3 líneas) se diferencia por patrón de guiones + alpha sobre el mismo contrastColor, no color; decisión de Claude, marcada explícitamente para que Paulina la cuestione si no le sirve. Los gráficos se integraron dentro de las CollapsibleSection ya existentes (Síntomas, Estado mental y ánimo) — sin toggle nuevo, heredan el show/hide ya construido ayer. Detalle completo en docs/report_view_redesign.md (actualizado). Otra vez: sin toolchain de Flutter, todo revisado manualmente, no compilado — y esta vez con una capa extra de incertidumbre (la API exacta de fl_chart no se verificó contra documentación en vivo). Antes de confiar en esto: flutter pub get, flutter analyze, flutter run.

Sesión 2026-07-15, continuación (nueva entrada separada en vez de seguir extendiendo el párrafo de arriba, que ya era excesivo). Paulina corrió `flutter analyze` de verdad y encontró 2 errores de compilación reales — la primera vez esta sesión que se verifica contra un compilador real en vez de solo revisión manual. (1) `BarTouchData` no es const-construible en la versión de fl_chart que resolvió pub (0.69.2) — se sacó `const` de ese call site en report_charts.dart, y proactivamente de FlDotData/AxisTitles/LineTouchData también (sacar `const` nunca es un error, así que es la corrección defensiva más segura sin esperar a que cada uno falle por separado). (2) `MoodQuadrant.valenceSign` reportado como no definido pese a que el getter existe correctamente en models.dart (verificado línea por línea, sin error de sintaxis) — diagnosticado como caché de build incremental desactualizado, no un bug real de código; se recomendó `flutter clean && flutter pub get && flutter run` en vez de seguir parchando contra un build potencialmente viejo. Por separado, Paulina señaló un gap real de producto: con 1 o 7 días seleccionados el reporte casi no mostraba nada (el umbral `rangeDayCount > 1` dejaba trends en null para 1 día; 7 días sí computaba trends pero con tan pocos puntos los gráficos no dicen nada — cita textual: "mostrar tendencias de tan pocos días no es significativo"), pero igual quería un resumen más completo que hoy_tab para rangos cortos. Rediseñado con un nuevo umbral `isShortRange = rangeDayCount <= 7`: rangos cortos ahora usan `_PeriodLog` (nueva clase en report_view.dart) — registro día por día con síntomas/dosis/fiebre/mental/ánimo/estructurales, sin gráficos ni agregación, esencialmente lo que _buildReportPlainText ya hacía para un solo día pero generalizado a hasta 7; rangos largos (>7 días) mantienen el resumen+gráficos de ayer sin cambios. Efectividad de medicamentos se sacó del bloque condicionado a trends (es histórica, no por período) y ahora se muestra en ambos modos. Blog (blog.html/en/blog.html) y docs/report_view_redesign.md actualizados con una nueva entrada fechada 15 de julio y un segundo addendum respectivamente, documentando ambas rondas de arreglos y el rediseño de rangos cortos. Conversación aparte (sin cambios de código, explícitamente pospuesta a pedido de Paulina): gestión de dependencias — pub.dev muestra 18 paquetes con versiones más nuevas disponibles fuera de los constraints actuales de pubspec.yaml; se le explicó la diferencia entre `flutter pub upgrade` (seguro, respeta constraints) y `flutter pub upgrade --major-versions` (puede romper APIs, probar de a un paquete), con nota específica de que fl_chart en particular (recién agregado, contra 0.69.x) no debería subirse a 1.2.0 sin revisar report_charts.dart de nuevo dado el salto de versión mayor. Sigue sin toolchain de Flutter para nada de esto excepto lo que Paulina corrió y reportó ella misma — ver docs/report_view_redesign.md Addendum 2 para el detalle completo.

Sesión 2026-07-16: Paulina reportó que el "—" (guion largo) seguía mostrándose como un bloque roto en el PDF. Causa raíz encontrada: el fix anterior (Addendum, primera entrada) asumía que la fuente base14 Helvetica del paquete `pdf` soporta el rango WinAnsi/cp1252 completo, incluyendo el bloque de tipografía 0x80-0x9F (guion largo/corto, comillas tipográficas, viñeta, elipsis, trademark) — en la práctica solo soporta Latin-1 plano (ASCII + letras latinas acentuadas), que es literalmente lo que el comentario original del archivo ya decía antes de que se extendiera esa suposición por error. `_pdfSafe()` en pdf_report_renderer.dart ahora traduce esos caracteres a ASCII plano en vez de dejarlos pasar (guion largo/corto → "-", comillas tipográficas → comillas rectas, viñeta → "-", elipsis → "...", trademark → "(TM)"). También se corrigieron los literales estáticos que nunca pasaban por `_pdfSafe()`: el título del reporte, la tarjeta de emergencia, las líneas de señales de alerta MCAS, la viñeta de patrones detectados, y — muy probablemente lo que Paulina vio en la práctica — `_cell(m.doseText ?? '—')`, el texto de respaldo en la columna Dosis para cualquier medicamento sin concentración/unidad definida (común en suplementos). Detalle completo en docs/report_view_redesign.md Addendum 3, incluyendo la lección explícita de no seguir parchando síntoma por síntoma sin encontrar la causa raíz. Sin verificar contra un compilador — mismo caveat de siempre.

Sesión 2026-07-16 (continuación, entrada separada por acuerdo explícito de mantener el párrafo de "Última actualización" en entradas fechadas en vez de seguir un solo bloque corrido — ver nota del 15-jul arriba): conversación de diseño puro, sin tocar código, sobre dos frentes nuevos. (1) Rediseño de dolor estructural — cerrado en `docs/design_decisions/symptom_detail_laters.md` §12: capa de detalle nueva de 18 chips en 4 grupos (Lateralidad, Carácter del dolor, Antecedente, Mecánica), aplicando a 6 de las 7 categorías de `kStructuralTaxonomy` existentes (joint/muscle/tendon/ligament/nerve + nuevo 7º kind "dolor sin causa estructural clara", que reemplaza el término informal de Paulina "dolor del síndrome" por humildad epistémica). Incluye "antecedente estructural conocido" (§12.6): historial por zona a nivel Profile para casos como cirugías previas (ej. rodilla de Paulina), con atajo que salta la funnel completa y va directo a severidad. Tejido blando (heridas/hematomas) quedó explícitamente fuera de este cierre — no por ser trivial, sino como su propio hilo de diseño (§12.6b) motivado por la conexión hematomas↔anemia. Verificación de citas real hecha en esta sesión: de 20 referencias en un reporte de Perplexity que trajo Paulina, solo 2 eran literatura primaria verificable — De Paepe & Malfait 2004 (BJH 127(5):491-500, DOI 10.1111/j.1365-2141.2004.05220.x) y Kumskova et al. 2023 (ya citado en este archivo para MCAS; Paulina aportó el PDF completo, corrigiendo una primera lectura mía que subestimaba severidad — datos reales: 13% hematomas musculares espontáneos, 16% sangrado cutáneo severo, 14% menorragia life-threatening, 32% de menorragia moderada requirió terapia hormonal o de hierro). La conexión específica hematomas→anemia/RDW-CV% sigue sin cita EDS-directa (búsqueda en PubMed sin resultados) — el candado ya existente en este archivo se mantiene. Paulina propuso adaptar el ISTH-BAT (International Society of Thrombosis and Haemostasis bleeding assessment tool, el instrumento validado que usa el propio paper de Kumskova) para tejido blando: como escala periódica completa (mismo patrón que PHQ-9/GAD-7 de TZP, ver Fase 5/phase_5_roadmap-3.md) y/o como fuente de las categorías de severidad por evento (ej. hematoma muscular: "posttrauma sin terapia" vs "espontáneo sin terapia" — reemplaza una escala 0-4 genérica por una ya validada clínicamente). (2) Panel de Signos Vitales — nuevo, documentado en `docs/design_decisions/vital_signs_panel.md`: unifica fiebre (ya completa), HRV (confirmado sin baseline, tal como CLAUDE.md ya sospechaba), presión arterial (nueva, greenfield) y respuesta ortostática/POTS (nueva, greenfield — D.3 Presíncope sigue vacío en el backlog). Arquitectura: modelos separados por retrocompatibilidad (no se toca el schema de FeverReading/HrvReading, que ya tienen datos de beta), unificación solo en capa de vista/servicio. Nombre elegido para evitar colisión con "envelope" (ya usado para pacing de movimiento en Fase 6/PHASE_5_ROADMAP.md). Vive dentro del tab Síntomas junto a las demás capas de detalle. La prueba ortostática (NASA lean test simplificado a 4 tiempos) quedó pausada a pedido explícito de Paulina — quiere pensarla con calma unos días, especialmente el punto de seguridad de riesgo de síncope durante la prueba de pie. Grounding cualitativo adicional en símbolo de encuesta general SED (2 respuestas, no específica de ZebraUp, anonimizadas): valida tanto la apuesta de correlación cruzada de síntomas como el caso de uso del PDF export (una encuestada ya arma "cartas" con IA para sus consultas porque olvida todo en el momento) — detalle en `symptom_detail_laters.md` §12.7. Nota de proceso: durante esta sesión se detectó y corrigió un bug propio (no de la app) — una edición anterior en el mismo doc había duplicado la sección §12.7 por error de edición, ya reparado.

Sesión 2026-07-16 (tercera continuación — implementación del rediseño de dolor estructural diseñado en la sesión anterior, más tres arreglos chicos previos). Vía Claude Code, sin toolchain de Flutter local — todo revisado manualmente (nombres de campos contra los modelos reales, balance de llaves/paréntesis, JSON/ARB validados con `python3 -c "import json"`), no compilado; pendiente `flutter analyze`/`flutter run -d chrome` antes de confiar en que compila. (1) Consolidación de RedFlagSeverity (ver arriba, sección de deuda técnica) — nuevo `lib/models/red_flag_severity.dart`, los tres servicios de red flags actualizados, rename de `_showAdvisoryFlags` a `_showHeadacheAdvisoryFlags`. (2) Filtro por MedicationType en el picker de F.B+C (ver Sprint F.F arriba) — `action_taken_sheet.dart` ahora excluye `basalScheduled`. (3) El toggle A-Z de Botiquín (botiquin_tab.dart) dejó de resetearse al cambiar de pestaña — ya no vive en `State` local, se persiste en `profile.settings.optionalTrackers['botiquin_sort_alpha']` vía el mismo callback `onProfileChanged` que usan los toggles de Ajustes, así que también sobrevive a reinicios de la app, no solo a cambios de tab. (4) Rediseño de dolor estructural (§12) implementado completo en el mismo pase acordado con Paulina — no solo el embudo de 4 grupos y el 7º kind, también el historial de zona (§12.6), todo junto porque están diseñados como un flujo interdependiente. Archivos nuevos: `lib/models/structural_detail.dart` (StructuralDetail + 4 enums single-select + StructuralComparisonToUsual), `lib/services/structural_detail_format.dart` (resumen compacto para el timeline), `lib/widgets/structural_detail_sheet.dart` (el embudo, con botón "Ya sé qué es" que devuelve un resultado tri-estado — skip/classicPicker/save — para que el caller decida si abrir el picker clásico), `lib/widgets/structural_quick_log_sheet.dart` (severidad + "¿distinto a lo usual?" para zonas con historial), `lib/widgets/structural_zone_history_form_sheet.dart` (calcado de life_event_form_sheet.dart). Modelos: `StructuralEventKind.painWithoutClearCause` (7º valor) + su entrada en `kStructuralTaxonomy` (`unclear_structural_cause`, único tipo bajo ese kind); `StructuralEvent` ganó 3 campos aditivos (`structuralDetail`, `severity` reusando `SymptomSeverity`, `comparedToUsual`); nueva clase `StructuralZoneHistoryEntry` + `Profile.structuralZoneHistory`. Un segundo tipo sintético, `known_condition_flare`, se usa solo para eventos del quick-log de historial conocido (no vive en `kStructuralTaxonomy`, nunca aparece en el picker clásico, solo se sintetiza programáticamente) — evita que el timeline muestre "sin causa clara" para una condición que sí es conocida. Wiring en `sintomas_tab.dart`: el tap de zona entra por `_openStructuralEntry` (rutea a quick-log si hay historial guardado, si no al embudo), el ícono ⚠️ uniforme del timeline "Registros de hoy" (el problema motivador original de §12.1) se reemplazó por `_iconForKind(e.kind)` — mismo ícono que ya usaba el picker de creación —, y se agregó la oferta post-funnel "guardar esto como algo que ya conoces" cuando el antecedente marcado es "condición conocida" y la zona no tiene historial todavía. Gestión del historial de zona (agregar/editar/eliminar) en `ProfileSettingsScreen` + `main_screen.dart`, calcada literalmente de la sección de `lifeEvents` (mismo patrón de callbacks inyectados `onAddX`/`onEditX`). Contenido nuevo en `assets/symptom_definitions.json` bajo la clave `"structural"` (18 chips en 4 grupos, mismo mecanismo `label_es/def_es` que cefalea/fatiga/abdomen — sin cambios al servicio) y ~24 claves ARB nuevas en los 4 locales (es/en/zh/zh_TW), incluyendo los `app_localizations*.dart` generados a mano ante la ausencia de `flutter gen-l10n` en este entorno (se confirmó que `app_localizations_zh_TW.dart` es un archivo huérfano no importado por nadie — la clase real `AppLocalizationsZhTw` vive dentro de `app_localizations_zh.dart` y hereda de `AppLocalizationsZh`, así que las claves nuevas solo se agregaron ahí). Fuera de alcance en este pase, sin cambios (ver §12.8): tejido blando, red flags estructurales, mapeo HPO. Decisión de producto confirmada con Paulina antes de codear (vía preguntas directas, resolviendo una contradicción real entre §12.6 y el resumen de §12.8 del propio doc de diseño): el embudo reemplaza el picker de tipos para zonas nuevas en vez de correr antes/después de él; sin toggle de Ajustes para desactivar el embudo (a diferencia de cefalea/fatiga/abdomen, reemplaza el flujo existente en vez de ser un add-on opcional). Blogs (blog.html/en/blog.html) actualizados con una entrada nueva fechada 16 de julio cubriendo lo user-facing de esta sesión (embudo de dolor, ícono del timeline, historial de zona, filtro del picker de medicamentos, persistencia del A-Z) — sin mencionar RedFlagSeverity, que es refactor puramente interno.

Sesión 2026-07-16 (vía Claude Code, sin toolchain de Flutter local — todo revisado manualmente, JSON/ARB validados con `python3 -c "import json"`, balance de llaves/paréntesis contado por archivo; pendiente `flutter analyze`/`flutter run -d chrome`). Paulina rechazó explícitamente el embudo de 4 grupos shippeado el día anterior: "no me gusta la nueva versión de la zona estructuralista". Su pedido, en sus palabras: tocar "dolor muscular" en el baúl debe preguntar la zona + los 4 chips; escribir "dolor pierna" debe preguntar el tipo (muscular/articular/tejido blando...). Es decir, zona y tipo dejan de ser caminos excluyentes (embudo de 4 grupos vs. "Ya sé qué es") y pasan a ser dos entradas simétricas al mismo resultado. Confirmado con Paulina antes de codear (vía AskUserQuestion + plan mode, no se asumió el diseño): (1) "Ya sé qué es" — el picker clínico específico (subluxación, esguince leve, etc.) — se mantiene intacto como atajo aparte, no se fusiona con el flujo nuevo; (2) tocar un chip de zona también cambia de comportamiento, no solo el baúl — ambos caminos convergen en el mismo sheet combinado.

Implementado: (1) Modelo — 5 tipos placeholder genéricos nuevos en `kStructuralTaxonomy` (uno por kind sin tipo genérico previo: `muscle_pain_general`, `tendon_pain_general`, `ligament_pain_general`, `soft_tissue_pain_general`, `nerve_pain_general`, mismo patrón que el `joint_pain` ya existente) + nuevo `kGenericStructuralTypeForKind` (models.dart) — sin cambios a `_migrateStructuralTypeId`/`inferKindFromType`, ambos ya pasan cualquier ID presente en la taxonomía sin tocarlo. (2) Detector de texto libre nuevo, `lib/services/structural_text_detector.dart` — listas de palabras clave en español neutro LatAm (mismo patrón que `_isMCASSymptom`), NO basado en `detectAliasVariant()` (hard-gateado a `abdominal_pain`, no reusable) ni en `assets/symptom_definitions.json` (las labels de zona/tipo ya viven en ARB, meter un segundo source of truth ahí hubiera sido confuso). Excluye a propósito `chest`/`side`/`ribs`/`abdomen` (se solapan con vocabulario GI ya gateado a `abdominal_pain`) y `temple` (cefalea tensional) del auto-match — siguen accesibles por tap manual o por el paso de zona del sheet. Bug propio encontrado y corregido en esta misma sesión: "pierna"/"espalda" sueltas no resuelven a una zona específica (son ambiguas entre 5-6 zonas cada una) pero tampoco resolvían ningún tipo, así que `dolor pierna` caía silenciosamente al menú genérico en vez de abrir el sheet — contradecía el propio ejemplo de Paulina. Corregido con un flag `hasAmbiguousZoneSignal` que abre igual el sheet (empezando por el paso de zona) sin forzar una zona inválida. (3) `lib/widgets/structural_detail_sheet.dart` reescrito como máquina de 3 pasos (zona → tipo → los 4 grupos existentes), saltando cualquier paso ya resuelto por un tap de zona o por el detector; nueva `StructuralDetailSheetResult` con `zone`/`kind`; el auto-downgrade de Guardar a Skip cuando los 4 grupos quedaban vacíos se eliminó (con zona+tipo siempre presentes, un detalle vacío ya es un resultado legítimo, no "no pasó nada"). Grilla de zonas extraída a `lib/widgets/body_zone_picker_grid.dart` (antes vivía inline en `sintomas_tab.dart`), reusada tanto por la sección "Zonas estructurales" como por el paso de zona del sheet nuevo. (4) `sintomas_tab.dart`: `_openStructuralFunnel` ahora acepta `initialKind`; lógica de guardado extraída a `_handleStructuralSheetResult` (compartida por el camino zona-primero y el camino del baúl); nuevo `_dispatchSymptomInput` — dispatcher central que chequea headache/fatigue/abdominal_pain (alias JSON) y MCAS (heurística de keywords) ANTES del detector estructural, en ese orden exacto, para que "dolor de cabeza"/"dolor de guata" sigan sus flujos existentes sin tocar — verificado a mano contra las listas de alias reales de `assets/symptom_definitions.json`. Los tres call sites que antes llamaban `_openSeverityMenu(s)` directo (chip del baúl, chip de "Tendencias", `_addSymptomToVault`) ahora pasan por este dispatcher — incluye tendencias por consistencia (mismo espacio de strings que el baúl, no debería comportarse distinto según de qué sección salió el tap). (5) 9 claves ARB nuevas (`structuralZonePickTitle/Subtitle`, `structuralKindPickTitle/Subtitle`, `structType{Muscle,Tendon,Ligament,SoftTissue,Nerve}General`) en es/en/zh + getters a mano en `app_localizations.dart`/`_es`/`_en`/`_zh` (ambas clases, `AppLocalizationsZh` y `AppLocalizationsZhTw`, siguiendo la lección ya establecida de que la clase zh_TW real vive dentro de `app_localizations_zh.dart`); `app_localizations_zh_TW.dart`/`app_zh_TW.arb` no se tocaron (huérfanos, confirmado en la sesión anterior).

Proceso: se usó plan mode explícitamente antes de tocar código (EnterPlanMode → 1 agente Explore + 1 agente Plan + revisión manual de archivos críticos → ExitPlanMode con plan aprobado) dado que era un rework de una feature shippeada el día anterior, no una feature nueva — mismo patrón que Paulina ya había pedido en sesiones previas ("before coding anything, let's discuss it").

Sesión 2026-07-16 (cuarta continuación, dos bugs chicos reportados por Paulina — vía Claude Code, sin toolchain de Flutter local, todo revisado manualmente, JSON/ARB validados con `python3 -c "import json"`; pendiente `flutter analyze`/`flutter run -d chrome`). (1) Historial de zona estructural forzaba todo evento nuevo al `kind` original guardado (ej. cirugía de rodilla), sin forma de registrar un problema nuevo/distinto en la misma zona. `lib/widgets/structural_quick_log_sheet.dart`: `StructuralQuickLogResult` ganó un campo `isNewIssue` (bool) y `severity` pasó a nullable; se agregó un link "¿Es un problema nuevo o distinto? Descríbelo aparte" sobre el picker de severidad que retorna `isNewIssue: true` sin severidad. `sintomas_tab.dart` (`_openStructuralQuickLog`): si `result.isNewIssue`, ya no arma el `StructuralEvent` con `kind: history.kind` — en vez de eso llama a `_openStructuralFunnel(zone)`, el mismo flujo de zona+tipo+4 grupos que usan las zonas sin historial, dejando que el usuario elija un tipo real en vez de heredar el antecedente guardado. "¿Distinto a lo usual?" (`StructuralComparisonToUsual`, severidad relativa) no se tocó — sigue siendo un comparador de intensidad, no de tipo; son dos preguntas distintas ahora coexistiendo en el mismo sheet. (2) `Profile` solo tenía un campo `name`, usado tanto en la UI (saludo, selector de perfiles, diálogos) como en el PDF/tarjeta de emergencia para el especialista — sin forma de que el nombre visual difiera del nombre legal. Se agregó `Profile.preferredName` (String, additivo, default `''`) + getter `Profile.displayName` (`preferredName` si no está vacío, si no `name`) en `models.dart`, con soporte en constructor/`toMap`/`fromMap`. `profile_settings_screen.dart` gana un segundo campo "NOMBRE PREFERIDO (OPCIONAL)" junto al de "NOMBRE DEL PACIENTE" (ahora con texto de ayuda aclarando que este último es el nombre legal completo usado en el PDF). Los cuatro sitios de UI puramente visual en `main_screen.dart` (diálogo de importación ×2, selector de perfiles, diálogo de eliminar perfil) pasaron a leer `profile.displayName`; `pdf_report_aggregator.dart`, `clinical_export_service.dart`, `profile_io_service.dart` y el texto plano del reporte (`_buildReportPlainText`, "PACIENTE: ...") siguen leyendo `profile.name` sin cambios, a propósito — son salidas clínicas/de exportación. 9 claves ARB nuevas (`structuralQuickLogNewIssueLink`, `settingsPatientNameHelper`, `settingsPreferredNameLabel`, `settingsPreferredNameHelper`) en es/en/zh + getters a mano en `app_localizations.dart`/`_es`/`_en`/`_zh` (ambas clases zh), mismo patrón de las sesiones anteriores.

Sesión 2026-07-16 (quinta continuación) — tejido blando implementado (§12.6b de `docs/design_decisions/symptom_detail_layers.md`, hilo diferido en el rediseño de dolor estructural; nota: el nombre correcto del archivo es `symptom_detail_layers.md`, no `symptom_detail_laters.md` como quedó escrito por error en entradas anteriores de este documento — mismo contenido, solo el nombre del archivo está mal tipeado arriba). Vía Claude Code, plan mode explícito (EnterPlanMode → lectura directa de código, sin subagentes por preferencia de Paulina → ExitPlanMode con plan aprobado), sin toolchain de Flutter local — JSON/ARB validados con `python3 -c "import json"`, balance de llaves de cada archivo Dart tocado contado por script; pendiente `flutter analyze`/`flutter run -d chrome`. Decisiones confirmadas con Paulina antes de codear: severidad ISTH-BAT **por evento** (no escala periódica completa), y sin mencionar anemia/RDW-CV% en ningún copy — consistente con el framing real del doc (disfunción plaquetaria, Artoni 2018, es el hallazgo medible; anemia nunca aparece en el copy candidato de §12.6b).

Implementado: (1) `lib/models/structural_detail.dart` — dos enums nuevos, `BleedingOnset` (espontáneo/trauma) y `BleedingSeverity` (5 valores, ISTH-BAT 0-4 adaptado a copy llano: no fue nada / lo noté sin consultar / consulté sin tratamiento / recibí tratamiento / grave-urgencia-transfusión-cirugía), más `StructuralBleedingDetail` (mismo shape que `StructuralDetail`: nullable, `isEmpty`/`copyWith`/`toMap`/`fromMap`). (2) `StructuralEvent` (models.dart) gana el campo aditivo `bleedingDetail` (mismo patrón que `structuralDetail`/`severity`/`comparedToUsual`), poblado solo para `kind == softTissue` con `type != 'burn'` (quemaduras no son sangrado). (3) `assets/symptom_definitions.json` bajo `"structural"."groups"` — dos grupos nuevos, `bleeding_onset` (2 chips) y `bleeding_severity` (5 chips), mismo mecanismo `label_es/en/zh` + `def_es/en/zh` que los 4 grupos existentes. (4) `lib/widgets/structural_detail_sheet.dart` — el paso de grupos del embudo zona+tipo ahora bifurca por `kind`: softTissue muestra Origen+Gravedad en vez de los 4 grupos de dolor (lateralidad/carácter/antecedente/mecánica no describen bien un hematoma). (5) Bug real cerrado de paso: el picker clásico ("Ya sé qué es") nunca pedía severidad para tipos de tejido blando (hematoma, contusión, cortes) — guardaba el `StructuralEvent` directo. Ahora, para softTissue no-burn, `_openStructuralMenu` (sintomas_tab.dart) cierra el picker y abre un sheet nuevo y pequeño, `lib/widgets/structural_bleeding_sheet.dart` (calcado de `structural_quick_log_sheet.dart`), antes de guardar. (6) Refactor de reuso: el chip con ícono ⓘ reactivo (patrón confirmado en §12.3) vivía como `_StructuralChip`, privado a `structural_detail_sheet.dart`, con un comentario explícito diciendo "duplicar es aceptable hasta que un 5º síntoma lo necesite" — como el segundo uso es dentro del mismo síntoma (structural), se extrajo a `lib/widgets/structural_chip.dart` (clase pública `StructuralChip`) y ambos sheets lo comparten, en vez de duplicar una variante con long-press (que no es el patrón decidido). (7) `formatStructuralBleedingDetailCompact` nuevo en `structural_detail_format.dart`, cableado en `_structuralCompactSummary` (sintomas_tab.dart) antes de las ramas de `structuralDetail`/quick-log, para que "Registros de hoy" muestre el resumen de sangrado. (8) 4 claves ARB nuevas (`structuralBleedingSheetTitle/Subtitle`, `structuralBleedingLogTitle/Subtitle`) en es/en/zh + getters a mano en `app_localizations.dart`/`_es`/`_en`/`_zh` (ambas clases zh), mismo patrón de sesiones anteriores.

Fuera de alcance, explícitamente (confirmado con Paulina, ver §12.8 del doc de diseño): red flags de tejido blando (incluye el tier de riesgo vEDS por ruptura arterial, anotado como alta prioridad pero diferido), el advisory de "tendencia de hematomas" (depende de que esta capa de captura exista primero — ahora existe, el advisory sigue sin construirse), cambios al historial de zona/quick-log (§12.6, sigue usando `SymptomSeverity` genérico), y edición post-guardado de `bleedingDetail` (mismo límite ya existente para `structuralDetail`/`severity`).

Sesión 2026-07-17 — D.3 (Presíncope) implementado, cuarta Symptom Detail Layer (4 de 6). Vía Claude Code, plan mode explícito (EnterPlanMode → 3 agentes Explore en paralelo para verificar patrones reales de abdominal/headache/settings/l10n antes de escribir el plan final → ExitPlanMode con plan aprobado), sin toolchain de Flutter local — JSON/ARB validados con `python3 -c "import json"`, balance de llaves/paréntesis contado por script; pendiente `flutter analyze`/`flutter run -d chrome`.

Corrección de proceso, antes de implementar: el plan de partida (aparentemente redactado en una sesión previa sin verificar contra este código) traía dos afirmaciones falsas. (1) Una "Fase 0" completa asumiendo que este directorio es una copia local de Mac desincronizada de una copia real en Codespaces, faltante el trabajo de tejido blando de la "Sesión 2026-07-16" de arriba — falso: se verificó leyendo el código directamente (`structural_bleeding_sheet.dart`, `StructuralBleedingDetail`, campo `bleedingDetail`, grupos `bleeding_onset`/`bleeding_severity`, las 4 claves ARB — todo presente, coincide con el commit `f440a47`). Esta sesión SÍ corre en el mismo entorno que edita este archivo, así que la premisa de "dos copias" no aplicaba. Fase 0 se eliminó del plan sin ejecutar ninguna de sus acciones. (2) El plan asumía que `_StructuralChip` fue duplicado citando un comentario "anticipa que un 5º síntoma lo necesite" — verificado que ese comentario no existe en ningún archivo del repo (el comentario real de `structural_chip.dart` habla de un "segundo host", `structural_bleeding_sheet.dart`, no de un futuro 5º síntoma). Se mantuvo de todos modos la duplicación privada del chip para presíncope (`_PresyncopeChip` en `presyncope_detail_sheet.dart`) porque es el patrón real observado en headache/abdominal (cada capa tiene su propia implementación privada; `StructuralChip` solo se comparte entre los dos sheets propios de structural, no entre síntomas distintos).

Implementado: `assets/symptom_definitions.json` — nueva clave `"presyncope"` (aliases + master + 4 grupos, 19 chips: `mechanism` 7/single, `prodrome` 6/multi, `outcome` 3/single, `recovery` 3/single). `lib/models/presyncope_detail.dart` nuevo (4 enums + `PresyncopeDetail`, mismo patrón exacto que `abdominal_detail.dart`: `serializationKey`/`fromKey`, `copyWith` con flags `clearX` solo en campos nullable simples, `toMap`/`fromMap` con mapa disperso). `SymptomEvent.presyncopeDetail` agregado como 5º sibling de headache/fatigue/abdominal/mcas en `models.dart` (mismos 4 puntos de contacto: campo, constructor, copyWith, toMap/fromMap con el patrón `xRaw is Map`). `lib/services/presyncope_red_flags.dart` nuevo — reusa `RedFlagSeverity` existente (no crea un cuarto enum de severidad duplicado), 1 URGENT (`briefLossOfConsciousness`, manejado in-sheet con diálogo bloqueante tipo D.2 "desgarro") + 2 ADVISORY (`exertionalTrigger`, `noPositionChangeTrigger`, ambos features de riesgo de ESC 2018 Syncope Guidelines). `lib/services/presyncope_detail_format.dart` nuevo. `lib/widgets/presyncope_detail_sheet.dart` nuevo — sheet de una sola vista (no wizard), mismo patrón mixto single/multi-select que `headache_detail_sheet.dart`, con el chip `brief_loc` interceptado igual que el onset "thunderclap" de cefalea.

Cableado en `sintomas_tab.dart`: `_dispatchSymptomInput` gana el chequeo de presíncope junto a headache/fatigue/abdominal_pain/MCAS; ambos paths de guardado (add y edit) ganan `isPresyncope`/`presyncopeLayerEnabled`, la rama `else if` del sheet, el campo en `SymptomEvent(...)`/`copyWith(...)`, y la llamada a `detectPresyncopeRedFlags` + `_showPresyncopeAdvisoryFlags` (nuevo método, mirror de `_showFatigueAdvisoryFlags` ya que presíncope tampoco tiene tier urgent post-save — el único urgent se resuelve in-sheet); el timeline "Registros de hoy" gana un 4º bloque de resumen compacto entre abdominal y MCAS. Nota confirmada durante la exploración: el path de edición ya omitía MCAS por completo antes de esta sesión (posible gap preexistente, no tocado aquí — se agregó presíncope de todos modos, siguiendo el patrón de los otros tres). Relevancia + toggle: `_hasPresyncopeRelevance()` nuevo en `main_screen.dart` (mirror exacto de `_hasAbdominalRelevance`), pasado como `showPresyncopeDetail` a `TrackingSettingsScreen`, que gana el campo + un `_toggle(...)` condicional con key `presyncope_detail` en `tracking_settings_screen.dart`.

Localización: 10 claves ARB nuevas (`presyncopeSheetTitle/Subtitle`, `presyncopeActionSaveDetail`, `presyncopeLossOfConsciousnessDialogTitle/Confirm`, `presyncopeAdvisoryDialogTitle`, `presyncopeRedFlagExertionalTriggerAdvisory`/`NoPositionChangeTriggerAdvisory`, `settingsModulePresyncopeDetailLabel/Description`) en `app_es.arb`/`app_en.arb`/`app_zh.arb`, con getters a mano en `app_localizations.dart` + `_es`/`_en`. Para `app_localizations_zh.dart`: a diferencia de sesiones anteriores (que duplicaban cada clave nueva en `AppLocalizationsZh` y `AppLocalizationsZhTw`), esta vez se agregaron **una sola vez**, dentro de `AppLocalizationsZh` únicamente, dejando que `AppLocalizationsZhTw` las herede — verificado contra el código que ese es el patrón correcto y ya usado (`structuralZonePickTitle`), mientras que la duplicación en ambas clases (ej. `settingsModuleAbdominalDetailLabel`) es redundancia real, no una convención a seguir. Nota: los headers de grupo (`mechanism`/`prodrome`/`outcome`/`recovery`) NO van en ARB — vienen de `header_es/en/zh` dentro del JSON de Fase 1, igual que cefalea/fatiga/abdomen/estructural; el plan de partida los había listado por error como claves ARB. También se evitó una clave ARB extra para el cuerpo del diálogo de pérdida de consciencia (`presyncopeLossOfConsciousnessDialogBody`): siguiendo el patrón real de `headache_detail_sheet.dart` (el diálogo de thunderclap reusa `getChipDefinition()` del JSON en vez de un string ARB separado), el diálogo de presíncope reusa la definición ya escrita para el chip `brief_loc`, evitando una segunda fuente de verdad para el mismo texto.

Diseño documentado en `docs/design_decisions/symptom_detail_layers.md` §13: grounding (Brignole et al. 2018, ESC Syncope Guidelines, DOI 10.1093/eurheartj/ehy037; MAPS de Spahic et al. 2023, DOI 10.1111/joim.13566, evaluado y archivado como candidato a escala periódica futura en vez de usarse aquí — es cuestionario de carga de 7 días, no captura evento-a-evento), restricción explícita de Paulina de no construir `OrthostaticTest`/medición activa en este pase (diferido a versión móvil por seguridad, mismo argumento que ya pausó la prueba ortostática del Panel de Signos Vitales el 2026-07-16), esquema final, y disciplina V1/V2 de red flags. `ROADMAP.md` actualizado (snapshot 4/6, D.3 fuera del backlog).

Sesión 2026-07-18 — dos correcciones al flujo combinado zona+tipo de dolor estructural (18-jul rework) reportadas por Paulina, más una feature nueva pedida explícitamente. Vía Claude Code, sin toolchain de Flutter local — JSON/ARB validados con `python3 -c "import json"`, balance de llaves/paréntesis/corchetes contado por script en cada archivo tocado; pendiente `flutter analyze`/`flutter run -d chrome`.

(1) Bug real en producción: Paulina agregó "dolor piernas" al baúl y la app lo resolvió como "dolor de pie", zonas distintas. Causa raíz en `lib/services/structural_text_detector.dart`: el matching original usaba `String.contains` puro, así que el keyword `'pie'` (zona `feet`) hacía match como substring dentro de `"piernas"` (p-**ie**-rnas). El detector ya traía un fix de una sesión anterior no documentada aquí todavía (matching por límites de palabra vía lookaround `(?<!...)...(?!...)` con una clase de caracteres española explícita `[a-z0-9áéíóúñ]`, comentado in-line con el propio caso de "piernas"/"pie" como ejemplo) — esta sesión completó el trabajo relacionado que quedó a medio hacer: `StructuralTextMatch.hasAmbiguousZoneSignal` (bool) se reemplazó por `ambiguousZoneCandidates` (`List<String>?`), y `_ambiguousZoneSignalWords` (lista plana) se reemplazó por `_ambiguousZoneSignalGroups` (mapa palabra→lista de zonas candidatas: `pierna`/`piernas` → `[front_thigh, back_thigh, knees, calf, ankles, feet]`, `espalda` → `[upper_back, shoulder_blades, lumbar_pelvis]`). Motivo: Paulina señaló que "dolor de piernas" es más amplio que una sola zona (incluye muslo/pantorrilla/gemelos, no necesariamente rodilla) — antes, aunque el detector dejara `zone: null` correctamente, el paso de zona del sheet combinado mostraba la grilla completa de 22 zonas de todo el cuerpo sin acotar. `BodyZonePickerGrid` (lib/widgets/body_zone_picker_grid.dart) ganó un parámetro opcional `candidateZones` (`Set<String>?`) que filtra cada región a la intersección con la lista, saltando regiones que queden vacías; `showStructuralDetailSheet`/`_StructuralDetailSheetBody` (structural_detail_sheet.dart) lo reciben y lo pasan al paso de zona; `_openCombinedSheetForVault` y `_dispatchSymptomInput` (sintomas_tab.dart) propagan `match.ambiguousZoneCandidates` de punta a punta. Resultado: "dolor piernas" ahora abre el sheet acotado a las 6 zonas de pierna en vez de las 22 zonas de todo el cuerpo o (el bug) resolver directo a "pie".

(2) Laterality vs. zona de contexto: Paulina notó que elegir lateralidad (izquierda/derecha) no necesariamente coincide con la zona precisa ya elegida — "que me duela la zona derecha, no significa que sea la pierna derecha", puede ser más amplio o más angosto que la zona puntual. Propuso una "zona de contexto opcional". Implementado como campo de texto libre, no como taxonomía nueva (dato real insuficiente todavía para enumerar chips con sentido): `StructuralDetail.contextNote` (String?, aditivo, lib/models/structural_detail.dart) + campo `TextField` nuevo en el paso de grupos del sheet combinado (structural_detail_sheet.dart), mostrado justo debajo de los chips de lateralidad con label "Zona de contexto (opcional)" y hint de ejemplo. Serialización omite el campo si está vacío, igual que el resto de `StructuralDetail`.

(3) Persistencia de dolor estructural — pedido explícito de Paulina: "si lo registro hoy, hasta no marcarlo como algo solucionado, [quiero] suponer que se mantiene el dolor", con la opción de actualizar si mejoró sin resolverse. El modelo ya traía `StructuralEvent.resolvedAt`/`isResolved` desde antes (usado hoy solo en el sheet de edición manual, `_editStructuralEvent`) — el gap era puramente de flujo: cada tap de zona creaba SIEMPRE un evento nuevo, y "Registros de hoy" solo mostraba eventos con timestamp de ese día exacto (`getStructuralForDay`), así que un dolor sin resolver desaparecía del timeline al día siguiente salvo que se volviera a registrar. Cambios: `Profile.getStructuralActiveForDay(date)` nuevo en `models.dart` — eventos de ese día MÁS cualquier evento anterior sin resolver, deliberadamente separado de `getStructuralForDay` (sin tocar, sigue siendo same-day estricto) porque agregación de reportes/frecuencia (`pdf_report_aggregator.dart`, `symptom_frequency_dashboard.dart`) debe seguir contando solo registros reales, no dolor arrastrado. `sintomas_tab.dart` usa el nuevo método para `todaysStructs`. `_openStructuralEntry` ahora chequea PRIMERO si la zona tocada tiene un `StructuralEvent` sin resolver (antes de mirar `structuralZoneHistory`/abrir el embudo) — si lo hay, abre un check-in en vez de arrancar un registro nuevo. Sheet nuevo `lib/widgets/structural_checkin_sheet.dart` (`showStructuralCheckInSheet`): 4 opciones — Sigue igual / Mejoró, pero sigue con dolor / Empeoró / Se resolvió — que actualizan el MISMO `StructuralEvent` in-place vía `copyWith` (comparedToUsual o resolvedAt), sin crear un evento nuevo. En "Registros de hoy", los eventos arrastrados de días anteriores se marcan con un tag "en curso desde el {fecha}" y pierden el botón de eliminar (✕) — borrarlos desde la vista de "hoy" habría eliminado el registro original de cuando empezó el dolor, lo cual sería sorpresivo; en su lugar ganan un ícono de check-in (✓) visible en cualquier evento sin resolver, sea de hoy o arrastrado. `_structuralCompactSummary` se ajustó para que un check-in posterior sobre un evento que ya tenía `structuralDetail`/`bleedingDetail` (embudo o sangrado) siga siendo visible — antes, el resumen compacto priorizaba el detail adjunto y habría ocultado silenciosamente la actualización de `comparedToUsual` hecha vía check-in.

Interacción no resuelta, dejada tal cual a propósito: el flujo de "condición conocida" (`structuralZoneHistory` + quick-log, §12.6) crea eventos con `resolvedAt: null` también — con esta sesión, volver a tocar esa zona antes de marcarla resuelta ahora abre el check-in en vez de dejar registrar una nueva racha del día. Para una condición que flarea y se apaga sola día a día (ej. rodilla que duele en días de lluvia) esto podría sentirse distinto a antes; el botón "Se resolvió" del check-in es de un solo tap, así que el costo adicional es bajo, pero vale la pena que Paulina lo pruebe en uso real antes de asumir que es el comportamiento correcto para ese sub-flujo específico.

Localización: 8 claves ARB nuevas (`structuralContextZoneLabel/Hint`, `structuralCheckInTitle/Subtitle/Same/Better/Worse/Resolved`, `structuralOngoingSinceTag`) en `app_es.arb`/`app_en.arb`/`app_zh.arb`, con getters a mano en `app_localizations.dart` + `_es`/`_en`; en `app_localizations_zh.dart` se agregaron una sola vez dentro de `AppLocalizationsZh` (no duplicadas en `AppLocalizationsZhTw`), siguiendo el patrón ya confirmado como correcto en la sesión de presíncope de arriba.

Sesión 2026-07-17 (continuación, misma fecha que D.3 pero conversación separada) — D.4 (Dolor pélvico) implementado, quinta Symptom Detail Layer (5 de 6). Vía Claude Code, plan mode explícito (EnterPlanMode → 2 agentes Explore en paralelo para verificar el patrón real de D.3 presíncope y D.2 abdominal/red flags antes de escribir el plan final → ExitPlanMode con plan aprobado), sin toolchain de Flutter local — JSON/ARB validados con `python3 -c "import json"`, balance de llaves/paréntesis/corchetes contado por script en cada archivo tocado; **compilación confirmada por Paulina** (sin detalle de si fue `flutter analyze`, `flutter run -d chrome`, u otro método — a diferencia de Phase4.A/B, donde CLAUDE.md registra explícitamente qué comando se corrió).

Antes de escribir el schema, dos decisiones de contenido trauma-informed se confirmaron explícitamente con Paulina vía AskUserQuestion, en vez de asumirlas por precedente de otras capas — es el dominio de contenido más sensible que la app ha capturado hasta ahora: (1) si incluir un chip de dolor sexual/dispareunia (ACOG lo considera diferenciador clínico clave para endometriosis/vulvodinia, pero es contenido sensible) — Paulina eligió **incluirlo**, wording neutro ("con la actividad sexual"), opcional y skippable, sin preguntas de seguimiento; (2) tono del chip de ubicación externa — clínico-neutro (ej. "zona genital externa") vs. suave/cotidiano — Paulina eligió el registro **suave**, resultando en "Por fuera, en la zona íntima" (evita la palabra "genital" a propósito), consistente con el precedente de D.1 fatiga.

Implementado: `assets/symptom_definitions.json` — nueva clave `"pelvic_pain"` (aliases incluyendo endometriosis/adenomiosis/vulvodinia/dispareunia como términos que el detector de alias ya resuelve sin código especial, verificado que no colisiona con los aliases reales de `abdominal_pain`; master; 5 grupos, 23 chips: `location` 5/single, `character` 5/single, `timing` 3/single, `triggers` 5/multi, `accompaniments` 5/multi — excede el techo de ≤20 de Morren 2009 igual que D.2 abdominal, formalizado como patrón de dominio repetido en `symptom_detail_layers.md` §14.3 en vez de tratarse como excepción aislada cada vez). `lib/models/pelvic_pain_detail.dart` nuevo (5 enums + `PelvicPainDetail`, mismo patrón exacto que `presyncope_detail.dart`: `serializationKey`/`fromKey`, `copyWith` con flags `clearX` en los 3 campos single-select, `toMap`/`fromMap` con el patrón `xRaw is List` para los 2 campos Set). `SymptomEvent.pelvicPainDetail` agregado como 6º sibling de headache/fatigue/abdominal/presyncope/mcas en `models.dart` (mismos 4 puntos de contacto: campo, constructor, copyWith, toMap/fromMap con el patrón `xRaw is Map`). `lib/services/pelvic_pain_red_flags.dart` nuevo — reusa `RedFlagSeverity` existente, 1 URGENT in-sheet (`suddenSevereOnset`, gateado por `character == sudden_severe_onset`, sin gate de severidad, mismo "confiar en la aserción del usuario" que la calidad desgarro de D.2) + 2 URGENT post-save (`abnormalBleedingUrgent`: sangrado + severidad ≥3, compound gate igual que la hematoquecia de D.2; `feverUrgent`: fiebre el mismo día + severidad ≥2, reusa `Profile.getFeverForDay()` ya existente para `FeverReading` en vez de duplicar un chip de fiebre) + 2 ADVISORY post-save (`bladderPatternAdvisory`, `pelvicFloorTensionAdvisory` — esta última fundamenta en advisory real los hechos ya existentes de "Pelvic Floor & EDS"/"Pelvic Floor & Dysautonomia" en `assets/zebra_wisdom.json`). `lib/services/pelvic_pain_detail_format.dart` nuevo. `lib/widgets/pelvic_pain_detail_sheet.dart` nuevo — sheet de una sola vista (no wizard) igual que `presyncope_detail_sheet.dart`, pero el chip URGENT (`sudden_severe_onset`) se intercepta al intentar guardar (`_attemptSave`), no al tocar el chip — siguiendo el patrón de `abdominal_detail_sheet.dart` (permite leer la definición del chip vía el ícono de info sin ser interrumpido), no el de presíncope.

Cableado en `sintomas_tab.dart`: `_dispatchSymptomInput` gana el chequeo de `pelvic_pain` junto a headache/fatigue/abdominal_pain/presyncope/MCAS; ambos paths de guardado (add y edit) ganan `isPelvicPain`/`pelvicPainLayerEnabled`, la rama `else if` del sheet, el campo en `SymptomEvent(...)`/`copyWith(...)`, y las llamadas a `detectPelvicPainRedFlags` + dos métodos nuevos `_showPelvicPainUrgentFlags`/`_showPelvicPainAdvisoryFlags` (dual-tier, mismo patrón visual que abdominal: borde grueso rojo + `barrierDismissible:false` para urgent, borde delgado `alpha:0.5` para advisory; `suddenSevereOnset` se filtra del diálogo urgent post-save porque ya se reconoció in-sheet, igual que `tearingPainSedv` en D.2); el timeline "Registros de hoy" gana un 5º bloque de resumen compacto entre presíncope y MCAS. Relevancia + toggle: `_hasPelvicPainRelevance()` nuevo en `main_screen.dart` (mirror exacto de `_hasPresyncopeRelevance`), pasado como `showPelvicPainDetail` a `TrackingSettingsScreen`, que gana el campo + un `_toggle(...)` condicional con key `pelvic_pain_detail` en `tracking_settings_screen.dart`.

Localización: 15 claves ARB nuevas (`pelvicPainSheetTitle/Subtitle`, `pelvicPainActionSaveDetail`, `pelvicPainSuddenOnsetEmergencyTitle/Body/ChangeCharacter/SaveAsIs`, `pelvicPainUrgentDialogTitle`, `pelvicPainRedFlagAbnormalBleedingUrgent`/`FeverUrgent`, `pelvicPainAdvisoryDialogTitle`, `pelvicPainRedFlagBladderPatternAdvisory`/`PelvicFloorTensionAdvisory`, `settingsModulePelvicPainDetailLabel/Description`) en `app_es.arb`/`app_en.arb`/`app_zh.arb`, con getters a mano en `app_localizations.dart` + `_es`/`_en`; en `app_localizations_zh.dart` se agregaron una sola vez dentro de `AppLocalizationsZh` (no duplicadas en `AppLocalizationsZhTw`), mismo patrón ya confirmado correcto en la sesión de presíncope. Verificado con `python3` que las 15 claves existen idénticas en los tres locales antes de cerrar la sesión.

Diseño documentado en `docs/design_decisions/symptom_detail_layers.md` §14: las dos decisiones trauma-informed confirmadas con Paulina, grounding (ACOG Practice Bulletin No. 218, Chronic Pelvic Pain, *Obstet Gynecol* 2020;135(3):e98–e109, DOI 10.1097/AOG.0000000000003716 — verificado vía WebSearch, no asumido de memoria), esquema final, formalización de la desviación del techo de chips como patrón repetible (no excepción aislada), disciplina V1/V2 de red flags, y decisiones diferidas (integración con tracking menstrual — no existe todavía, mismo principio que `linkedBowelEventId` se construyó solo porque `BowelEvent` ya existía; mapeo HPO agrupado con D.5). `ROADMAP.md` actualizado (snapshot 5/6, D.4 fuera del backlog).

Sesión 2026-07-17 (segunda continuación, misma fecha que D.3/D.4 pero conversación separada) — D.5 (Dolor torácico) implementado, sexta y última Symptom Detail Layer del roadmap original (6 de 6, cobertura completa). Vía Claude Code, plan mode explícito (EnterPlanMode → 1 agente Explore para mapear todo el contenido existente en el repo relacionado a dolor de pecho/cardíaco/vEDS antes de escribir el plan final, más WebSearch directo para verificar las dos citas clínicas → ExitPlanMode con plan aprobado), sin toolchain de Flutter local — JSON/ARB validados con `python3 -c "import json"`, balance de llaves/paréntesis/corchetes contado por script en cada archivo tocado; pendiente `flutter analyze`/`flutter run -d chrome`.

Es el síntoma de mayor riesgo real que captura la app: el dolor de pecho en esta población abarca desde costocondritis/síndrome de Tietze benigno y muy frecuente (ya documentado en `assets/condition_codes.json`, con una advertencia explícita de "no asumas que 'es solo Tietze' sin evaluación") hasta síndrome coronario agudo y, para el subconjunto de pacientes con EDS vascular (vEDS), disección o rotura arterial. Antes de diseñar los red flags, se confirmó con Paulina —vía AskUserQuestion, no asumido— construir la primera rama de red flag de esta app condicionada por `Profile.conditions`: el diálogo de emergencia in-sheet para el chip de carácter "desgarro" muestra texto vEDS-específico (evitar compresiones torácicas si es posible, RM/TC cruciales — ambos hechos ya existentes en `assets/zebra_wisdom.json`) cuando el perfil coincide con palabras clave de EDS vascular, y texto general poblacional en caso contrario. El matching (`veds`, `vascular eds`, `vascular ehlers` sobre texto en minúsculas) reusa exactamente las mismas tres substrings que ya usaba `domainsForUserCondition` en `lib/services/condition_labels.dart:217-239` — verificado leyendo el código real antes de escribirlo, no asumido. Este patrón ya había sido identificado como necesario pero diferido en `docs/design_decisions/symptom_detail_layers.md` §12.6b (tejido blando/vEDS); D.5 lo implementa por ser el síntoma donde la distinción es más clínicamente consecuente.

Implementado: `assets/symptom_definitions.json` — nueva clave `"chest_pain"` (aliases incluyendo costocondritis; verificado que no colisionan con `abdominal_pain` ni con `structural`, que excluye vocabulario de pecho explícitamente desde la sesión del 18-jul; master; 4 grupos, 21 chips: `location` 5/single —incluye `upper_back_between_shoulder_blades`, patrón de irradiación interescapular clásico de disección, no solo una zona musculoesquelética—, `character` 5/single —incluye `aching_worse_with_pressing`, el diferenciador de costocondritis por sensibilidad reproducible a la palpación, y `tearing_or_ripping`, el gate del red flag URGENT in-sheet—, `triggers` 5/multi, `accompaniments` 6/multi —incluye `palpitations_or_racing_heart`, relevante por la comorbilidad de POTS/disautonomía en esta población—). `lib/models/chest_pain_detail.dart` nuevo, mismo patrón exacto que `pelvic_pain_detail.dart`. `SymptomEvent.chestPainDetail` agregado como 7º sibling de headache/fatigue/abdominal/presyncope/pelvic_pain/mcas en `models.dart`. `lib/services/chest_pain_red_flags.dart` nuevo — reusa `RedFlagSeverity` existente, expone `isLikelyVEDSFromConditions()` como función pública reusable, y define 6 condiciones de red flag (más que cualquier capa anterior, confirmando la nota "múltiples red flags esperadas" del backlog): 1 URGENT in-sheet (`tearingOrRipping`, sin gate de severidad, copy bifurcada por vEDS) + 2 URGENT post-save (`possibleCardiacPatternUrgent`: presión/opresión + irradiación a brazo/mandíbula/espalda o disnea o sudoración + severidad ≥2, combinación de riesgo anginal de Gulati et al. 2021; `exertionalPatternUrgent`: disparador de esfuerzo + disnea o palpitaciones + severidad ≥2) + 3 ADVISORY post-save (`pleuriticPatternAdvisory`, `palpitationsPatternAdvisory`, `refluxPatternAdvisory`). Control de fatiga de alarma resuelto por taxonomía de chips, no por un sistema de historial nuevo: la presentación benigna de costocondritis no satisface ningún gate. `lib/services/chest_pain_detail_format.dart` nuevo. `lib/widgets/chest_pain_detail_sheet.dart` nuevo — primer sheet de la app que recibe `profileConditions: List<String>` (no el `Profile` completo, manteniéndolo desacoplado del modelo igual que el resto de las capas) y llama a `isLikelyVEDSFromConditions()` al construir el diálogo de "desgarro"; intercepción al intentar guardar (`_attemptSave`), no al tocar el chip, siguiendo el patrón de `abdominal_detail_sheet.dart`.

Cableado en `sintomas_tab.dart`: `_dispatchSymptomInput` gana el chequeo de `chest_pain`; ambos paths de guardado (add y edit) ganan `isChestPain`/`chestPainLayerEnabled`, la rama `else if` del sheet (pasando `profileConditions: _p.conditions`), el campo en `SymptomEvent(...)`/`copyWith(...)`, y las llamadas a `detectChestPainRedFlags` + dos métodos nuevos `_showChestPainUrgentFlags`/`_showChestPainAdvisoryFlags` (dual-tier, mismo patrón visual que abdominal/pelvic pain); el timeline "Registros de hoy" gana un 6º bloque de resumen compacto entre pelvic pain y MCAS. Relevancia + toggle: `_hasChestPainRelevance()` nuevo en `main_screen.dart` (mirror exacto de `_hasPelvicPainRelevance`), pasado como `showChestPainDetail` a `TrackingSettingsScreen`, que gana el campo + un `_toggle(...)` condicional con key `chest_pain_detail` en `tracking_settings_screen.dart`.

Localización: 17 claves ARB nuevas (`chestPainSheetTitle/Subtitle`, `chestPainActionSaveDetail`, `chestPainTearingEmergencyTitle`, `chestPainTearingEmergencyBodyGeneral`/`BodyVEDS` —las dos variantes de copy vEDS-condicional—, `chestPainTearingEmergencyChangeCharacter`/`SaveAsIs`, `chestPainUrgentDialogTitle`, `chestPainRedFlagCardiacPatternUrgent`/`ExertionalPatternUrgent`, `chestPainAdvisoryDialogTitle`, `chestPainRedFlagPleuriticPatternAdvisory`/`PalpitationsPatternAdvisory`/`RefluxPatternAdvisory`, `settingsModuleChestPainDetailLabel/Description`) en `app_es.arb`/`app_en.arb`/`app_zh.arb`, con getters a mano en `app_localizations.dart` + `_es`/`_en`; en `app_localizations_zh.dart` se agregaron una sola vez dentro de `AppLocalizationsZh` (no duplicadas en `AppLocalizationsZhTw`), mismo patrón confirmado correcto desde la sesión de presíncope. Verificado con `python3` que las 17 claves existen idénticas en los tres locales antes de cerrar la sesión.

Diseño documentado en `docs/design_decisions/symptom_detail_layers.md` §15: la decisión vEDS-condicional confirmada con Paulina y su justificación, grounding (Gulati M et al. 2021, AHA/ACC Chest Pain Guideline, *Circulation* 2021;144:e368–e454, DOI 10.1161/CIR.0000000000001029; Isselbacher EM et al. 2022, ACC/AHA Aortic Disease Guideline, *Circulation* 2022, DOI 10.1161/CIR.0000000000001106, cubre vEDS explícitamente — ambas verificadas vía WebSearch, no asumidas de memoria), esquema final, disciplina de 6 red flags, y el cierre del mapeo HPO diferido en §12.8/§13.5/§14.5 ahora que las tres capas candidatas (estructural, D.4, D.5) están completas. `ROADMAP.md` actualizado (snapshot 6/6, Symptom Detail Layers completo).

Sesión 2026-07-18 — Panel de Signos Vitales (Presión Arterial) + pase de correcciones UX/beta. Vía Claude Code, plan mode explícito para el alcance del Panel de Signos Vitales (AskUserQuestion antes de codear: PA sola este pase, `OrthostaticTest` diferido), sin toolchain de Flutter local — balance de llaves/paréntesis por script, JSON/ARB validados con `python3 -c "import json"`; **compilación confirmada por Paulina** antes de que empezara a preparar el deploy de este ciclo.

(1) Presión Arterial implementada, cerrando la mitad greenfield de `docs/design_decisions/vital_signs_panel.md` §5.1 (fiebre y HRV ya existían; PA y `OrthostaticTest` no). `BloodPressurePosition` enum (`sitting`/`lying`/`standing`) + `BloodPressureReading` (sistólica, diastólica, FC opcional, posición, nota) en `lib/models/models.dart`, junto a `FeverReading` — deliberadamente sin ningún getter de interpretación (nada de "esto se ve alto/bajo"): una lectura suelta no tiene baseline contra qué compararse, esa lógica quedó reservada para `OrthostaticTest`. `Profile.bloodPressureHistory` + `getBloodPressureForDay()`. Toggle `blood_pressure` off-by-default en `TrackingSettingsScreen` (seleccionado a favor de replicar el precedente HRV/sleep/hydration por ser módulo nuevo, no el de fiebre, que quedó sin toggle desde antes de que el patrón `optionalTrackers` se consolidara). Sheet nuevo `lib/widgets/blood_pressure_form_sheet.dart` (calcado de `hrv_form_sheet.dart`: steppers de sistólica/diastólica con edición directa por tap, FC opcional agregable/quitable, chips de posición), cableado completo en `sintomas_tab.dart` (sección colapsable, timeline "Registros de hoy", handlers mirror de HRV). El punto de seguridad pendiente de `OrthostaticTest` (§7 del doc de diseño — riesgo de síncope durante la prueba de pie) quedó **resuelto en conversación** aunque el modelo/UI en sí no se construyó: advertencia previa + botón de "Detener prueba" visible en todo momento, decisión registrada para cuando se retome ese hilo, sin necesidad de volver a preguntarla.

(2) Pase de correcciones puntuales pedido por Paulina sobre trabajo de sesiones anteriores (Botiquín/onboarding/movimiento/sueño/hidratación/HRV/Ajustes), ninguna requirió research previo, todas confirmadas de alcance acotado antes de codear salvo la de localización (ver más abajo): (a) barra de navegación inferior más alta (`SizedBox` + `iconSize`/`selectedFontSize` mayores en `main_screen.dart`). (b) Los 4 pasos de `onboarding_screen.dart` ahora usan `SingleChildScrollView` + `Column(mainAxisSize: MainAxisSize.min)` en vez de `Padding` fijo — evita overflow en celulares chicos o con letra grande. (c) **Localización de strings hardcodeados — investigado pero NO resuelto en este pase**: el sondeo inicial (~45 strings) resultó ser la punta de un problema mucho más grande — 9 archivos completos sin ninguna integración de l10n (`mcas_detail_sheet.dart`, `flare_control.dart`, `flare_suggestion_banner.dart`, `action_effectiveness_dialog.dart`, `retro_symptom_dialog.dart`, `pdf_export_sheet.dart`, `action_taken_sheet.dart`, `life_event_form_sheet.dart`, `beta_access_screen.dart`), más gaps parciales en 3 archivos ya integrados, más una segunda capa descubierta por accidente (helpers de tiempo relativo tipo "hace 2 días" duplicados en ~8 archivos más, y ternarios de botones "Editar"/"Guardar cambios"). Decisión explícita: no perseguir esto de forma apurada dentro del mismo pase — queda como tarea propia, con el inventario ya hecho para retomarla directamente en vez de re-descubrirlo. (d) `movimiento_tab.dart`: ejercicios/modalidades de terapia personalizados (`_p.customExercises`/`_p.customTherapyModalities`) ahora se pueden eliminar (ícono de `InputChip`) y renombrar (long-press → diálogo), sin tocar los ítems del catálogo fijo (`kExerciseCatalog`/`kTherapyCatalog`), que siguen sin ser editables a propósito. (e) `sleep_form_sheet.dart`: agregados selectores opcionales de hora de acostarse/despertar (`showTimePicker`, hora y minutos reales) que auto-calculan la duración vía módulo (maneja el cruce de medianoche); campos aditivos `SleepEntry.bedTimeMinutes`/`wakeTimeMinutes` (minutos desde medianoche, mismo patrón sin-dependencia-de-Flutter que `MedicationGroup.defaultTimeMinutes`). Corrección de la misma sesión, a pedido de Paulina tras ver el resultado: la duración pasó de un solo campo decimal ("7.5") a dos campos separados Horas/Minutos (`_durationHoursCtrl`/`_durationMinutesCtrl`) — el cálculo automático desde acostarse/despertar ahora llena ambos campos en vez de escribir un decimal. (f) `hydration_form_sheet.dart`: nuevo `Profile.customBeverages` (mismo patrón que `customExercises`) + `HydrationEntry.customBeverageName` — permite agregar bebidas propias (ej. "Té") como chips seleccionables adicionales a los 4 fijos de `HydrationBeverage`, persistidas para uso futuro. (g) `HrvContext` ganó el valor `average` ("Promedio"/"Average"/"平均"), quinta opción de contexto junto a matinal/tarde/noche/post-ejercicio/otro. (h) Link de acceso rápido al cuestionario de seguimiento (`BetaAccessService.followUpQuestionnaireUrl`, Google Form) agregado en Ajustes → Acerca de — **gateado a locale español únicamente** (`Localizations.localeOf(context).languageCode == 'es'`, oculto por completo en EN/ZH, no solo sin traducir) porque el cuestionario en sí solo existe en español. De la misma conversación: link a la cuenta de Bluesky del proyecto (`BetaAccessService.blueskyUrl`, `https://bsky.app/profile/zebraup.bsky.social`) agregado en el mismo lugar — a diferencia del cuestionario, este **sí se muestra en los tres idiomas** (`aboutBlueskyLinkLabel`, nueva clave ARB) porque una cuenta de red social no es un contenido específico de un idioma.

(3) Dos correcciones finas reportadas por Paulina tras revisar lo anterior: "lpm" en el campo de frecuencia cardíaca de PA corregido a **"ppm"** (pulsaciones por minuto es la abreviatura correcta en español clínico; "lpm" quedó como un error — inglés "bpm" y chino "次/分" no se tocaron, ya eran correctos). Confirmado que "ppm" es el único cambio necesario vía `grep` de todo `lib/` antes de tocar nada, para no dejar otro `lpm` suelto.

Todas las claves ARB nuevas de esta sesión (`bloodPressureHeartRateUnit` ahora "ppm" en es, `sleepFieldDurationHoursLabel`/`MinutesLabel`, `hydrationBeverageAddCustomHint`, `hrvContextAverage`, `movementRenameDialogTitle`, `settingsModuleBloodPressureLabel/Description`, `aboutBlueskyLinkLabel`, y el resto de claves de PA) siguen el patrón ya establecido: `AppLocalizationsZh` una sola vez, heredado por `AppLocalizationsZhTw` sin duplicar. `pubspec.yaml` sigue en `2.3.5+1` (ya preparado para este ciclo desde el deploy de v2.3.4) — Paulina reportó que este ciclo completo (D.5 + Panel de Signos Vitales/PA + este pase de correcciones) compila y procederá a desplegarlo como v2.3.5; falta que confirme el deploy real para registrarlo en CHANGELOG.md § "Estado de Deploy".

Anexo: Equivalencia Terminológica

Término InglésTérmino Español LatAmNotasSymptom SeverityGravedad de SíntomaEscala 0–4Medication OutcomeResultado de MedicamentoPost-dosis, LikertFlare ModeModo BroteEstado agudo (alias UI: "modo crisis")ActionTakenAcción TomadaPost-síntoma, 13 tiposCrashColapso FuncionalFatiga severa post-esfuerzoPattern DetectionDetección de PatronesCard transversal, toggleable (suprimible en Modo Cuidadoso)Mood StateEstado EmocionalCircumplex + paletasLocal-FirstAlmacenamiento LocalDatos nunca salen del dispositivo sin consentimiento
