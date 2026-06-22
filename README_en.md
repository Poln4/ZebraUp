# About ZebraUp

**ZebraUp** is a health tracking app built specifically for people living with rare diseases — the "zebras" of medicine, where the common horses don't apply. The app exists to make short medical consultations more useful, helping patients arrive with concrete data instead of blurred memories.

It's currently in beta, targeting Spanish-speaking patients in Chile first.

🌐 **Web version**: [zebraup.netlify.app](https://zebraup.netlify.app)

---

## The story behind the project

I'm Paulina, a software developer and a patient living with several rare conditions: **classical Ehlers-Danlos syndrome (clEDS)**, **postural orthostatic tachycardia syndrome (POTS)**, **adenomyosis**, and **anemia**. I've spent years walking into 8-minute medical appointments trying to explain weeks of complex symptoms to professionals who have often never heard the name of my primary diagnosis.

ZebraUp came out of a very specific frustration: after a hard week, my memory — already affected by the brain fog that comes with dysautonomia — wasn't reliable enough to reconstruct what had happened. And the notes I kept in notebooks, phone memos, or in my head never quite translated into a clear summary a doctor could read in the minutes we had together.

The health apps that exist today are built for common conditions or for fitness. None of them were designed for rare disease patients, who need to track things the rest of the world doesn't understand: subluxations, dysautonomic flares, interactions between multiple medications, passive therapies like physiotherapy or acupuncture, and the days when *resting* is the treatment.

ZebraUp is the tool I needed to have. I'm building it from the dual perspective of being both patient and developer, hoping other zebras find it useful too.

---

## Mission

To help people with rare diseases arrive at their medical appointments with **objective, structured data**, so that limited time with their doctors is spent making decisions — not reconstructing memory of the past few weeks.

---

## Vision

A future where rare disease patients in Latin America have **digital tools designed for their actual conditions**, in their language, respecting their cognitive and energetic capacities, and built with their autonomy as a guiding principle — not adapted from generic apps that don't understand what living with a poorly-understood disease is like.

---

## What ZebraUp does today

**Daily tracking without guilt.** Symptoms, medication doses, structural events (subluxations, dislocations, joint/myofascial/neuropathic pain), mental states and mood. Designed with minimal cognitive load — no streaks, no notifications that punish rest days.

**Smart medicine cabinet.** Medication catalog with dosing, frequency, and interactions specific to conditions like EDS, POTS, and MCAS — interactions that general databases like OpenFDA don't cover well.

**Effectiveness tracking.** Did that medication actually help? The app asks you hours after each dose and objectively measures whether your symptom got better, worse, or stayed the same.

**Movement and recovery as equals.** Exercise (calisthenics, walking, stretching) and passive therapies (physiotherapy, acupuncture, massage, dry needling) are logged in the same place. Both count. Rest days count too.

**Mental state with low cognitive cost.** A 2D quadrant picker (calm/activated × pleasant/unpleasant) inspired by research validated for people with chronic fatigue and brain fog, instead of long questionnaires.

**Life events as context.** A trip, a move, an accident, a loss, a positive event: things that may have impacted your body or mood get logged with their date range and appear as dots on the calendar.

**Information in Spanish.** Your registered conditions connect to MedlinePlus in Spanish (US National Library of Medicine) so you have validated information in your language without having to search for it.

**Recent research.** Automatic PubMed search for recent articles on your conditions, with local caching and translations in progress.

**Local weather.** Atmospheric pressure, temperature, and humidity, so you can correlate flares with weather changes (especially useful for dysautonomia).

**Privacy by design.** All your data lives on your device. We don't upload anything to the internet unless you do. You can export your full history at any time, import it to another device, or delete everything with two taps.

**LatAm legal compliance.** Built from the start respecting ARCO rights (Access, Rectification, Cancellation, Opposition) that Chile's new Ley 21.719 and other regional laws recognize for health data.

**Caregiver support.** You can create profiles for people you care for — a family member, a partner — with their own labeled relationship and completely separate data.

---

## On the horizon

These are areas I'm actively exploring or building. They're not dated promises — they're the direction of the project.

**Mobile deployment (iOS and Android).** ZebraUp is available as a web app today, but mobile apps would enable native notifications, HealthKit/Health Connect integration, and a better offline experience.

**Wearable integration.** Heart rate variability (HRV) from smartwatches to objectively measure autonomic nervous system state — especially relevant for people with POTS and other dysautonomias.

**PDF report export.** A structured clinical summary, ready to print or send to your doctor before a consultation.

**Broader Latin American medications database.** Beyond MedlinePlus, connecting with sources like Orphadata (rare diseases) and SNOMED CT in Spanish.

**Correlation analysis.** Once enough data has accumulated, surface useful correlations: "your worst fatigue days coincide with atmospheric pressure drops," "physiotherapy seems to improve your sleep over the next two days," "this medication works better when taken with food."

**Community tab.** Aggregated, anonymous insights from other users with similar conditions — research suggests that sense of community is one of the most important factors in chronic-disease app retention.

**Microlearning.** The educational cards in the Compendium in shorter, fatigue-friendly formats.

**Sleep tracking.** A dimension that research consistently flags as important for understanding symptom patterns.

---

## Design principles

These aren't decoration; they're decisions that shape every screen of the app:

1. **No guilt, no streaks.** Apps that reward consistency punish people with chronic illness, whose consistency depends on their body, not their discipline.

2. **Autonomy over paternalism.** The app doesn't tell you what to do. It hands you your own data so you and your medical team can decide.

3. **Minimal cognitive load.** Every interaction is designed assuming the user has fatigue, brain fog, or pain. If an important action takes more than two taps, it's badly designed.

4. **User data, user property.** Export, import, and deletion are rights, not premium features.

5. **Validated research as the foundation.** Design decisions rest on peer-reviewed studies on mHealth, EDS, myofascial pain, dysautonomia, and accessible design.

6. **Spanish first.** Latin America is usually the "later" of health products. Here it's the starting point.

---

## Note for healthcare professionals

ZebraUp is **not a medical device**. It does not diagnose, treat, cure, or prevent any disease. It's a tool for Patient-Reported Outcomes (PRO) and Ecological Momentary Assessment (EMA), built in line with mHealth research recommendations from the last five years (Maarj et al. 2022; Slater et al. 2020; Buryk-Iggers et al. 2022; Steen, Jaiswal & Kumbhare 2025; Heiskari et al. 2026; among others).

Reports generated from the app include: symptom severity on a 0–4 scale (e-VAS), dose timeline with before/after markers, structural events with joint location, autonomic state inferred from mental tracking, and relevant life context (travel, stressful events, interventions). Data is stored locally and patients can export it in JSON format for external analysis if they wish.

If you work with patients who might benefit from ZebraUp, or have clinical feedback on how to improve reports for your practice, reach out through the person who shared this app with you.

---

## Beta testing and feedback

ZebraUp is in beta. Current testers are people with rare diseases in Chile who live directly with the conditions the app is designed to support. If you found a bug, an awkward translation, a feature that doesn't work the way you expected, or have an idea for improving something — that feedback is **exactly** what I need right now.

---

## Credits

Built with Flutter. Scientific data comes from PubMed (NCBI) and MedlinePlus (US National Library of Medicine). Weather data from Open-Meteo. No sponsors. No trackers. No data sales.

Built with care by a zebra, for other zebras.

---

*Last updated: June 2026*
