# ROADMAP — ZebraUp

Documento de dirección: qué está shippeado (resumen, no exhaustivo), qué sigue de verdad, y qué está en el backlog. Reemplaza a `docs/PHASE_5_ROADMAP.md` y `docs/phase_5_roadmap-3.md` (archivados en `docs/archive/`, ver nota al final).

**Lo que este documento NO es:**
- No es un historial de sesiones → eso vive en `CHANGELOG.md`.
- No es el detalle de convenciones/arquitectura/estado campo-por-campo → eso vive en `CLAUDE.md`.
- No es el razonamiento ni las citas detrás de una decisión de diseño → eso vive en `docs/design_decisions/` y `docs/eds_research_notes.md`.

Si algo en `docs/` (planning) contradice el código real en `lib/`, el código manda — regla ya adoptada en `CLAUDE.md`.

---

## Snapshot: qué está shippeado

- **Sprint F (Acciones Transversales)** — completo (F.A–F.F).
- **Sprint E (MCAS/Alergias)** — completo (E.A–E.E).
- **Sprint G (Flare Mode)** — completo (G.A/G.B/G.B.2/G.C/G.E). G.D diferido a propósito, pendiente de datos de beta.
- **Symptom Detail Layers** — 6 de 6 síntomas, completo: Cefalea (C.4), Fatiga (D.1), Dolor Abdominal (D.2), Presíncope (D.3, sin componente de medición — ver `docs/design_decisions/symptom_detail_layers.md` §13), Dolor Pélvico (D.4, trauma-informed, wording suave para ubicación externa, chip de dispareunia opcional — ver §14), Dolor Torácico (D.5, primera rama de red flag condicionada por `Profile.conditions` — copy vEDS-específica ante dolor tipo desgarro — ver §15). Dolor estructural (rediseño, no uno de los 6) implementado con historial de zona, flujo combinado zona+tipo, y tejido blando (sangrado/hematomas) con severidad tipo ISTH-BAT.
- **Fase 6 (GI/sleep/hydration/HRV/movement)** — modelos, formularios y toggles ya shippeados (6.0/6.1/6.1b/6.1c, 6.6-6.7 parcial). El motor de correlación (`correlation_engine.dart`) es solo scaffold — sin reglas concretas todavía.
- **Fase 4 (PDF Clinical Export)** — Phase4.A–D completos, confirmado que compila.
- **Sprint P.C (Reorganización de Settings)** — completo, 5 subpantallas dedicadas.
- **Cuadros temporales (Episode)** — nuevo, shippeado 2026-07-21: diagnósticos agudos-pero-no-crónicos (resfrío, amigdalitis, gastritis) que agrupan varios síntomas relacionados, distinto de `conditions` (permanente) y `LifeEvent` (sin síntomas vinculados). Vínculo manual desde el sheet de síntomas (con creación rápida inline), gestión completa en Ajustes → Perfil, agrupación en el Reporte in-app y el PDF clínico. Primera sesión con `flutter analyze`/`flutter build web` reales disponibles en este entorno — ambos verificados limpios; sin probar clic-a-clic en navegador todavía, y el naming de UI ("Cuadro"/"Cuadro temporal") es una propuesta de Claude pendiente de confirmar. Ver ítem #2 de "Ahora mismo" abajo.
- **Baúl de síntomas: búsqueda + A-Z, y continuación same-day** — nuevo, shippeado 2026-07-22. Búsqueda/orden A-Z en el Baúl (mismo patrón ya usado en Botiquín, ahora extraído a widgets compartidos `SearchField`/`SortToggleButton`). Un síntoma que se vuelve a registrar el MISMO día (mejora sin llegar a resolverse, empeora, o se marca resuelto) actualiza el registro de hoy en vez de duplicarlo — `SymptomEvent.resolvedAt`/check-in nuevo, alcance deliberadamente acotado a same-day (a diferencia del check-in cross-day que ya existía para dolor estructural) para no fusionar silenciosamente episodios de días distintos de síntomas naturalmente recurrentes (fatiga, náuseas). Primera sesión que corrió `flutter gen-l10n` real (no edición a mano de los `.dart` generados). `flutter analyze`/`flutter build web` limpios, **compilación confirmada por Paulina**; sin probar clic-a-clic en navegador todavía.
- **Diseñados, sin sprint asignado todavía:** Multi-Observer Profiles, Panel de Signos Vitales.

Detalle campo-por-campo de todo esto: ver `CLAUDE.md`.

---

## Cómo se prioriza

Cuatro criterios, evaluados en Alto/Medio/Bajo — no para producir un puntaje falsamente preciso, solo para que "qué sigue" sea una decisión razonada y comparable, no orden de llegada ni lo último que se conversó:

| Criterio | Pregunta |
|---|---|
| **Riesgo si no se hace** | ¿Qué se acumula o se rompe silenciosamente mientras esto espera? |
| **Impacto clínico/paciente** | ¿A cuántos testers afecta, o qué tan seguido se topan con esto? |
| **Bloquea otro trabajo** | ¿Hay algo downstream (backlog o diseño) esperando esto? |
| **Esfuerzo** | ¿Es una sesión o es un sprint? |

Un ítem con Riesgo alto + Esfuerzo bajo siempre gana, incluso sobre algo de mayor impacto — es la fruta más barata de bajar. Un ítem que Bloquea otro trabajo sube de prioridad aunque su propio impacto sea modesto, porque su costo real es el trabajo detenido detrás.

Al mover algo de Backlog a "Ahora mismo", pasarlo por esta tabla — no hace falta para todo el backlog, solo para lo que se está por decidir trabajar.

---

## Ahora mismo / lo que sigue

**Resuelto 2026-07-17:** "Verificación con toolchain real" — Paulina confirmó que ya compiló todo y funciona bien (fuera de este entorno, que no tiene Flutter local). Este documento y el deploy log habían asumido que v2.3.4 salió sin verificar; era incorrecto, corregido aquí y en `CHANGELOG.md`/`CLAUDE.md`. Sale de la lista.

| # | Ítem | Riesgo si no se hace | Impacto | Bloquea | Esfuerzo |
|---|---|---|---|---|---|
| 1 | Sprint S1 (QA Beta) | Medio — bugs de UX/edge-case sin descubrir | Alto — superficie F+E+G completa | — | Alto — 8 sesiones de 30-60 min |
| 2 | Cuadros temporales (Episode) + Baúl de síntomas (búsqueda/A-Z, continuación same-day) — validar en navegador + confirmar naming | Medio — dos features nuevas (07-21 y 07-22) con flujos no triviales (dropdown con creación inline; gate de check-in same-day) probadas solo con `flutter analyze`/`build web`, nunca clic a clic | Medio — features nuevas; no bloquean nada existente si algo falla | — | Bajo — una sesión de click-through + una pregunta de naming |
| 3 | Panel de Signos Vitales — prueba ortostática | Bajo — nada roto, solo diseño pausado | Medio — subset POTS/dysautonomía | Resto del panel (fiebre/HRV/presión ya podrían avanzar independientemente) | Medio — decisión de diseño + luego build |
| 4 | Contactos de emergencia sin UI | Bajo | Bajo — feature menor, ya diferida por Paulina | — | Bajo |

1. **Sprint S1 (QA Beta) en curso.** Checklist manual de `docs/sprint_s1_testing_checklist.md` sobre la superficie combinada F+E+G — 8 sesiones, aún sin completar. Ahora que la compilación está confirmada y v2.3.4 está en producción, es el ítem con mayor impacto real pendiente — el esfuerzo alto (8 sesiones) es el costo, no una razón para evitarlo.
2. **Cuadros temporales (Episode) + Baúl de síntomas — validar en navegador + confirmar naming.** Episode shippeado 2026-07-21 (modelo, CRUD en Ajustes, vínculo manual desde Síntomas, agrupación en Reporte/PDF, 17 claves ARB en es/en/zh); búsqueda/A-Z del Baúl + continuación same-day de síntomas shippeado 2026-07-22 (`SymptomEvent.resolvedAt`/check-in, 8 claves ARB). Ambas corrieron `flutter analyze`/`flutter build web` reales y limpios (la del 07-22 además corrió `flutter gen-l10n` real por primera vez) — pero ningún flujo interactivo de ninguna de las dos se probó en un navegador real: abrir el dropdown de cuadros y crear uno inline, tocar dos veces el mismo síntoma el mismo día y confirmar que abre el check-in en vez de duplicar, verificar que el toggle A-Z persiste. Súbelo sobre el Panel de Signos Vitales y Contactos de emergencia porque es esfuerzo bajo sobre código recién escrito, no por mayor impacto de fondo. Incluye una decisión chica pendiente: el nombre de UI de Cuadros ("Cuadro"/"Cuadro temporal") lo propuso Claude, no Paulina.
3. **Panel de Signos Vitales — retomar la prueba ortostática.** Diseño pausado explícitamente a pedido de Paulina en el punto de seguridad (riesgo de síncope de pie). Sube en la lista pese a impacto/riesgo modestos porque bloquea el resto del panel — aunque, notar que fiebre/HRV/presión arterial podrían desacoplarse y avanzar sin esperar resuelto ese punto, si Paulina prefiere no decidir la parte ortostática todavía.
4. **Contactos de emergencia sin UI.** `Profile.emergencyContacts` existe desde Phase4.A, usado en la tarjeta de emergencia del PDF, pero no tiene pantalla de edición. Último por diseño: bajo en los cuatro criterios. Diferido explícitamente por Paulina el 2026-07-13 — retomar cuando ella lo pida.

---

## Backlog (sin orden estricto)

### Trabajo relacionado a Symptom Detail Layers (las 6 capas ya están completas)
- **Mapeo HPO** — estructural, D.4 pélvico y D.5 torácico comparten vocabulario de "carácter del dolor" y ya están todos shippeados, listos para evaluarse como lote único; D.3 (Presíncope) no comparte ese vocabulario y no entra en ese lote (confirmado, ver §13.5/§15.5 de `symptom_detail_layers.md`).
- **Red flags estructurales** (incluye el tier de riesgo vEDS por ruptura arterial) — diferidos a propósito hasta cerrar el modelo de captura.
- **Advisory de tendencia de hematomas** — depende de la capa de tejido blando, que ya existe; el advisory en sí no se ha construido.

### Fase 6 — profundización
- Motor de correlación v1/v2 con reglas concretas (6.4/6.9) — hoy solo scaffold.
- Anti-features de movimiento: sin streaks, envelope band real, sugeridor de progresión de calistenia (6.5/6.8).
- Contenido "Compendio" (tarjetas educativas GI/sleep/hydration/HRV) — no confirmado si existe como sección en el código actual; verificar antes de diseñar más sobre esa base.
- Pase de revisión trauma-informado transversal completo (6.10) — el toggle "modo cuidadoso" ya existe y está wireado; el pase de revisión en sí no está confirmado como completo.
- Corrección de tránsito/distensión GI (mecánica de dolor GI + banner de distensión) — no confirmado en la última auditoría.

### Otras líneas de trabajo diseñadas, sin sprint
- **Multi-Observer Profiles** — bloqueado en la decisión de arquitectura de sync (backend cifrado / CRDT P2P / export-import manual). Recomendación ya tomada: shippear export/import manual (Opción C) primero como v1/proof-of-concept, ~2 semanas estimadas.
- **Correlación con clima (weather)** — esperando acumular ~60 días de datos de beta antes de que tenga sentido estadístico.

### Cuadros temporales (Episode) — posibles v2
- **Vínculo retroactivo** — hoy un síntoma solo puede vincularse a un cuadro al registrarlo o editarlo uno por uno; no hay forma masiva de vincular varios síntomas ya registrados a un cuadro creado después (el caso real que motivó la feature: Paulina reconociendo a mitad de un cuadro que varios días de síntomas sueltos eran, en realidad, la misma amigdalitis). Evaluar si se necesita según uso real, no construir por adelantado.
- **Cuadros recurrentes vinculados entre sí** (ej. "3ª amigdalitis este año") — hoy cada cuadro es independiente, sin relación con instancias anteriores del mismo título.

### Localización
- **Strings hardcodeados sin l10n (investigado 2026-07-18, sin ítem propio en este roadmap hasta ahora)** — 9 archivos completos sin ninguna integración de l10n (`mcas_detail_sheet.dart`, `flare_control.dart`, `flare_suggestion_banner.dart`, `action_effectiveness_dialog.dart`, `retro_symptom_dialog.dart`, `pdf_export_sheet.dart`, `action_taken_sheet.dart`, `life_event_form_sheet.dart`, `beta_access_screen.dart`), más gaps parciales en 3 archivos ya integrados, más helpers de tiempo relativo duplicados en ~8 archivos más. Inventario ya hecho — ver `CLAUDE.md` sesión 2026-07-18, retomar directamente en vez de re-descubrirlo. `report_view.dart` y `pdf_export_sheet.dart` siguen sin l10n después de la sesión de Cuadros temporales del 07-21 (que agregó texto nuevo ahí siguiendo la convención hardcoded ya existente de esos dos archivos en vez de mezclar una localización parcial) — de los 9+ archivos listados, estos dos son los que más urgen si se retoma esto, por ser los que reciben contenido nuevo con más frecuencia.
- **pt-BR** — esperando disponibilidad de la colaboradora de Paulina para el ARB. Sin trabajo de código iniciado.
- **README_es.md** — pase de traducción independiente pendiente, no auto-traducción.
- **Corrección clEDS en README_en.md** — dice "classical EDS", debe decir "classic-like EDS (clEDS)". Pendiente, a criterio de timing de Paulina.

### Otros
- **Mobile deployment** — track separado, ~1 semana de config, no bloquea nada de lo anterior.
- **Reportes médicos (labs/MRI/X-Ray como adjuntos)** — pospuesto explícitamente hasta tener datos de beta-testers y poder publicar/generar revenue. Sin diseño todavía.
- **TZP (The Zebra Project) export interoperability** — depende de Fase 4 (ya lista) + que TZP documente su schema públicamente + flujo de consentimiento para que datos salgan del dispositivo.
- **Escalas clínicas estandarizadas** (PHQ-9, GAD-7, FIQR, Rand-36) como prompts periódicos opcionales — diferido.
- **Phase4.F** — persistencia de `PdfExportPreferences` en Hive.
- **Tensión RWE/B2B vs. local-first** — monetizar exponiendo datos agregados tensiona con la arquitectura local-first; evaluar solo post-lanzamiento, no antes.

---

## Explícitamente fuera de alcance

Decisiones ya tomadas, con rationale completa en `CLAUDE.md` § "Exclusiones" y `docs/competitive_analysis-2.md`:

- Tracker dedicado de PTSD/C-PTSD, texto libre narrativo de trauma, biofeedback durante crisis de pánico.
- Gamificación de movimiento (streaks, metas fijas).
- UI de BSS basada en foto (el campo `photoPath` existe en el modelo, sin UI).
- Push notifications en web (espera a mobile).
- HRV basada en sensor (espera a mobile).
- Community/social features, insights agregados cross-user (requieren backend — fuera del compromiso local-first).

---

## Documentos relacionados

- `CHANGELOG.md` — historial de desarrollo, fechado sesión por sesión, incluye el log de deploys reales.
- `CLAUDE.md` — convenciones de código/copy, arquitectura de datos, estado detallado campo-por-campo.
- `docs/design_decisions/` — razonamiento y citas académicas por decisión de diseño (symptom_detail_laters.md, vital_signs_panel.md, multi_observer_profiles.md).
- `docs/eds_research_notes.md`, `docs/competitive_analysis-2.md`, `docs/business_strategy_notes.md` — grounding clínico y de mercado.
- `docs/sprint_s1_testing_checklist.md` — checklist de QA manual en curso.

---

## Cómo mantener este documento

- Actualizar "Ahora mismo / lo que sigue" cada vez que algo se shipea, se reprioriza, o queda bloqueado.
- Mover ítems de Backlog a "Ahora mismo" cuando pasan a ser trabajo activo — no al revés sin razón explícita.
- No reproducir aquí detalle de sesión-a-sesión — eso es trabajo de `CHANGELOG.md`.
- Si un doc en `docs/` queda desactualizado respecto al código, corregir el doc (o archivarlo), no dejar la contradicción.

**Última actualización:** 2026-07-21.
