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
