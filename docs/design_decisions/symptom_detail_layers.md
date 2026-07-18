# Capas de detalle por síntoma — decisiones de diseño

**Sprint:** C.4
**Estado al cierre del sprint:** Cefalea implementada como primer caso. Patrón listo para replicar a otros síntomas (próximo: fatiga).
**Última actualización:** 30-jun-2026

Este documento consolida la base de investigación y las decisiones de diseño que sustentan el sistema de capas de detalle por síntoma en ZebraUp. Sirve como referencia para implementaciones futuras (fatiga, dolor abdominal, presíncope, dolor pélvico, dolor torácico) y como justificación clínica/UX cuando un colaborador externo o un revisor pregunte por qué un módulo se diseñó como se diseñó.

---

## 1. Propósito de las capas de detalle

Un síntoma genérico ("cefalea", "fatiga", "dolor abdominal") aporta poca información clínica por sí solo. La diferencia entre una migraña con aura y una cefalea tensional, o entre fatiga post-esfuerzo cognitivo y fatiga ortostática, es lo que un clínico necesita para diagnosticar y ajustar tratamiento.

La capa de detalle captura **rasgos observables** (no etiquetas diagnósticas) que el paciente puede identificar sin formación médica, y los traduce en datos estructurados que el clínico puede leer rápido. Esto es especialmente crítico para pacientes con enfermedades raras ("cebras") que típicamente tienen 7-10 minutos por consulta y necesitan llegar con datos objetivos.

---

## 2. Base de investigación

Tres fuentes de research independientes (corpus NotebookLM de 200+ papers, Gemini deep research, Science-Hub Bot para literatura primaria) convergieron en los siguientes hallazgos. Cada uno se traduce en una decisión de diseño concreta.

### 2.1 Reportar rasgos observables, no etiquetas diagnósticas

**Hallazgo:** Cuando se pide a pacientes que clasifiquen su propio dolor de cabeza como "tensional" vs "migraña", 86% de quienes se autodiagnostican como tensionales cumplen criterios de migraña al evaluación clínica.

**Cita:** Tepper SJ, Dahlöf CG, Dowson A, et al. Prevalence and diagnosis of migraine in patients consulting their physician with a complaint of headache: data from the Landmark Study. *Headache.* 2004;44(9):856-864. DOI: 10.1111/j.1526-4610.2004.04165.x

**Decisión:** Los chips capturan rasgos (unilateral, pulsátil, fotofobia, peor al estar de pie) — nunca pedimos al paciente que elija "es migraña" o "es tensional". El clínico hace ese mapeo.

### 2.2 Disclosure progresivo > entrada plana

**Hallazgo:** Los formularios que muestran todos los campos a la vez tienen tasas de abandono significativamente más altas que los que revelan campos progresivamente. En pacientes con fatiga cognitiva (ME/CFS, fibromialgia, EDS con disautonomía), el efecto se amplifica.

**Citas:**
- Slater H, et al. End user and implementer experiences of mHealth technologies for noncommunicable chronic disease management in young adults: systematic review. *J Med Internet Res.* 2017;19(12):e406. DOI: 10.2196/jmir.8888
- van Berkel N, Goncalves J, Hosio S, et al. Effect of experience sampling schedules on response rate and recall accuracy. *Int J Hum Comput Stud.* 2019;125:118-128. DOI: 10.1016/j.ijhcs.2018.12.002

**Decisión:** La capa de detalle es un paso opcional **después** del severity grading, con un botón "Saltar" igual de prominente que "Guardar detalle". El paciente nunca queda atrapado completando todos los chips.

### 2.3 Regla de dos taps para fatiga cognitiva

**Hallazgo:** En usuarios con niebla mental crónica, cualquier registro que requiera más de dos taps por dimensión tiene baja adherencia a 30 días.

**Cita:** Davies B, et al. Self-tracking with cognitive impairment. *CHI Conference on Human Factors in Computing Systems Proceedings.* 2019. DOI: 10.1145/3290605.3300444

**Decisión:** Cada chip = un tap (toggle). El info icon en cada chip es un tap separado para definición, no es obligatorio. Severidad ya está pre-seleccionada antes de la capa de detalle.

### 2.4 Sin streaks ni gamificación punitiva

**Hallazgo:** Los streaks ("registraste 7 días seguidos") generan ansiedad y abandono en poblaciones con enfermedad crónica fluctuante. El día que rompen el streak por estar en crash, dejan la app.

**Citas:**
- Schroeder J, et al. Pocket Skills: A conversational mobile web app to support dialectical behavioral therapy. *CHI Conference on Human Factors in Computing Systems Proceedings.* 2018. DOI: 10.1145/3173574.3173972

**Decisión:** Ningún elemento del flujo de detalle muestra streaks, badges o counters de "logros". El refuerzo positivo se hace vía surfacing de patrones útiles para el paciente, no vía gamificación.

### 2.5 Personalización aumenta retención

**Hallazgo:** En un estudio longitudinal con n=184 usuarios durante 593 días, la capacidad de habilitar/deshabilitar trackers individuales aumentó retención en 3.2x vs forma fija.

**Cita:** Jones SL, et al. Customisation of symptom tracking with uMotif: a longitudinal study. *npj Digital Medicine.* 2021;4:155. DOI: 10.1038/s41746-021-00525-1

**Decisión:** La capa de detalle por síntoma se activa/desactiva por usuario en settings (`optionalTrackers['headache_detail']`, `['fatigue_detail']`, etc.). Un paciente sin cefaleas no ve el switch siquiera — sólo aparece si "cefalea" o un alias está en su vault o conditions.

### 2.6 Diarios diarios > recall retrospectivo

**Hallazgo:** En pacientes con síntomas gastrointestinales (IBS, gastroparesis), el recall de 7 días previa la consulta tiene correlación r=0.31 con diarios diarios. El recall sobreestima severidad y subestima frecuencia.

**Citas:**
- Palsson OS, Whitehead WE, et al. Development of the Rome IV functional gastrointestinal disorder diagnostic questionnaire. *Gastroenterology.* 2016;150(6):1481-1491. DOI: 10.1053/j.gastro.2016.02.014
- Lackner JM, et al. The accuracy of patient-reported measures for IBS. *Psychosom Med.* 2014;76(4):310-319. DOI: 10.1097/PSY.0000000000000051

**Decisión:** El detalle se captura **en el momento del log**, no retroactivamente al final del día. La pestaña Hoy y el reporte clínico leen lo que se capturó en el momento, sin pedir al paciente que recuerde patrones.

### 2.7 Límite de ítems por entrada

**Hallazgo:** Meta-análisis de 17 estudios EMA muestra que tasas de cumplimiento caen drásticamente cuando una entrada requiere más de 20 ítems totales.

**Cita:** Morren M, Van Dulmen S, Ouwerkerk J, Bensing J. Compliance with momentary pain measurement using electronic diaries: a systematic review. *Eur J Pain.* 2009;13(4):354-365. DOI: 10.1016/j.ejpain.2008.05.010

**Decisión:** La capa de detalle de cefalea tiene 19 chips totales distribuidos en 5 grupos. Bajo el límite. Cuando agreguemos fatiga, abdominal, etc., cada uno respetará el mismo techo.

### 2.8 Frecuencia óptima de prompts

**Hallazgo:** En contextos EMA, 3-5 prompts/día maximizan información útil sin generar fatiga de notificación.

**Cita:** May M, et al. Designing for symptom tracking. *cEMAp.* 2018. DOI: 10.1145/3173574.3173801

**Decisión:** ZebraUp no usa notificaciones push (PWA web). Los registros son user-initiated. Esto encaja con el principio: ninguna entrada es obligatoria, todas son opcionales.

---

## 3. Decisiones transversales (aplicables a todo síntoma)

Las siguientes decisiones se aplicaron a cefalea y deben replicarse cuando se implemente cualquier otro síntoma con capa de detalle.

| # | Decisión | Justificación |
|---|----------|---------------|
| 1 | Capas por síntoma, no genéricas | Cada síntoma tiene su propio marco clínico (ICHD-3, IOM 2015, Rome IV, etc.). Un schema unificado pierde precisión. |
| 2 | Schema cerrado en Dart (enums tipados, no `Map<String,dynamic>`) | Type safety en compile time, autocomplete, refactoring seguro. Costo: cada síntoma necesita su propio archivo de modelo. |
| 3 | Definiciones en JSON externo | Permite editar definiciones sin recompilar y traducir a 3 locales (es/en/zh-TW) en el mismo archivo. |
| 4 | Activación per-usuario via `optionalTrackers` map en Profile | Sin schema bump cuando se agrega un nuevo síntoma. Extensible. |
| 5 | Switch sólo visible cuando el síntoma matchea vault o conditions | Reduce ruido en settings. Implementado via `SymptomDefinitionsService.matchesSymptomKey`. |
| 6 | Capa = paso opcional con "Saltar" prominente | Disclosure progresivo. El paciente nunca queda atrapado. |
| 7 | Chips con info icon individual | Definición clínica accesible sin abrir manuales externos. |
| 8 | Red flags clasificados en URGENT (advisory fuerte) y ADVISORY (informativo) | Evita paternalismo en patrones no-urgentes, mantiene alerta fuerte para emergencias reales. |
| 9 | Master symptom keyword matching (aliases) | El vault del paciente puede decir "cefalea", "dolor de cabeza", "migraña", "headache" — todos matchean al mismo key clínico. |
| 10 | Trail de DOIs en comentarios de header del archivo de modelo + este markdown | Cualquier decisión clínica trazable a literatura primaria. |

---

## 4. Implementación: cefalea (primer caso)

### 4.1 Estructura de grupos

5 grupos, 19 chips totales, orden ICHD-3:

1. **Localización** (multi-select, 6 chips): unilateral, bilateral, detrás de los ojos, cuello/occipital, sienes, coronilla/difusa
2. **Calidad** (single-select, 4 chips): pulsátil, opresiva/tensional, punzante, brain zaps (descargas eléctricas)
3. **Acompañantes** (multi-select, 7 chips): náusea, vómito, fotofobia, fonofobia, aura visual, intolerancia al movimiento, **desregulación de temperatura**
4. **Patrón postural** (single-select, 3 chips): empeora de pie, empeora acostada, sin patrón postural
5. **Inicio** (single-select, 1 chip): thunderclap (inicio súbito en segundos)

### 4.2 Decisiones específicas

**Inclusión de "desregulación de temperatura" en Acompañantes (no está en ICHD-3):** Añadido tras revisión con la persona desarrolladora (paciente con clEDS + disautonomía). Aunque no es un acompañante migrañoso clásico, en el subgrupo EDS-disautonomía es altamente prevalente y diagnósticamente útil. Decisión basada en experiencia directa del paciente, no en ICHD-3.

**Por qué solo 1 chip en "Inicio":** En la primera versión sólo capturamos thunderclap porque es el único con red flag asociado de severidad urgente. Otros patrones de inicio (gradual, post-Valsalva, post-coito) se pueden agregar en una iteración posterior si la base de usuarios lo justifica. Mantener el grupo con 1 chip permite agregarlos sin migrar schema.

**Por qué single-select en calidad:** ICHD-3 trata calidad como mutuamente excluyente en el momento. Un mismo episodio puede empezar opresivo y volverse pulsátil — eso se captura con dos registros separados, no marcando dos chips al mismo tiempo.

**Por qué multi-select en localización:** La cefalea puede ocupar dos zonas a la vez (ej. unilateral + cuello), y la ICHD-3 acepta múltiples localizaciones simultáneas.

### 4.3 Red flags activos

Tres red flags implementados en `lib/services/headache_red_flags.dart`, todos derivados de SNNOOP10 + literatura específica de EDS.

| Flag | Trigger | Severidad | Justificación clínica |
|------|---------|-----------|----------------------|
| Thunderclap | Onset = thunderclap | URGENT (dialog rojo + confirmación pre-save) | Diagnóstico diferencial obligatorio para hemorragia subaracnoidea. Do MTS et al. (SNNOOP10). |
| Fuga de LCR | Patrón postural = empeora de pie AND severidad ≥ 3 | ADVISORY (dialog informativo post-save) | Hipotensión intracraneal espontánea; prevalencia elevada en EDS por debilidad del tejido conectivo dural. Schievink WI. |
| Hipertensión intracraneal | Patrón postural = empeora acostada AND severidad ≥ 3 | ADVISORY (dialog informativo post-save) | Idiopathic intracranial hypertension; asociación EDS documentada. Friedman DI. |

### 4.4 Red flags diferidos

| Flag | Razón de diferir |
|------|------------------|
| Meningitis (fiebre + rigidez de cuello + cefalea súbita) | Requiere chips de "fiebre concurrente" y "rigidez de cuello" que no están en el schema actual. Cuando se integre el tracker de fiebre con la capa de cefalea (Phase 5+), reactivar. |
| Aura prolongada (>60 min) | Requiere captura de duración del aura, fuera del schema actual. Agregar cuando se diseñe la capa de tiempo en síntomas. |

### 4.5 DOIs citados en los archivos de código

Estos DOIs aparecen en comentarios de header en:
- `assets/symptom_definitions.json` (metadata block)
- `lib/services/headache_red_flags.dart`
- `lib/models/headache_detail.dart`

| DOI | Fuente |
|-----|--------|
| 10.1177/0333102417738202 | ICHD-3 official classification |
| 10.1212/WNL.0000000000006697 | SNNOOP10 red flag mnemonic |
| 10.1002/ajmg.a.36000 | Reinstein E et al. 2013 — clEDS clinical features |
| 10.1002/ajmg.c.31549 | Henderson FC et al. 2017 — neurological manifestations of hereditary connective tissue disorders |

---

## 5. Decisiones diferidas / abiertas

1. **Captura de duración** del episodio individual (start/end). No incluido en V1 porque agrega complejidad de UX (un timer? un picker post-hoc?). Se evaluará tras un mes de uso de la versión actual.
2. **Trigger tracking** (qué precedió a la cefalea: comida, estrés, clima, hormonal). Se está acumulando data implícita vía la correlación con weather, life events, y mood; agregar campo explícito sólo si los testers reportan que la inferencia automática no es suficiente.
3. **Edge case en `_editSymptomEvent`**: si el usuario quiere **borrar** un detalle existente, hoy debe re-abrir el sheet y dejar todo sin marcar — y eso retorna null, que se interpreta como "preservar". Para clearing explícito se requiere un flag en `SymptomEvent.copyWith`. Diferido porque caso de uso es raro.
4. **Multi-detail por evento**: hoy un SymptomEvent tiene un solo `headacheDetail`. Si el paciente quiere registrar dos cefaleas el mismo día con distinto detalle, debe crear dos SymptomEvents separados. Funciona pero podría ser más fluido.

---

## 6. Replicabilidad: cómo agregar un nuevo síntoma con detalle

Plantilla para implementar el siguiente síntoma (próximo: fatiga). Cada paso replica directamente lo hecho para cefalea.

1. **Investigación clínica** — identificar el marco de referencia del síntoma:
   - Cefalea → ICHD-3
   - Fatiga → IOM 2015 (criterios ME/CFS), CDC criteria
   - Dolor abdominal → Rome IV
   - Presíncope → ESC 2018 syncope guidelines
   - Dolor pélvico → ACOG guidelines
   - Dolor torácico → AHA/ACC 2021

2. **Definir grupos y chips** en `assets/symptom_definitions.json`:
   - Master entry con label es/en/zh-TW y master definition es/en/zh-TW
   - Aliases para keyword matching (palabras que el paciente puede escribir en el vault)
   - 3-6 grupos lógicos
   - Total ≤ 20 chips (regla Morren 2009)
   - Cada chip con label + clinical definition en 3 locales

3. **Definir red flags** específicos del síntoma:
   - Identificar el equivalente al SNNOOP10 para ese síntoma
   - Clasificar como URGENT (intervención inmediata) o ADVISORY (mencionar al médico)
   - Implementar `detect{Symptom}RedFlags` función pura

4. **Modelo Dart** en `lib/models/{symptom}_detail.dart`:
   - Enums tipados por grupo con `serializationKey` + `fromKey`
   - Clase `{Symptom}Detail` con `isEmpty`, `copyWith`, `toMap`, `fromMap`
   - DOIs en header

5. **Sheet UI** en `lib/widgets/{symptom}_detail_sheet.dart`:
   - Mismo patrón que `headache_detail_sheet.dart` — Skip prominente, info icons, master definition disponible vía title button
   - Confirmación pre-save para chips URGENT

6. **Extender `SymptomEvent`** con campo opcional `{symptom}Detail`:
   - Aditivo, backward compatible
   - Reutilizar el patrón de `headacheDetail`

7. **Integración en flow** de log:
   - En `sintomas_tab._openSeverityMenu.saveWith`: chequeo de matchesSymptomKey + tracker active → ofrecer sheet
   - Procesar red flags via `detect{Symptom}RedFlags` + `_showAdvisoryFlags`

8. **Settings switch**:
   - Agregar SwitchListTile condicional en `main_screen._buildSettingsDrawer`, gated por extension de `_hasHeadacheRelevance` (renombrarla a `_hasSymptomRelevance(symptomKey)` cuando agregue el segundo)

9. **Renders compactos**:
   - Extender `headache_detail_format.dart` o crear `{symptom}_detail_format.dart` paralelo
   - Renderizar en `sintomas_tab` TODAY's COMBINED LOG y `hoy_tab` narrative summary

10. **ARB keys**:
    - Sheet title, subtitle, save action
    - Cualquier red flag dialog/snackbar específico
    - Settings label + description
    - Mirror es/en/zh-TW

11. **Actualizar este documento** con la sección 4 equivalente para el síntoma nuevo.

---

## 7. Métricas de éxito

Para evaluar si la capa de detalle está siendo útil tras un mes de uso por los testers chilenos y los pacientes de Taiwan:

- **Tasa de uso**: % de registros de cefalea que incluyen detalle (vs Saltar). Objetivo: ≥ 40%.
- **Distribución de chips**: ¿qué chips se marcan más? Si alguno tiene <2% de uso, considerar simplificar el grupo.
- **Red flag trigger rate**: ¿cuántos casos de CSF leak advisory por mes? Si muy bajo, validar que los testers entienden el patrón postural.
- **Feedback cualitativo de los testers**: ¿los textos de las definiciones son claros? ¿algún chip que falte?

---

*Fin del documento. Última revisión: cierre del sprint C.4 (jun-2026). Próximo sprint planificado: capa de detalle para fatiga (IOM 2015 ME/CFS + CDC framework).*
<!-- D.1_PART_C_APPENDED -->

---

## 8. D.1 — Fatigue detail layer

**Sprint completed:** 2026-07-02. This section closes out the fatigue
detail layer, which was scoped, designed, implemented, hot-fixed, and
verified across sub-sprints D.1.A → D.1.D.2.

### 8.1 Clinical grounding

Fatigue was chosen as the second symptom in the detail-layer roadmap
because (a) it is a core zebra symptom present in ME/CFS, fibromyalgia,
and EDS with dysautonomia; (b) it is heterogeneous — five clinically
separable subtypes per Jason MFTQ 2010 — so a schema-closed detail
layer materially improves clinical utility; and (c) unlike cefalea, it
has no acute URGENT patterns, making it a good test of the
ADVISORY-only red-flag path in `sintomas_tab._showFatigueAdvisoryFlags`.

Primary references (verified DOIs, embedded in
`lib/models/fatigue_detail.dart` and `lib/services/fatigue_red_flags.dart`
headers):

- Clayton EW. IOM 2015 ME/CFS criteria (SEID) —
  DOI: 10.1001/jama.2015.1346
- Mateo LJ et al. 2020 — PEM quantification, 24-72h onset, 51%
  unrecovered at day 7. DOI: 10.3233/wor-203168
- Jason LA et al. 2010 — MFTQ 5 clinically distinguishable fatigue
  types including "wired" as factorially separable.
  DOI: 10.1080/08964280903521370
- De Wandele I et al. 2016 — orthostatic intolerance in 74.4% of
  EDS-HT; fatigue +3.1 NRS post-tilt vs +0.5 controls.
  DOI: 10.1093/rheumatology/kew032
- Voermans NC et al. 2010 — fatigue as frequent and clinically
  relevant problem in EDS.
  DOI: 10.1016/j.semarthrit.2009.08.003
- Rowe PC et al. 1999 — EDS + CFS + orthostatism co-occurrence.
  DOI: 10.1016/s0022-3476(99)70173-3
- Davies T et al. 2019 CHI — tracking fatigue UX; symptom-tracking
  fatigue is a first-order UX concern.
  DOI: 10.1145/3290605.3300452
- Morren M et al. 2009 — ≤20 items EMA rule; determined chip count
  ceiling. DOI: 10.1016/j.ejpain.2008.05.010

### 8.2 Final schema

Four groups, 20 chips total (at the Morren 2009 ceiling):

| Group             | Kind          | Chips |
|-------------------|---------------|-------|
| type              | single_select | 5     |
| temporal_pattern  | single_select | 4     |
| accompaniments    | multi_select  | 8     |
| trigger           | multi_select  | 3     |

Chip serialization keys (stable across releases; safe to reference from
analytics and clinical exports):

- **type**: `cognitive_drain`, `muscle_unresponsive`, `orthostatic`,
  `post_exertional`, `hpa_wired`
- **temporal_pattern**: `since_waking`, `during_day`, `post_meal`,
  `post_trigger`
- **accompaniments**: `brain_fog`, `dizziness_standing`,
  `unrefreshing_sleep`, `resting_tachycardia`, `headache`,
  `diffuse_muscle_pain`, `light_sound_intolerance`, `temp_dysregulation`
- **trigger**: `past_exertion`, `bad_night`, `emotional_stress`

Aliases (JSON-level, flat list — see 8.6 for why this shape matters):

- es: fatiga, cansancio, agotamiento, agotada, agotado, drenada,
  drenado, sin energía
- en: fatigue, exhaustion, exhausted, tired, worn out, weary
- zh: 疲勞, 疲倦, 疲憊, 累

### 8.3 Design iterations with the user

The chip set went through three rounds of feedback before implementation:

**Iteration 1** — 6 type chips proposed: cognitive_drain,
muscle_unresponsive, orthostatic, post_exertional, hpa_wired, PLUS
`only_want_to_lie_down`.

User feedback: `only_want_to_lie_down` was descriptive of her
experience but did not correspond to a distinct physiological
mechanism — the phenomenology emerges from a combination of orthostatic
+ PEM + unrefreshing sleep, all of which are separately covered.
Removed to preserve schema parsimony.

**Iteration 2** — chip label for `hpa_wired` was originally *"Agotada
pero acelerada, no puedo descansar"*. User flagged the feminine
adjective and asked for gender-neutral phrasing.

Three candidates evaluated:

- *"No logro descansar"* — rejected: too broad, applies to 5+ distinct
  mechanisms (pain, insomnia, anxiety, apnea, wired-but-tired) and
  loses clinical discriminability
- *"El cuerpo no logra apagarse aunque estoy exhausta"* — rejected:
  still feminine
- **"No logro descansar aunque el cuerpo está exhausto"** — chosen

The chosen phrasing preserves the wired-but-tired specificity (Jason
2010 MFTQ separates this from generic sleep issues) while being fully
gender-neutral in LatAm Spanish.

**Iteration 3** — added `resting_tachycardia` to accompaniments after
user reported resting tachycardia during iron-deficiency episodes and
observed the same in her Chilean beta community. Chip also serves POTS
and dysautonomia phenotype detection, which is separately common in
EDS.

The MFTQ "flu-like" (inflammatory) subtype was **deliberately not
included** as a fifth accompaniment cluster:

- Fever is already a first-class event (`FeverReading`, schema v3)
- Sore throat and adenopathies are rare in the current beta phenotype
- Adding would exceed Morren's 20-item ceiling

Reactivate if Long COVID users join the beta and inflammatory fatigue
becomes prevalent.

### 8.4 Red flags: ADVISORY only, plain language

Fatigue has three detectable patterns, all surfaced as ADVISORY (no
URGENT). Contrast with cefalea, whose `thunderclap` fires an in-sheet
emergency dialog *before* save.

**Detection gate:** `severityIndex >= 3` (intense or unbearable). Below
that, the pattern is captured in `SymptomEvent.fatigueDetail` for
retrospective review but not surfaced as an advisory — avoids alert
fatigue during mild episodes.

**Patterns:**

- `pemPattern` — type = `post_exertional` AND severity ≥ 3
- `orthostaticPattern` — type = `orthostatic` AND severity ≥ 3
- `hpaPattern` — type = `hpa_wired` AND severity ≥ 3

**Message language.** The initial drafts used clinical shorthand.
Per user request, all three messages were rewritten in everyday
Spanish. Comparison for the PEM pattern:

Original (rejected):

> *"Este patrón puede sugerir malestar post-esfuerzo (PEM), criterio
> central de ME/SFC y frecuente en EDS con disautonomía. La aparición
> 24-72h después del esfuerzo es característica."*

Shipped:

> *"Este patrón muestra que tu fatiga aparece 1-3 días después de un
> esfuerzo. Puede indicar que tu cuerpo tiene menos reservas de energía
> de lo habitual y necesita más días para recuperarse. Si se repite,
> considera mencionárselo a tu médico."*

Rules for advisory copy applied uniformly across the three patterns:

1. No acronyms (PEM, POTS, ME/SFC, HPA, tilt test, cortisol).
2. Explain mechanism in everyday terms (*"tu cuerpo tiene menos
   reservas de energía"*, *"tu sistema de estrés lleva mucho tiempo
   activado"*).
3. Close with *"considera mencionárselo"* or *"vale mencionárselo"* —
   soft suggestion, not imperative.
4. Preserve epistemic humility: *"puede indicar"*, never *"indica"* or
   *"confirma"*.

### 8.5 Replication template application

The C.4 cefalea 11-step replication template held with two refinements
required for D.1. Actual work log per step:

1. **Research consolidation** — MFTQ, IOM 2015, De Wandele 2016
   yielded chip set
2. **JSON extension** — `assets/symptom_definitions.json` +fatigue
   entry (see 8.6 for the shape bug hot-fixed post-implementation)
3. **Model file** — `lib/models/fatigue_detail.dart` with 4 typed enums
4. **Red flag service** — `lib/services/fatigue_red_flags.dart`
5. **SymptomEvent extension** — `fatigueDetail` field, parallel to
   `headacheDetail`
6. **Sheet widget** — `lib/widgets/fatigue_detail_sheet.dart`
7. **Format helper** — `lib/services/fatigue_detail_format.dart`
8. **sintomas_tab integration** — save flow, edit flow, TODAY log
   render, advisory dialog
9. **ARB additions** — 9 new keys × 3 locales
10. **Settings switch** — `_hasFatigueRelevance()` gate,
    `optionalTrackers['fatigue_detail']`
11. **hoy_tab narrative** — `_buildSentences` extension

**Refinement 1:** the model file gained `clearType` and
`clearTemporalPattern` flags on `copyWith` to allow explicit clearing
of single-select fields — a gap that was implicit in the cefalea
`HeadacheDetail` and would have needed a follow-up refactor. Adopted
into the template for D.2+.

**Refinement 2:** deferred consolidation of `HeadacheRedFlagSeverity`
and `FatigueRedFlagSeverity` into a shared `RedFlagSeverity` enum.
Duplication is documented in `fatigue_red_flags.dart` header. Not
blocking D.2; consolidate before D.3 to avoid a third duplicate.

### 8.6 Lessons learned — D.1.A.fix

**The bug.** The initial `phase_d1a_json.py` used a nested-dict schema
for aliases, labels, headers, and definitions:

```json
"aliases": {"es": [...], "en": [...], "zh_TW": [...]},
"label": {"es": "Fatiga", "en": "Fatigue", "zh_TW": "疲勞"},
"groups": {"type": {"header": {"es": "..."}, "chips": {...}}}
```

The actual convention (established by cefalea, expected by
`SymptomDefinitionsService`) is flat suffix keys:

```json
"aliases": ["fatiga", "cansancio", "fatigue", "疲勞", ...],
"master": {"label_es": "Fatiga", "label_en": "Fatigue", "label_zh": "疲勞"},
"groups": {
  "type": {
    "header_es": "...",
    "chips": {
      "cognitive_drain": {"label_es": "...", "def_es": "..."}
    }
  }
}
```

Additional gotchas discovered during the fix:

- Chip definition key is `def_XX`, **not** `definition_XX`. The
  service calls `_localizedString(source, 'def', localeCode)`.
- Chinese suffix is `_zh`, **not** `_zh_TW`. `_langSuffixFor('zh_TW')`
  normalises to `'zh'` before the key lookup.
- The `master` sub-node is required — labels and definitions cannot
  live at the symptom root.

**Impact.** Silent failure. The JSON loaded successfully ("loaded 2
symptoms" appeared in the browser console) but every downstream lookup
returned `null` or `[]`. `matchesSymptomKey('fatiga', 'fatigue')`
returned false because `getAliases` bailed at the `is! List` check.
Consequences: settings switch never appeared, sheet never triggered on
log, no visible sign that anything was broken until end-to-end testing.

**Root cause.** The D.1.A JSON was designed without inspecting
cefalea's JSON or reading `SymptomDefinitionsService.dart`. A "cleaner"
nested schema was assumed without verifying the production convention.

**Fix.** `phase_d1a_fix_json_shape.py` transformed the fatigue entry
in place, verbatim — no content re-typed, only structure rewritten.
Idempotent via `fatigue.master` sentinel.

**Preflight check adopted as step 0 of the replication template.**
Before writing a new symptom's JSON entry, read
`lib/services/symptom_definitions_service.dart` and inspect the JSON
block of the most recently added symptom. Verify:

1. Are aliases a flat list or a nested dict?
2. Do labels use `_es` suffix or nested `{es: ...}`?
3. Is the definition key `def_XX` or `definition_XX`?
4. Which locale suffix is used for zh-TW (`_zh` or `_zh_TW`)?
5. Is a `master` sub-node required for symptom-level fields, or do
   they live at the root?

This five-question sanity check would have prevented D.1.A.fix.
Applies to D.2+ and to any future assumption about a convention
established by a previously-shipped symptom.

---

## 9. Sprint completion log

| Sprint | Symptom       | Status     | Groups | Chips | URGENT flags | Notes                                             |
|--------|---------------|------------|--------|-------|--------------|---------------------------------------------------|
| C.4    | Cefalea       | ✓ 2026-06  | 5      | 19    | 1 (thunderclap) | +`temp_dysregulation` added post-launch          |
| D.1    | Fatiga        | ✓ 2026-07  | 4      | 20    | 0            | Structural hot-fix D.1.A.fix applied              |
| D.2    | Dolor abdominal | Planned  | TBD    | TBD   | 3-4 expected | Rome IV framework, 5 abstract quadrants           |
| D.3    | Presíncope    | Backlog    | —      | —     | TBD          | Likely orthostatic-focused                        |
| D.4    | Dolor pélvico | Backlog    | —      | —     | TBD          | Trauma-informed design considerations             |
| D.5    | Dolor torácico | Backlog   | —      | —     | Multiple expected | Cardiac ruling-out UX critical                |

**Coverage metric:** 2 of 6 planned symptoms implemented (33%). Both
have working sheet, advisory-flag detection, TODAY log render, hoy_tab
narrative render, and gated settings switch. D.2 pending research
consolidation (Rome IV + EDS-GI phenotype papers from
Fikree/Zeitoun/Nelson; DOIs verified by NotebookLM 2026-07-02).

### 9.1 Files touched in D.1 (delta from post-C.4 state)

New files:

- `lib/models/fatigue_detail.dart`
- `lib/services/fatigue_red_flags.dart`
- `lib/services/fatigue_detail_format.dart`
- `lib/widgets/fatigue_detail_sheet.dart`

Modified files:

- `assets/symptom_definitions.json` — +fatigue entry (post-fix shape)
- `lib/models/models.dart` — +`fatigueDetail` field on `SymptomEvent`
  (import, constructor, `copyWith`, `toMap`, `fromMap`)
- `lib/screens/sintomas_tab.dart` — save/edit fatigue branches, TODAY
  log render, `_showFatigueAdvisoryFlags` method
- `lib/screens/main_screen.dart` — `_hasFatigueRelevance()` helper,
  gated fatigue `SwitchListTile`
- `lib/screens/hoy_tab.dart` — narrative render extension, import
- `lib/l10n/app_es.arb` + `app_en.arb` + `app_zh_TW.arb` — +9 keys per
  locale

Zero migrations required — all changes additive per the
`optionalTrackers` extension pattern established in F6.a.
<!-- D.2_PART_C_APPENDED -->

---

## 10. D.2 — Abdominal detail layer

**Sprint completed:** 2026-07-02. Third detail layer in the roadmap
(after cefalea and fatiga). Introduces three new patterns not present
in earlier layers: progressive disclosure semántico, in-sheet emergency
dialog for tearing quality, and bidirectional integration with an
existing typed event (BowelEvent).

### 10.1 Clinical grounding

Abdominal pain was chosen as the third symptom because (a) it is the
most heterogeneous of the six planned symptoms — Rome IV separates it
into functional dyspepsia, IBS, biliary functional pain, and CAPS by
observable pattern alone; (b) it has the highest URGENT-flag surface
area of any detail layer to date (three vs. one in cefalea, zero in
fatiga), including the vascular-rupture risk from clEDS; and (c) the
EDS phenotype is well characterised — Fikree, Zeitoun, and Nelson
cohorts report 66-84% GI symptom prevalence and 25% gastroparesis in
EDS populations.

Primary references (verified DOIs, embedded in
`lib/models/abdominal_detail.dart` and
`lib/services/abdominal_red_flags.dart` headers):

- Palsson OS et al. 2016 — Rome IV Diagnostic Questionnaire for
  Adults. DOI: 10.1053/j.gastro.2016.02.014
- Zeitoun JD et al. 2013 — Functional digestive symptoms and quality
  of life in EDS (n=134, 84% GI prevalence).
  DOI: 10.1371/journal.pone.0080321
- Fikree A et al. 2014 — GI symptoms in JHS prospective cohort.
  DOI: 10.1016/j.cgh.2014.01.014
- Fikree A et al. 2015 — FGID + JHS case-control.
  DOI: 10.1111/nmo.12535
- Fikree A et al. 2017 — GI involvement in EDS review.
  DOI: 10.1002/ajmg.c.31546
- Nelson AD et al. 2015 — Mayo Clinic 20-year retrospective (66% GI,
  25% gastroparesis, 30% abnormal colonic transit).
  DOI: 10.1111/nmo.12665
- Lackner JM et al. 2014 — Accuracy of patient-reported measures for
  IBS. DOI: 10.1097/PSY.0000000000000109

### 10.2 Final schema

Five groups, 22 chips total — **intentionally exceeds** the Morren
2009 ≤20 ceiling (see 10.3 for rationale):

| Group           | Kind          | Chips |
|-----------------|---------------|-------|
| location        | single_select | 5     |
| quality         | single_select | 4     |
| timing          | single_select | 4     |
| accompaniments  | multi_select  | 6     |
| trigger         | multi_select  | 3     |

Chip serialization keys (stable across releases):

- **location**: `epigastric`, `periumbilical`, `hypogastric`, `ruq`,
  `diffuse`
- **quality**: `colicky`, `burning`, `pressure`, `tearing`
- **timing**: `postprandial_immediate`, `postprandial_delayed`,
  `nocturnal`, `bowel_related`
- **accompaniments**: `nausea`, `vomiting`, `early_satiety`,
  `bloating`, `excessive_gas`, `bloody_stool`
- **trigger**: `specific_food`, `emotional_stress`, `menstrual_cycle`

Aliases (JSON-level, flat list, 41 total) span three semantic
clusters — this is new versus cefalea and fatiga which each have a
single semantic cluster:

- **Pain** (es/en/zh): dolor abdominal, dolor de estómago, dolor de
  guata, dolor de panza, cólico, retortijón, abdominal pain, stomach
  pain, cramps, 腹痛, 肚子痛, 胃痛, ...
- **Bloating**: hinchazón, distensión, panza hinchada, guata hinchada,
  bloating, abdominal distension, 腹脹, 腹部脹氣
- **Gas**: gases, pedos, peos, flatulencia, gas, farting, flatulence,
  放屁, 排氣, 脹氣

### 10.3 Chip ceiling deviation

22 chips exceeds the Morren 2009 EMA guideline of ≤20 items per
episode capture. The deviation was accepted after weighing:

- Morren 2009 studied general symptom EMA in pain populations, not
  domain-specific abdominal capture
- Rome IV distinguishes 4+ functional GI disorders by chip
  combinations that require the full location × quality × timing
  matrix
- EDS GI phenotype (Fikree, Nelson) is polymorbid — patients often
  present multiple accompanying features simultaneously; forcing them
  to pick one of two accompaniments would lose information

Trade-off accepted: two extra chips of cognitive load vs. losing
clinical discriminability. Chips considered for cutting but retained:
`ruq` (rare in clEDS but standard-of-care for biliary pain),
`vomiting` (distinct severity signal vs. nausea alone), `bloody_stool`
(URGENT gate compound), `menstrual_cycle` (central for adenomyosis
phenotype).

Future ceiling adjustments: if D.4 pélvico or D.5 torácico also
exceed 20, formalise the deviation as a domain-specific override in
this document rather than treating each as an exception.

### 10.4 Progressive disclosure semántico

**New pattern introduced in D.2.** Aliases for a single symptom key
now belong to distinct semantic clusters (pain / bloating / gas). The
sheet detects which alias variant triggered the sheet open and
pre-marks context-appropriate chips.

Implementation:

- `SymptomDefinitionsService.detectAliasVariant(userInput, symptomKey)`
  returns `'pain'` / `'bloating'` / `'gas'` / `null`
- Called by `showAbdominalDetailSheet` in `initState` when
  `widget.existing == null` (skip in edit mode — user's stored
  selections take precedence)
- Pre-selection is minimal: `bloating` variant pre-marks the
  `bloating` chip in accompaniments; `gas` variant pre-marks
  `excessive_gas`. `pain` variant marks nothing (default full sheet).
- **All groups remain visible regardless of variant.** The variant
  informs pre-selection but does not gate what the user can log —
  bloating with cramps is a valid combination and must be capturable.

Check order in `detectAliasVariant`: bloating → gas → pain. Specific
variants win over the generic pain cluster when a user input matches
multiple (e.g., "hinchazón" matches bloating cluster; a hypothetical
"cólico hinchazón" would match bloating first because that check
runs before pain).

Rationale for pattern: the same symptom key (`abdominal_pain`) has
multiple lay-terms that carry semantic content ("gases" implies
flatulence, "hinchazón" implies distension). Rather than force these
into separate symptom keys with duplicate schemas, one key + variant
detection preserves data-model simplicity while respecting user
vocabulary. Reactivate for D.4 pélvico if similar variant clustering
emerges (menstrual vs. ovulation vs. non-cyclical pelvic pain).

### 10.5 In-sheet emergency dialog for tearing quality

**Second new pattern in D.2**, extending the cefalea thunderclap
approach.

When the user selects `quality = tearing` and taps "Guardar detalle",
the sheet intercepts before save and shows an emergency dialog with
warning icon, thick border, and Paulina-approved copy specific to the
clEDS phenotype (mentions TNXB mutation and instruction to
communicate the diagnosis to paramedics).

Two branches:

- **"Cambiar calidad y guardar"** — returns `false`, sheet regains
  focus, user can revise quality and save with the standard flow
- **"Guardar como está (emergencia)"** — returns `true`, sheet
  commits the save with `quality = tearing` as-is

Design differences from cefalea thunderclap:

1. **Fires on save attempt, not on chip selection.** The user can
   explore quality options — tap tearing, read the definition,
   change mind — without being warned repeatedly. Only the actual
   commit triggers the dialog.
2. **`barrierDismissible: false`** — the user must make an explicit
   choice, cannot dismiss by tapping outside.
3. **Post-save red flag detection SKIPS `tearingPainSedv`.** The
   `_showAbdominalUrgentFlags` method explicitly filters out this
   flag because it was already handled in-sheet. Surfacing it again
   would create alarm fatigue for someone who just acknowledged the
   in-sheet warning.

Text scope caveat: the current copy mentions clEDS + TNXB explicitly.
For future users with hEDS, vEDS, or other subtypes, this text will
need Profile-conditions-driven personalization. Deferred to a future
refinement sprint — Paulina is the initial user and the copy is
correct for her phenotype.

### 10.6 Three-tier red flag handling

Cefalea had two tiers (in-sheet URGENT thunderclap + post-save
ADVISORY). Fatiga had one tier (post-save ADVISORY only). D.2
introduces a **three-tier structure**:

- **In-sheet URGENT** (`tearingPainSedv`): handled by the sheet's
  emergency dialog before save commits
- **Post-save URGENT** (`massiveHematochezia`, `hematemesis`):
  handled by `_showAbdominalUrgentFlags` — prominent dialog with
  warning icon, thick border, `barrierDismissible: false`
- **Post-save ADVISORY** (`nocturnalPainAdvisory`,
  `gastroparesisPatternAdvisory`): handled by
  `_showAbdominalAdvisoryFlags` — softer info-icon dialog, thin
  border

Gates:

- Tearing pain: **no severity gate** — user asserting tearing quality
  is trusted regardless of numeric severity (patients often
  understate in-progress emergencies)
- Massive hematochezia: **compound gate** — `bloody_stool` +
  (`nausea` OR `vomiting`) + severity ≥ 3. Isolated hemorrhoidal
  bleeding does NOT fire.
- Hematemesis: **note text scan** — no chip exists to avoid daily
  users seeing "vómito con sangre" every time they log; keyword
  match on the free-text note field with an es/en/zh keyword set of
  15 terms
- Nocturnal advisory: `timing == nocturnal AND severity >= 3` (Rome
  IV alarm criterion)
- Gastroparesis advisory: `timing == postprandial_immediate AND
  accompaniments has early_satiety AND severity >= 2` (lower gate
  because the pattern itself is specific per Nelson 2015)

Post-save call order: URGENT first, ADVISORY second. Both sequential
with `if (!mounted) return;` guards between.

### 10.7 Bidirectional integration with BowelEvent (D.2.E)

**Third new pattern in D.2.** The abdominal detail layer is the
first to integrate with another existing typed event
(`BowelEvent` from Phase 5.1) via a bidirectional prompt system.

Forward direction (BowelEvent → AbdominalDetail):

- Triggered in `_openBowelForm` after a NEW BowelEvent is saved AND
  the `abdominal_detail` tracker is enabled
- Prompt: "¿Registrar detalle del dolor?"
- If Yes: opens `showAbdominalDetailSheet` with
  `symptomInput = canonicalName` (localized master label, produces
  `pain` variant, no pre-marked chips)
- On save: creates a new `SymptomEvent` with `severity = moderate` (2),
  `name = canonicalName`, `timestamp = bowelEvent.timestamp`,
  `abdominalDetail.linkedBowelEventId = bowelEvent.id`
- URGENT/ADVISORY dialogs surface normally after save

Reverse direction (AbdominalDetail → BowelEvent):

- Triggered by `_maybeLinkToBowelEvent(detail, eventTime)` in `saveWith`
  and `_editSymptomEvent` when the abdominal detail has
  `timing == bowelRelated` AND `linkedBowelEventId == null`
- Searches `_p.bowelHistory` for a BowelEvent within ±1 hour of
  `eventTime`, closest by absolute delta
- Prompt: "¿Vinculado a una evacuación de las {time}?"
- Options: Sí / No / No lo sé (all three distinct; "No lo sé"
  returns null which is treated as No for linkage but is
  semantically distinct as future analytics signal)
- On Yes: `detail.copyWith(linkedBowelEventId: candidate.id)` before
  `setState`

Design decisions in D.2.E:

- **`accompaniedByPain` field on BowelEvent does not exist yet.**
  My initial plan gated the forward prompt on `result.accompaniedByPain`
  but the field is not in the model. Deferred to a future refactor;
  for now the forward prompt fires on every new BowelEvent when the
  tracker is enabled. UX trade-off: mild intrusion vs. missed
  linkages. If UX becomes noisy, add the field to BowelEvent and
  gate on it.
- **Default severity = moderate (2).** The forward flow doesn't
  include a severity picker to keep the flow lightweight. User can
  edit via TODAY log if the pain was worse.
- **`linkedBowelEventId` is best-effort FK.** Referential integrity
  is not enforced — if the referenced BowelEvent is deleted, the
  abdominal detail retains the dangling ID for future analytics
  recovery.
- **Skip on edits (forward direction only).** The forward prompt
  only fires for NEW BowelEvents (`existing == null` in the outer
  flow) to avoid re-prompting on every edit. Reverse direction
  fires on both save and edit — a user might change timing to
  `bowelRelated` on edit and want to link retroactively.

### 10.8 Replication template refinements from D.2

The 11-step template held for D.2 with additions:

- **Step 0 (preflight)** worked as designed. All 5 JSON convention
  questions were verified against cefalea + fatiga post-fix state
  before writing the D.2 JSON. No structural mismatches occurred —
  first sprint using the preflight and it caught nothing (which is
  the goal).
- **New step 12: integration cruzada.** For symptoms with meaningful
  temporal overlap with other typed events (like abdominal ↔ bowel),
  add a `linkedXxxEventId` field to the detail model and a
  bidirectional prompt system. Template for D.4 pélvico
  (potentially links to menstrual tracking when added) and D.5
  torácico (potentially links to activity tracking).
- **Progressive disclosure semántico** is a new pattern available
  for future symptoms with multi-cluster aliases. Reusable via
  `detectAliasVariant` extension in the service.

Deferred refactors (documented for D.3+):

- `HeadacheRedFlagSeverity`, `FatigueRedFlagSeverity`,
  `AbdominalRedFlagSeverity` are triplicated. Consolidate into a
  shared `RedFlagSeverity` enum before D.3 to avoid quadruplication.
- `_showAdvisoryFlags` (cefalea) is not named `_showHeadacheAdvisoryFlags`
  for symmetry with the other two. Rename before D.3 as part of the
  shared severity refactor.

### 10.9 Lessons learned — anchor drift

**The bug:** Multiple D.2.E patch scripts failed with "anchor not
found" errors because the assumed structure of `_openBowelSheet` did
not match the actual file. The actual method is called `_openBowelForm`
(not `_openBowelSheet`), lives inside `sintomas_tab.dart` (not a
separate widget file), has a different signature (uses
`prefilledBucket` not `existing`-only), and lacks fields I assumed
existed (like `accompaniedByPain` on BowelEvent).

**Root cause:** I based my patch anchors on a `_openBowelSheet` block
that Paulina pasted in an earlier turn. That block was either from a
different app state or was a reconstruction — not verbatim from the
current file. I did not verify the anchor against the file state
before writing the patch, and did not ask for a fresh paste of the
target region before delivering D.2.E.

**Impact:** Three failed patch attempts, cognitive-load cost to
Paulina, wasted iteration credits. Eventually resolved via
`grep -rn "showBowelFormSheet"` + `sed -n '1820,1900p'` to see the
actual code, followed by manual snippet application.

**Rules adopted for D.3+:**

1. **Before writing any anchor for an existing file, request a
   FRESH paste of the target region** — do not rely on paste from
   earlier turns.
2. **When targeting a method by name, verify the exact method name
   in the current file first.** Assumptions about naming (e.g.
   `_openBowelSheet` vs. `_openBowelForm`) cost real iterations.
3. **Verify field/getter names before generating code that
   references them.** `accompaniedByPain` cost an extra compile
   iteration.
4. **When the user asks for manual snippets over automation, deliver
   manual snippets without further script attempts.** The switch to
   manual mode was resisted when it should have been accepted
   immediately.

Preflight-style questions to ask before writing any patch to an
existing file (in addition to the 5-question JSON preflight from
D.1.A.fix):

1. What is the exact current method name?
2. What is the exact method signature (params + return type)?
3. What fields on referenced types (e.g., BowelEvent.accompaniedByPain)
   actually exist?
4. Have I seen the target region within the current session, or is
   the paste from a stale earlier turn?

---

## 11. Sprint completion log (updated)

| Sprint | Symptom       | Status     | Groups | Chips | URGENT flags | Notes                                             |
|--------|---------------|------------|--------|-------|--------------|---------------------------------------------------|
| C.4    | Cefalea       | ✓ 2026-06  | 5      | 19    | 1 (thunderclap) | +`temp_dysregulation` added post-launch          |
| D.1    | Fatiga        | ✓ 2026-07  | 4      | 20    | 0            | Structural hot-fix D.1.A.fix applied              |
| D.2    | Dolor abd.    | ✓ 2026-07  | 5      | 22    | 3 (1 in-sheet, 2 post-save) | Progressive disclosure, bidirectional bowel integration |
| D.3    | Presíncope    | Backlog    | —      | —     | TBD          | Likely orthostatic-focused                        |
| D.4    | Dolor pélvico | Backlog    | —      | —     | TBD          | Trauma-informed; menstrual integration candidate  |
| D.5    | Dolor torácico | Backlog   | —      | —     | Multiple expected | Cardiac ruling-out UX critical                |

**Coverage metric:** 3 of 6 planned symptoms implemented (50%). All
three ship with working sheet, red-flag detection, TODAY log render,
hoy_tab narrative render, and gated settings switch. D.2 additionally
ships bidirectional BowelEvent integration.

### 11.1 Files touched in D.2 (delta from post-D.1 state)

New files:

- `lib/models/abdominal_detail.dart`
- `lib/services/abdominal_red_flags.dart`
- `lib/services/abdominal_detail_format.dart`
- `lib/widgets/abdominal_detail_sheet.dart`

Modified files:

- `assets/symptom_definitions.json` — +abdominal_pain entry
- `lib/models/models.dart` — +`abdominalDetail` field on `SymptomEvent`
- `lib/services/symptom_definitions_service.dart` —
  +`detectAliasVariant` method +3 static const alias clusters
- `lib/screens/sintomas_tab.dart` — save/edit abdominal branches,
  TODAY log render, `_showAbdominalUrgentFlags`,
  `_showAbdominalAdvisoryFlags`, `_promptBowelToAbdominal`,
  `_maybeLinkToBowelEvent`, forward integration in `_openBowelForm`
- `lib/screens/main_screen.dart` — `_hasAbdominalRelevance()` helper,
  gated abdominal `SwitchListTile`
- `lib/screens/hoy_tab.dart` — narrative render extension, import
- `lib/l10n/app_es.arb` + `app_en.arb` + `app_zh_TW.arb` — +14 keys
  (D.2.C) + 7 keys (D.2.E)

Zero migrations required. All changes additive per the
`optionalTrackers` extension pattern.

---

## 12. Estructural — Dolor musculoesquelético (diseño en curso, sin sprint asignado)

**Estado:** En discusión con la usuaria (2026-07-15 a 2026-07-16). Sin implementar — este documento congela las decisiones tomadas hasta ahora en la conversación. La lista final de chips por grupo queda explícitamente pendiente (ver §12.6); no usar este documento todavía como spec de implementación.

### 12.1 Motivación

Paulina identificó dos problemas encadenados en el picker actual de "ZONAS ESTRUCTURALES":

1. El dolor muscular post-ejercicio normal (DOMS) se registraba bajo el mismo ícono de alerta (⚠️) que subluxaciones/dislocaciones, pese a ser una respuesta esperada y benigna a la actividad — más intensa en hipermovilidad (ver `assets/zebra_wisdom.json`, hallazgo Ostuni et al., confirmado real en auditoría de código).
2. Pacientes con poca experiencia clínica pueden no reconocer o no saber nombrar lo que les pasa ("subluxación", "entesitis") cuando sí saben describirlo en lenguaje llano (lateralidad, si duele al moverse, si es punzante u hormigueo, si hay antecedente de esfuerzo o "duele porque sí").

### 12.2 Estado del código verificado antes de diseñar

Auditoría directa de `lib/models/models.dart` y `lib/screens/sintomas_tab.dart` (no se asumió nada de una propuesta externa sin verificar, siguiendo el preflight del proyecto):

- 27 valores en `kStructuralTaxonomy` bajo 6 `StructuralEventKind`: joint (4), muscle (6), tendon (5), ligament (3), softTissue (7), nerve (2).
- El ⚠️ uniforme solo existe en el timeline "Registros de hoy" (aplica a todo evento sin mirar `kind`); el picker de selección ya varía ícono por kind. El problema real está en la visualización posterior, no en el picker de entrada.
- `StructuralEvent` solo tiene `zone`, `kind`, `type`, `note`, `resolvedAt`, `stillPainful` — sin lateralidad, carácter del dolor, ni mecánica. Un comentario preexistente en el código (línea ~475) ya anticipaba "`BodySide` enum support in a future sprint" — nunca se construyó.
- No existe `structural_red_flags.dart` — es la única categoría mayor de síntomas sin servicio de red flags (cefalea, fatiga, abdomen y MCAS sí tienen el suyo).
- Nota de proceso: la primera propuesta de este rediseño vino de una instancia externa de Claude (Claude web) sin acceso al código. Acertó el diagnóstico del problema (mezcla DOMS/red-flags) pero se equivocó en detalles verificables (afirmó un ⚠️ uniforme en el picker que no existe ahí, y sugirió mapear directo a Orphanet cuando en realidad el vocabulario controlado relevante es HPO). Se corrigió contra el código real antes de avanzar — mismo principio que ya aplica el proyecto a sus propios parches.

### 12.3 Decisiones de alcance

| # | Decisión | Estado |
|---|----------|--------|
| 1 | Patrón UX: ícono ⓘ reactivo por opción (no embudo guiado de preguntas, no solo definiciones inline pasivas) | Confirmado por Paulina |
| 2 | Alcance: auditoría completa de las 27 opciones, no solo articulación/tendón/ligamento | Confirmado por Paulina |
| 3 | El origen de datos del ⓘ reusa el patrón `label_es`/`def_es` ya existente en `assets/symptom_definitions.json` (usado hoy por cefalea) en vez de construir un mecanismo nuevo | Propuesto, no contradicho |
| 4 | Red flags estructurales (ej. subluxación que no reduce, pérdida de sensibilidad/pulso distal) | Diferido a sprint aparte — no se cierra el schema dos veces |
| 5 | Mapeo HPO | Diferido — ver §12.6 |

### 12.4 Estructura de grupos — CERRADA (2026-07-16)

18 chips totales en 4 grupos, bajo el techo de 20 (Morren 2009, §2.7). Aplica a las 6 categorías de dolor: articulación, músculo, tendón, ligamento, nervio, y el nuevo "dolor sin causa estructural clara" (§12.5). **No aplica a tejido blando** — ver §12.6b, deferido a su propia ronda de diseño.

1. **Lateralidad** (4, single-select): Izquierda, Derecha, Ambas, Difuso/central — implementa el `BodySide` ya anticipado en el código.
2. **Carácter del dolor** (6, single-select): Agudo/punzante, Sensación de corte, Punzadas/eléctrico, Hormigueo, Sordo/difuso, Ardor. Confirmado por Paulina que "agudo/punzante" y "sensación de corte" son suficientemente distintos como para no fusionarse.
3. **Antecedente** (5, single-select): Post-ejercicio reciente, Post-esfuerzo diferido (ventana 24-72h, mismo patrón que PEM en Fatiga/Flare Mode), Por golpe/trauma, **Condición conocida/antigua** (post-quirúrgica o crónica — seleccionar esto dispara el flujo de guardar historial de zona de §12.6), Sin antecedente específico.
4. **Mecánica** (3, single-select): Empeora con movimiento, Presente en reposo también, Ambas — misma forma que el grupo "Patrón postural" ya usado en cefalea (§4.1.4).

**Atajo ("Ya sé qué es")**: no es un chip, reusa el mismo patrón de botón "Saltar" ya establecido como decisión transversal (§3, ítem 6) — salta directo al picker de los 20 términos de dolor existentes + el nuevo. No cuenta contra el techo de chips.

### 12.5 Nuevo `StructuralEventKind`: "dolor sin causa estructural clara"

Paulina describe un tipo de dolor recurrente sin antecedente identificable ("duele porque duele"), que no encaja en articulación/músculo/tendón/ligamento/nervio en el sentido clásico. Se decidió modelarlo como un 7º `StructuralEventKind` propio, no como un valor dentro del grupo "Antecedente" — reconoce que es clínicamente distinto (dolor central/difuso vs. lesión estructural localizada), no solo una variante de timing.

Nombre elegido: **"dolor sin causa estructural clara"** — se descartó el término informal de la usuaria ("dolor del síndrome") para evitar que el copy suene a que la app está confirmando un mecanismo diagnóstico no establecido. Aplica la misma regla de humildad epistémica ya codificada en este proyecto para advisories (§8.4, §10.6): describir el rasgo observable, no la interpretación clínica.

### 12.6 Antecedente estructural conocido (post-quirúrgico/crónico)

**Confirmado por Paulina (2026-07-16)**, motivado por un caso propio: dos cirugías de rodilla, con molestia crónica esperada cuya intensidad fluctúa día a día. Este caso es distinto de los tres ya cubiertos por la capa (lesión aguda nueva, DOMS, dolor sin causa estructural clara) — es una **cuarta categoría**: causa ya conocida y documentada, no algo que redescribir desde cero cada vez que duele.

Diseño:

1. **Historial estructural por zona** (nuevo, a nivel `Profile`, no por evento): entrada tipo "Rodilla derecha: post-quirúrgica (2 cirugías)" — zona + descripción libre + fecha aproximada opcional. Se registra una vez.
2. **Atajo de registro rápido para zonas con historial conocido**: si la zona ya tiene antecedente guardado, el registro salta lateralidad/carácter/antecedente/mecánica y va directo a severidad (0-4, escala ya existente) + un chip opcional "¿distinto a lo usual?" (peor que de costumbre / normal para mí / mejor).
3. **Opt-in en el momento, no solo desde ajustes**: al completar la funnel completa por primera vez en una zona, ofrecer un botón "guardar esto como algo que ya conozco" que crea la entrada de historial para la próxima vez.
4. **Implicación diferida para red flags** (cuando se retome §12.6-red-flags en sprint aparte): distinguir fluctuación normal de una condición conocida vs. un cambio agudo nuevo sobre esa misma zona (ej. hinchazón repentina fuera de patrón) es clínicamente más útil que tratar toda lectura igual — anotado aquí para no perderlo, sin diseñar todavía.

### 12.6b Tejido blando (heridas, quemaduras, hematomas) — hilo de diseño propio, deferido

**Decisión (2026-07-16):** tejido blando NO entra en el cierre de §12.4. Explícitamente no es "queda como está porque es autoevidente" — Paulina señaló que merece su propia ronda de diseño porque la piel cicatriza distinto, los hematomas duran más y duelen más que otras lesiones, y hay una conexión clínica real entre hematomas frecuentes/extensos y anemia que muchos médicos no reconocen.

**Verificación de citas (2026-07-16), corrigiendo una primera pasada demasiado conservadora:** Paulina compartió un reporte de Perplexity con 20 referencias; solo 2 son literatura primaria real, el resto son sitios de consumo/blogs/un post de Facebook, descartados por el mismo estándar de citas que ya aplica este proyecto (evitar hallucinations tipo NotebookLM — Perplexity corre el mismo riesgo).

- **De Paepe & Malfait 2004**, *British Journal of Haematology* 127(5):491-500, DOI 10.1111/j.1365-2141.2004.05220.x — hematoma fácil presente "en grado variable en todos los subtipos de EDS" por fragilidad capilar y del tejido conectivo perivascular.
- **Kumskova et al. 2023**, *J Thromb Haemost* 21(7):1824-1830, DOI 10.1016/j.jtha.2023.04.004 — ya citado en CLAUDE.md para MCAS (bruising/heavyBleeding, Sprint E). Paulina aportó el paper completo (no solo el abstract), lo que corrigió una primera lectura mía que subestimaba la severidad. Datos reales de la Tabla 2, cohorte n=52 EDS vs. 52 controles sanos:
  - 62% de pacientes EDS con score ISTH-BAT anormal (0% en controles sanos, p<.0001).
  - Sangrado cutáneo: 77% de pacientes lo reportan; de ellos, 16% "severo: extenso".
  - Hematomas musculares: 69% lo reportan; 13% de todos los EDS los tuvo "espontáneos, sin trauma" (la categoría más grave que mide el estudio).
  - Epistaxis: 50% lo reportan; 19% severa (taponamiento/cauterización), 4% con transfusión de sangre.
  - Menorragia: 62% (de pacientes mujeres); 14% "life-threatening" (requirió dilatación y curetaje, ablación endometrial, o histerectomía).
  - El paper concluye recomendando agregar síntomas de sangrado como criterio diagnóstico dado lo serio que puede llegar a ser — no es un síntoma menor/cosmético.
  - Dato específico relevante a la conexión con anemia: en el grupo de menorragia moderada, **32% de todas las pacientes EDS "requirió terapia hormonal o de hierro"** — tratamiento con hierro documentado en la cohorte, aunque ligado a menorragia, no a hematomas directamente, y el paper no mide hemoglobina/ferritina como resultado.

**Sobre la conexión hematomas→anemia específicamente:** ninguno de los dos papers reales mide anemia como resultado, y una búsqueda directa en PubMed de "Ehlers-Danlos + iron deficiency anemia + menorrhagia" no arrojó resultados indexados. La restricción original de CLAUDE.md (anemia/RDW-CV%, sin cita completa) se mantiene — Perplexity no la resuelve.

**Segunda ronda de research (2026-07-16), documento propio de Paulina, 12 referencias — calidad muy superior al reporte de Perplejidad (todo revistas peer-reviewed reales, sin blogs).** Verifiqué 2 de las 12 directamente:

- **Artoni et al. 2018**, *J Thromb Haemost* 16(12):2425-2431, DOI 10.1111/jth.14310, PMID 30312027 — confirmado: 41.7% de 141 pacientes EDS con score de sangrado (BSS) anormal, y de esos, **90% tenía al menos una anormalidad de función plaquetaria** (vía ADP), con relación dosis-respuesta (>3 anormalidades → OR 5.19). Coagulación estándar (PT/aPTT/factor von Willebrand) generalmente normal — el mecanismo dominante medible es plaquetario, no solo fragilidad vascular.
- **Gooijer et al. 2024**, *Orphanet J Rare Dis* 19(1):61, DOI 10.1186/s13023-024-03054-8, PMID 38347577 — confirmado: 42% de 195 adultos con osteogénesis imperfecta (OI) con Self-BAT anormal, sin diferencia significativa entre subtipos de OI. Prevalencia casi idéntica a la de EDS (41.7%).
- Las otras 10 (De Paepe & Malfait 2009 *Blood Reviews*, Jesudas 2019 *Haemophilia*, Velo-García 2016 *J Autoimmun*, Giannouli 2006 *Ann Rheum Dis*, Bertoli 2007 *Rheumatology*, Wielosz 2020 *Rheumatology*, Gooijer 2019 *BJH*, Wilson 2004 *Am J Med*, De Paepe & Malfait 2004 *BJH* — ya verificada, ver arriba — y Abdulla 2016 *Reumatismo*) no se verificaron una por una en esta sesión, pero el formato de cita es consistente y las dos verificadas coincidieron exactamente con lo reportado — confianza razonable, no verificación exhaustiva.

**Esto cambia el framing del advisory.** El mensaje principal ya no debería ser "posible anemia" — la evidencia real y EDS-específica apunta a **disfunción plaquetaria** como mecanismo medible (Artoni 2018), con anemia como una posibilidad secundaria razonable de mencionar (un hemograma es parte estándar de cualquier estudio de sangrado, así que no está de más nombrarlo, pero no es el hallazgo principal). Candidato de copy revisado: *"esto puede valer la pena conversarlo con tu médico — podría incluir evaluación de tendencia de sangrado (función plaquetaria, entre otras cosas que suelen revisarse)"*, nunca afirmando causa. Sigue la misma regla de humildad epistémica de §8.4/§10.6.

**El ISTH-BAT/Self-BAT generaliza más allá de EDS** — OI muestra prevalencia casi idéntica (42% vs 41.7%). Refuerza la idea de Paulina de adaptarlo (§ arriba), y sugiere que el diseño de esta capa no debería asumir EDS como única condición subyacente — las 56 condiciones de `condition_codes.json` incluyen otros trastornos del tejido conectivo a los que el mismo instrumento podría aplicar igual de bien.

**⚠️ Nota de alta prioridad, sin diseñar, para cuando se retomen red flags de tejido blando:** en EDS vascular (vEDS), el moretón excesivo es descrito en la literatura como frecuentemente "la primera señal presente" antes de ruptura arterial espontánea — potencialmente fatal, riesgo distinto en orden de magnitud a cualquier otro red flag ya diseñado en esta app. Cuando se diseñe la fase de red flags de tejido blando, vEDS (identificable vía `Profile.conditions`) necesita su propio tier de severidad, no puede tratarse con la misma vara que un hematoma post-quirúrgico común. Anotado aquí explícitamente para que no se pierda — no se diseña ahora porque red flags de tejido blando ya está diferido como decisión previa.

**Nota sensible, sin acción por ahora:** la literatura también menciona que en EDS pediátrico el moretón excesivo puede generar sospecha clínica de malignidad hematológica o maltrato infantil. Relevante para el futuro trabajo de Multi-Observer Profiles (ej. el caso de la ahijada de Paulina), donde datos longitudinales objetivos podrían en teoría ayudar a contextualizar el patrón — pero es territorio delicado que no se diseña sin que Paulina lo traiga explícitamente como prioridad.

**Candidato de diseño para cuando le toque turno a tejido blando:** advisory de "tendencia de hematomas" — si la frecuencia/extensión reciente supera el patrón habitual de la paciente, sugerir mencionarlo al médico con el copy revisado arriba (plaquetas primero, hemograma/anemia como mención secundaria), nunca afirmando causa. Requiere que tejido blando tenga primero su propio tracking de frecuencia/severidad por zona, idealmente usando las categorías/severidad del ISTH-BAT/Self-BAT en vez de inventar una escala 0-4 genérica. Todavía sin diseñar en detalle.

### 12.7 Grounding cualitativo adicional: encuesta general SED (no específica de ZebraUp)

Paulina compartió respuestas de una encuesta propia sobre comunicación médica en SED (2 respuestas al momento de esta conversación, Chile, ambas con hipermovilidad/hEDS sospechado o confirmado). No es una encuesta de uso de ZebraUp ni es representativa por tamaño de muestra — se usa aquí como grounding cualitativo, no como dato estadístico. Referenciadas de forma anónima (encuestada A/B), sin correos ni datos de contacto que sí aparecían en el archivo original.

- **Encuestada B (25, sin diagnóstico formal, barrera económica)**: reporta que médicos atribuyen su dolor a "falta de ejercicio". Refuerza directamente la motivación original de esta sección (§12.1) — separar dolor estructural genuino de DOMS no es solo higiene de datos interna, es munición real contra el descarte clínico de "solo necesitas moverte más". El historial estructural conocido (§12.6) apunta al mismo problema desde otro ángulo: evidencia longitudinal y específica por zona es más difícil de descartar que un reporte verbal aislado en consulta.
- **Encuestada B** también describe escribir manualmente "cartas" con ayuda de IA antes de sus consultas porque olvida todo en el momento — validación directa, independiente, del caso de uso de Fase 4 (exportación PDF clínica).
- **Encuestada A (39, hEDS confirmado genéticamente, 16 patologías)**: "Unir cabos, no verme por separado cada síntoma, eso hizo perder años" — valida la apuesta original de correlación cruzada entre síntomas (Sprint G, `symptom_pattern_detector.dart`). También señala un riesgo a vigilar: con muchas condiciones raras documentadas, condiciones comunes (en su caso, insuficiencia renal) pueden quedar de lado — no es una decisión de diseño todavía, queda como nota de vigilancia para cualquier feature futura de priorización o resumen automático.

### 12.8 Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| Tejido blando (heridas/hematomas) | Hilo de diseño propio — ver §12.6b. No confundir con "no importa": Kumskova 2023 (paper completo) confirma severidad real (hematomas espontáneos, sangrado severo, menorragia life-threatening en subconjuntos de la cohorte). La conexión específica hematomas→anemia sigue sin cita EDS-directa, pero el advisory de "tendencia de hematomas" (§12.6b) no depende de esa cita, solo de principio médico general. |
| Red flags estructurales | Se decidió expresamente no incluirlos en esta ronda — cerrar primero el modelo de captura (lateralidad/carácter/mecánica), evitar migrar el schema dos veces. Incluye la distinción de §12.6.4 (cambio agudo sobre condición conocida). |
| Mapeo HPO | Se agrupará con el mapeo de Dolor Pélvico (D.4) y probablemente Dolor Torácico (D.5), porque comparten vocabulario de "carácter del dolor". Pendiente confirmar si Presíncope (D.3) entra en ese lote — no comparte ese vocabulario por ser de otra naturaleza clínica. Mientras tanto, Paulina puede avanzar el mapeo de los 20 valores de dolor de `kStructuralTaxonomy` (excluyendo tejido blando, ver arriba) que ya son estables independientemente de esta capa nueva. |
| Relación exacta con `StructuralEvent` existente | Mayormente resuelta: la capa nueva convive con `StructuralEvent`, no lo reemplaza — el atajo ("Ya sé qué es") y el historial de zona (§12.6) son las dos vías de entrada rápida al mismo picker de 20 términos + el nuevo. Falta solo decidir el mecanismo de persistencia exacto (¿nuevo campo en `StructuralEvent` o modelo aparte vinculado?) al momento de implementar. |

## 13. Presíncope (D.3)

**Sprint completado:** 2026-07-17. Cuarta capa de detalle en el
roadmap (después de cefalea/C.4, fatiga/D.1, dolor abdominal/D.2).
Deliberadamente subjetiva únicamente — sin ningún componente de
medición activa.

### 13.1 Restricción explícita de Paulina

No construir `OrthostaticTest`/medición de dispositivo (NASA lean test
simplificado) en este pase. Esa pieza queda diferida a una versión
móvil, por seriedad clínica — una prueba de pie activa conlleva riesgo
real de síncope y merece más cuidado del que permite este entorno de
desarrollo. D.3 captura únicamente la experiencia subjetiva del
episodio: desencadenante, síntomas previos, cómo terminó, y
recuperación. Ver también `docs/design_decisions/vital_signs_panel.md`,
donde la misma prueba ortostática quedó pausada por la misma razón de
seguridad — este mismo argumento aplicó dos veces de forma
independiente, lo que refuerza que no es una preocupación puntual.

### 13.2 Grounding científico

Verificado en esta sesión, no asumido de memoria:

- **Brignole M et al. 2018** — ESC Guidelines for the diagnosis and
  management of syncope. *Eur Heart J* 39(21):1883–1948.
  DOI: 10.1093/eurheartj/ehy037. Es sobre síncope (pérdida de
  consciencia), no presíncope específicamente — su valor para D.3 es
  la taxonomía de mecanismos/triggers (reflejo-vasovagal / ortostático
  / cardíaco) y el principio de que ciertas características (esfuerzo,
  sin cambio postural, pérdida de consciencia real) son de mayor
  riesgo y ameritan evaluación médica.
- **Spahic JM et al. 2023 (MAPS, Malmö POTS Symptom Score)** — *J
  Intern Med* 293:91–99. DOI: 10.1111/joim.13566. Considerado y
  archivado para un futuro ítem de escala periódica en vez de usarse
  en esta capa: es un cuestionario autoadministrado de carga de
  síntomas con recall de 7 días (VAS 0-10), arquitectónicamente
  distinto del patrón evento-a-evento que usan C.4/D.1/D.2/D.3. Buen
  candidato futuro junto a PHQ-9/GAD-7/FIQR/Rand-36 (ver roadmap de
  Fase 5, escalas clínicas periódicas). Sin validación EDS-específica
  (solo menciona hipermovilidad de pasada) — mismo tipo de vacío ya
  documentado para hematomas→anemia en §12.6b, se anota igual.

### 13.3 Esquema final

4 grupos, 19 chips totales — dentro del techo de ≤20 de Morren 2009
(a diferencia de D.2, que lo excede deliberadamente):

| Grupo      | Kind          | Chips |
|------------|---------------|-------|
| mechanism  | single_select | 7     |
| prodrome   | multi_select  | 6     |
| outcome    | single_select | 3     |
| recovery   | single_select | 3     |

Chip serialization keys (estables entre releases):

- **mechanism**: `on_standing`, `prolonged_standing`, `situational`,
  `post_exertion`, `strong_emotion_or_pain`, `no_position_change`,
  `unidentified`
- **prodrome**: `tunnel_vision`, `ringing_ears`, `cold_sweat`,
  `nausea`, `paleness_noted`, `palpitations`
- **outcome**: `sat_or_lay_down`, `near_fall_no_loc`, `brief_loc`
- **recovery**: `fast`, `slow`, `tired_after`

A diferencia de `abdominal_pain` (donde el grupo `trigger` es singular
pero el campo Dart `triggers` es plural), los 4 grupos de presíncope
coinciden 1:1 con los nombres de campo de `PresyncopeDetail` — no hay
asimetría singular/plural que replicar aquí.

### 13.4 Red flags — V1 vs. V2

V1 se mantiene deliberadamente pequeño (1 urgent + 2 advisory), misma
disciplina de scope que C.4/D.1/D.2:

- **URGENT** (in-sheet, bloqueante pre-save, mismo patrón que la
  calidad "desgarro" de D.2): `briefLossOfConsciousness`, gateado por
  `outcome == briefLossOfConsciousness`. Sin gate de severidad — la
  aserción del usuario de haber perdido el conocimiento se confía
  igual que D.2 confía en la aserción de dolor tipo desgarro.
- **ADVISORY** (post-save, no bloqueante): `exertionalTrigger`
  (`mechanism == postExertion`) y `noPositionChangeTrigger`
  (`mechanism == noPositionChange`) — ambos features de riesgo de ESC
  2018, sin gate de severidad.

Candidatas a V2, post-datos de beta: reglas basadas en
frecuencia/recurrencia de episodios, y combinaciones de pródromo
(ej. palpitaciones + esfuerzo físico) — no incluidas en V1 por falta
de datos reales para calibrar los umbrales.

### 13.5 Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| `OrthostaticTest` / medición activa | Ver §13.1 — versión móvil, razón de seguridad (riesgo de síncope durante la prueba de pie). |
| Mapeo HPO | No comparte vocabulario de "carácter del dolor" con dolor pélvico/torácico (§12.8) — presíncope es de otra naturaleza clínica. Sin agrupar todavía. |
| MAPS como escala periódica | Archivado como candidato, no implementado — ver §13.2. |
| Reglas de red flag basadas en frecuencia/recurrencia | V2, post-datos de beta — ver §13.4. |

## 14. D.4 — Dolor pélvico

**Sprint completado:** 2026-07-17. Quinta capa de detalle en el
roadmap (después de cefalea/C.4, fatiga/D.1, dolor abdominal/D.2,
presíncope/D.3). Trauma-informed por diseño desde el backlog original
(CLAUDE.md) — es el dominio de contenido más sensible capturado por la
app hasta ahora, así que dos decisiones de contenido se confirmaron
explícitamente con Paulina antes de escribir el schema, en vez de
asumirlas por precedente de otras capas.

### 14.1 Decisiones trauma-informed confirmadas con Paulina

1. **Chip de dolor sexual (dispareunia).** ACOG lo considera un
   diferenciador clínico clave para endometriosis/vulvodinia, pero es
   el contenido potencialmente más sensible de toda la capa. Opciones
   presentadas: (a) incluirlo, con wording neutro y opcional, o (b)
   omitirlo de este v1 y diferirlo como hilo propio (mismo patrón que
   tejido blando se difirió en el rediseño estructural). Paulina eligió
   **incluirlo** — vive como un chip más dentro del grupo `triggers`
   ("con la actividad sexual"), multi-select, sin preguntas de
   seguimiento, mismo gating opt-in que el resto de la capa.
2. **Wording del chip de ubicación externa.** Opciones presentadas:
   registro clínico-neutro (ej. "zona genital externa", igual que
   `AbdominalLocation` usa "hipogástrico") vs. registro suave/cotidiano
   que evita incluso la palabra "genital". Paulina eligió el registro
   **suave/cotidiano** — el chip final dice "Por fuera, en la zona
   íntima", consistente con el precedente de D.1 fatiga, donde wording
   clínico-duro también se rechazó a favor de lenguaje más gentil.

### 14.2 Grounding clínico

Verificado en esta sesión vía WebSearch, no asumido de memoria:

- **ACOG Practice Bulletin No. 218 — Chronic Pelvic Pain.** *Obstet
  Gynecol* 2020;135(3):e98–e109. DOI: 10.1097/AOG.0000000000003716.
  Fundamenta: la distinción cíclico/acíclico que estructura el grupo
  `timing`; dolor de inicio súbito y muy intenso como señal de alarma
  (torsión anexial, rotura de embarazo ectópico) que fundamenta el
  chip `sudden_severe_onset` y su red flag URGENT in-sheet; fiebre +
  dolor pélvico como señal de posible infección pélvica (red flag
  URGENT post-save).
- **assets/zebra_wisdom.json** ("Pelvic Floor & EDS", "Pelvic Floor &
  Dysautonomia") — no es literatura peer-reviewed nueva, pero ya vivía
  en el repo y fundamenta el chip `pelvic_floor_tension` y su advisory
  correspondiente (piso pélvico hipertónico en hipermovilidad /
  espasmo involuntario por disautonomía).

### 14.3 Esquema final

5 grupos, 23 chips totales — excede el techo de ≤20 de Morren 2009,
mismo tipo de desviación deliberada que D.2 abdominal (22 chips). Por
lo indicado en §10.3, esta nota formaliza la desviación como patrón de
dominio repetido en vez de tratar cada caso como excepción aislada: **a
partir de D.2, un síntoma cuyo espacio clínico real requiere más
granularidad que el techo de Morren puede excederlo, siempre que la
capa mantenga divulgación progresiva/opcionalidad total (nada
obligatorio) y la desviación quede documentada aquí con el número
exacto de chips.**

| Grupo          | Kind          | Chips |
|----------------|---------------|-------|
| location       | single_select | 5     |
| character      | single_select | 5     |
| timing         | single_select | 3     |
| triggers       | multi_select  | 5     |
| accompaniments | multi_select  | 5     |

Chip serialization keys (estables entre releases):

- **location**: `lower_abdomen`, `deep_central`, `external_intimate`,
  `low_back_tailbone`, `radiating_legs_groin`
- **character**: `cramping`, `burning`, `pressure_heaviness`,
  `sharp_stabbing`, `sudden_severe_onset`
- **timing**: `with_period`, `mid_cycle`, `no_cycle_pattern`
- **triggers**: `with_bowel_movement`, `with_bladder_fullness`,
  `prolonged_sitting`, `physical_activity`, `sexual_activity`
- **accompaniments**: `bloating`, `urinary_urgency_frequency`,
  `bowel_changes`, `pelvic_floor_tension`, `abnormal_bleeding`

El chip `no_cycle_pattern` incluye explícitamente "o no aplica" en su
copy para no forzar un marco menstrual a pacientes que no menstrúan
(regla de copy neutro en género de CLAUDE.md). Los 5 grupos coinciden
1:1 con los nombres de campo de `PelvicPainDetail` — mismo patrón sin
asimetría singular/plural que D.3 presíncope (a diferencia de D.2
abdominal, donde el grupo JSON `trigger` es singular pero el campo
Dart `triggers` es plural).

### 14.4 Red flags — V1 vs. V2

V1 tiene 1 in-sheet urgent + 2 post-save urgent + 2 post-save advisory
— más grande que D.3 (1+0+2) pero comparable a D.2 (1+2+2), reflejando
que el espacio clínico de dolor pélvico agudo tiene más vías de
emergencia reales que presíncope:

- **URGENT in-sheet** (bloqueante pre-save, mismo patrón que la
  calidad "desgarro" de D.2): `suddenSevereOnset`, gateado por
  `character == suddenSevereOnset`. Sin gate de severidad — misma
  lógica de "confiar en la aserción cualitativa del usuario" que D.2 y
  D.3 ya establecieron.
- **URGENT post-save**: `abnormalBleedingUrgent`
  (`abnormalBleeding` + severidad ≥ 3, compound gate igual que la
  hematoquecia masiva de D.2) y `feverUrgent` (fiebre registrada el
  mismo día + severidad ≥ 2 — gate más bajo porque la fiebre misma es
  la señal de alarma, no la intensidad del dolor).
- **ADVISORY post-save**: `bladderPatternAdvisory` (trigger de vejiga
  llena o accompaniment de urgencia/frecuencia urinaria) y
  `pelvicFloorTensionAdvisory` (accompaniment de tensión/espasmo del
  piso pélvico).

`feverUrgent` reusa `Profile.getFeverForDay()`, ya existente para
`FeverReading`, en vez de duplicar un chip de fiebre dentro de esta
capa — el mismo patrón de reuso de datos ya trackeados que el proyecto
prefiere sobre pedir la misma información dos veces.

Candidatas a V2, post-datos de beta: reglas de severidad/recurrencia
del patrón cíclico (ej. dolor severo repetido con la menstruación como
posible indicador de endometriosis) — evaluadas para V1 y descartadas
por ser demasiado presuntivas de diagnóstico para un solo evento; mejor
candidato para una regla de `correlation_engine.dart` con datos
longitudinales reales que para un red flag de evento único.

### 14.5 Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| Integración bidireccional con tracking menstrual | El tracker de menstruación no existe todavía en el código — candidato solo cuando exista (mismo principio que `linkedBowelEventId` de D.2 se construyó porque `BowelEvent` ya existía). |
| Mapeo HPO | Se agrupará con D.5 torácico — comparten vocabulario de "carácter del dolor" (§12.8), a diferencia de D.3 presíncope. |
| Regla de severidad/recurrencia cíclica como red flag | Ver §14.4 — mejor candidato para `correlation_engine.dart` con datos longitudinales que para un red flag de evento único. |
| Escala periódica validada (ej. adaptación de un instrumento de dolor pélvico crónico) | No evaluada en este pase — mismo tipo de item que MAPS quedó archivado para D.3 (§13.2), sin tiempo de research dedicado aquí. |

## 15. D.5 — Dolor torácico

**Sprint completado:** 2026-07-17 (misma fecha que D.4, sesión separada). Sexta y última
Symptom Detail Layer del roadmap original — cierra la cobertura 6 de 6. El síntoma de mayor
riesgo real que captura la app: el dolor de pecho en esta población abarca desde
costocondritis/síndrome de Tietze benigno y muy frecuente (laxitud de las articulaciones
costocondrales, ya documentado en `assets/condition_codes.json`) hasta dos emergencias reales
— síndrome coronario agudo (riesgo poblacional general, no específico de EDS) y, para el
subconjunto de pacientes con EDS vascular (vEDS), disección o rotura arterial.

### 15.1 Decisión confirmada con Paulina: primera rama de red flag condicionada por `Profile.conditions`

`assets/condition_codes.json` (entrada de Tietze, ya existente) advierte explícitamente: "Dolor
torácico nuevo siempre merece descartar causas cardíacas primero... no asumas que 'es solo
Tietze' sin evaluación." Y §12.6b de este mismo documento (diseño de tejido blando) ya había
identificado que vEDS "necesita su propio tier de severidad, no puede tratarse con la misma
vara" — pero lo dejó diferido.

Se confirmó con Paulina, antes de diseñar los red flags: **construir esa rama ahora, para
D.5.** Cuando el chip de carácter "desgarro" dispara el diálogo de emergencia in-sheet, el
cuerpo del texto se selecciona según si `Profile.conditions` contiene alguna coincidencia de
palabra clave para vEDS (`veds`, `vascular eds`, `vascular ehlers` — mismas tres substrings ya
usadas por `domainsForUserCondition` en `lib/services/condition_labels.dart:217-239`, aplicadas
sobre texto en minúsculas). Si hay coincidencia, el texto es específico a vEDS (evitar
compresiones torácicas si es posible, estudios de imagen —RM o TC— cruciales); si no, texto
general poblacional. Es la primera vez que un red flag de esta app cambia su copy según el
perfil clínico del paciente — implementado en `isLikelyVEDSFromConditions()`
(`lib/services/chest_pain_red_flags.dart`), reusado por el sheet
(`lib/widgets/chest_pain_detail_sheet.dart`) sin necesidad de pasarle el `Profile` completo —
recibe solo `profileConditions: List<String>`, manteniendo el sheet desacoplado del modelo
igual que el resto de las capas de detalle.

Limitación conocida y documentada explícitamente en el código: `Profile.conditions` es texto
libre, no un campo de diagnóstico validado (decisión de diseño deliberada, ver Coussens 2022 —
no forzar clasificación hEDS/HSD). Una paciente vEDS que no haya escrito "vEDS" o lo haya
escrito de forma distinta no activará la rama específica. Es un heurístico, igual que su uso
ya existente en `condition_labels.dart` para enrutar contenido del compendio.

### 15.2 Grounding clínico (verificado vía WebSearch en esta sesión)

- **Gulati M et al. 2021** — AHA/ACC/ASE/CHEST/SAEM/SCCT/SCMR Guideline for the Evaluation and
  Diagnosis of Chest Pain. *Circulation* 2021;144:e368–e454.
  DOI: 10.1161/CIR.0000000000001029. Es el framework ya nombrado en CLAUDE.md y en §6 de este
  documento como "AHA/ACC 2021" para D.5. Fundamenta los rasgos de riesgo cardíaco compuestos:
  presión/opresión, irradiación a brazo/mandíbula/espalda, disparador de esfuerzo,
  acompañantes de disnea/sudoración/náusea.
- **Isselbacher EM et al. 2022** — ACC/AHA Guideline for the Diagnosis and Management of
  Aortic Disease. *Circulation* 2022. DOI: 10.1161/CIR.0000000000001106. Cubre explícitamente
  el EDS vascular como una enfermedad aórtica torácica heredable sindrómica — fundamenta la
  rama vEDS-específica de §15.1 y el chip `upper_back_between_shoulder_blades` (patrón de
  irradiación interescapular, clásico de disección).
- **`assets/zebra_wisdom.json`** (ya existente, condición "vEDS Emergency Preparedness"): dos
  hechos reusados verbatim como base del texto vEDS-específico — evitar compresiones torácicas
  si es posible (fuente: American Medical ID) y RM/TC cruciales ante dolor torácico o abdominal
  súbito y severo en vEDS (fuente: The VEDS Movement).

### 15.3 Esquema final

4 grupos, 21 chips totales — excede el techo de ≤20 de Morren 2009, misma desviación deliberada
ya formalizada en §10.3 (aplicada también en D.2 con 22 y D.4 con 23):

| Grupo          | Kind          | Chips |
|----------------|---------------|-------|
| location       | single_select | 5     |
| character      | single_select | 5     |
| triggers       | multi_select  | 5     |
| accompaniments | multi_select  | 6     |

Chip serialization keys (estables entre releases):

- **location**: `retrosternal_central`, `left_sided`, `right_sided`, `costal_margin`,
  `upper_back_between_shoulder_blades`
- **character**: `pressure_or_tightness`, `sharp_or_stabbing`, `burning`,
  `aching_worse_with_pressing` (diferenciador de costocondritis — sensibilidad reproducible a
  la palpación), `tearing_or_ripping` (gate del red flag URGENT in-sheet)
- **triggers**: `worse_with_breathing_or_movement`, `worse_with_pressing_on_area`,
  `worse_with_exertion`, `after_eating_or_lying_down`, `no_clear_trigger`
- **accompaniments**: `shortness_of_breath`, `radiates_to_arm_jaw_back`,
  `sweating_or_clamminess`, `nausea_or_vomiting`, `palpitations_or_racing_heart` (relevante por
  la comorbilidad de POTS/disautonomía en esta población), `feeling_faint_or_dizzy`

Los 4 grupos coinciden 1:1 con los nombres de campo de `ChestPainDetail` — mismo patrón sin
asimetría singular/plural que D.3/D.4. No incluye un grupo de relación temporal con el ciclo
(no aplica clínicamente al dolor torácico).

### 15.4 Red flags — 6 condiciones, más que cualquier capa anterior

Confirmando explícitamente la nota "múltiples red flags esperadas" del backlog: 1 URGENT
in-sheet + 2 URGENT post-save + 3 ADVISORY post-save — más que D.2 y D.4 (5 cada una).

- **URGENT in-sheet**: `tearingOrRipping` (`character == tearingOrRipping`), sin gate de
  severidad — mismo "confiar en la aserción cualitativa del usuario" que D.2/D.4. Copy
  bifurcada por `isLikelyVEDSFromConditions()` (ver §15.1).
- **URGENT post-save**: `possibleCardiacPatternUrgent` (`pressureOrTightness` + al menos uno
  de irradiación a brazo/mandíbula/espalda, disnea, o sudoración + severidad ≥ 2 — combinación
  de riesgo anginal de AHA/ACC 2021) y `exertionalPatternUrgent` (disparador de esfuerzo + al
  menos uno de disnea o palpitaciones + severidad ≥ 2).
- **ADVISORY post-save**: `pleuriticPatternAdvisory` (punzante + empeora con respiración/
  movimiento + severidad ≥ 2 — diferencial de pericarditis/neumotórax/embolia pulmonar, menos
  urgente que los patrones anteriores pero igual de mención médica), `palpitationsPatternAdvisory`
  (palpitaciones/corazón acelerado + severidad ≥ 2, independiente del gate exertional — ambos
  pueden dispararse a la vez legítimamente), `refluxPatternAdvisory` (ardor + después de comer
  o al acostarse + severidad ≥ 2).

**Control de fatiga de alarma por taxonomía de chips, no por un sistema de historial/quick-log
nuevo**: la presentación benigna común de costocondritis (`achingWorseWithPressing` +
`worseWithPressingOnArea`/`worseWithBreathingOrMovement`) no satisface ningún gate urgente ni
advisory — una paciente con costocondritis recurrente conocida no dispara ningún diálogo en
sus registros habituales. No se replicó el patrón de historial de zona de dolor estructural
(§12.6) porque D.5 no tiene la forma zona/tipo que motivó esa feature — es un síntoma único,
misma categoría que headache/fatigue/abdominal/presyncope/pelvic_pain.

### 15.5 Cierre del mapeo HPO diferido (§12.8)

Con D.5 shippeado, las tres capas que comparten vocabulario de "carácter del dolor"
(estructural, D.4 pélvico, D.5 torácico) están todas completas — el mapeo HPO agrupado que
§12.8, §13.5 y §14.5 dejaban pendiente puede evaluarse como un lote único cuando se retome,
sin bloqueos adicionales de implementación.

### 15.6 Decisiones diferidas / abiertas

| Ítem | Razón de diferir |
|------|-------------------|
| Integración bidireccional con tracking de actividad física | `MovementMetric` ya existe (Fase 6), pero no se construyó el link en este pase — mismo principio de "construir el FK solo cuando hay tiempo dedicado a diseñarlo bien", no una limitación técnica. |
| Mapeo HPO | Ver §15.5 — las tres capas candidatas ya están completas, listo para evaluarse como lote. |
| Regla de frecuencia/recurrencia de costocondritis vs. patrón nuevo como distinción explícita | Evaluada y descartada para v1 — la taxonomía de chips ya evita el disparo de diálogos en la presentación benigna común (§15.4), sin necesitar tracking de historial. Reconsiderar solo si datos de beta muestran que no es suficiente. |
| Rama vEDS-consciente extendida a otros red flags (no solo `tearingOrRipping`) | Fuera de alcance de este pase — `isLikelyVEDSFromConditions()` queda como función pública reusable en `chest_pain_red_flags.dart` si se decide extenderla a otras capas o red flags en el futuro. |
