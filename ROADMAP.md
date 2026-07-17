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
- **Symptom Detail Layers** — 5 de 6 síntomas: Cefalea (C.4), Fatiga (D.1), Dolor Abdominal (D.2), Presíncope (D.3, sin componente de medición — ver `docs/design_decisions/symptom_detail_layers.md` §13), Dolor Pélvico (D.4, trauma-informed, wording suave para ubicación externa, chip de dispareunia opcional — ver §14). Dolor estructural (rediseño, no uno de los 6) implementado con historial de zona, flujo combinado zona+tipo, y tejido blando (sangrado/hematomas) con severidad tipo ISTH-BAT.
- **Fase 6 (GI/sleep/hydration/HRV/movement)** — modelos, formularios y toggles ya shippeados (6.0/6.1/6.1b/6.1c, 6.6-6.7 parcial). El motor de correlación (`correlation_engine.dart`) es solo scaffold — sin reglas concretas todavía.
- **Fase 4 (PDF Clinical Export)** — Phase4.A–D completos, confirmado que compila.
- **Sprint P.C (Reorganización de Settings)** — completo, 5 subpantallas dedicadas.
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
| 2 | Panel de Signos Vitales — prueba ortostática | Bajo — nada roto, solo diseño pausado | Medio — subset POTS/dysautonomía | Resto del panel (fiebre/HRV/presión ya podrían avanzar independientemente) | Medio — decisión de diseño + luego build |
| 3 | Contactos de emergencia sin UI | Bajo | Bajo — feature menor, ya diferida por Paulina | — | Bajo |

1. **Sprint S1 (QA Beta) en curso.** Checklist manual de `docs/sprint_s1_testing_checklist.md` sobre la superficie combinada F+E+G — 8 sesiones, aún sin completar. Ahora que la compilación está confirmada y v2.3.4 está en producción, es el ítem con mayor impacto real pendiente — el esfuerzo alto (8 sesiones) es el costo, no una razón para evitarlo.
2. **Panel de Signos Vitales — retomar la prueba ortostática.** Diseño pausado explícitamente a pedido de Paulina en el punto de seguridad (riesgo de síncope de pie). Sube en la lista pese a impacto/riesgo modestos porque bloquea el resto del panel — aunque, notar que fiebre/HRV/presión arterial podrían desacoplarse y avanzar sin esperar resuelto ese punto, si Paulina prefiere no decidir la parte ortostática todavía.
3. **Contactos de emergencia sin UI.** `Profile.emergencyContacts` existe desde Phase4.A, usado en la tarjeta de emergencia del PDF, pero no tiene pantalla de edición. Último por diseño: bajo en los cuatro criterios. Diferido explícitamente por Paulina el 2026-07-13 — retomar cuando ella lo pida.

---

## Backlog (sin orden estricto)

### Symptom Detail Layers pendientes
- **D.5 Dolor torácico** — múltiples red flags esperadas, sin empezar.
- **Mapeo HPO** de dolor estructural — se agrupará con D.4/D.5 (comparten vocabulario de "carácter del dolor"); D.3 (Presíncope) no comparte ese vocabulario y no entra en ese lote (confirmado, ver §13.5 de `symptom_detail_layers.md`).
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

### Localización
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

**Última actualización:** 2026-07-17.
