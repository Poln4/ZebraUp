// Sprint F — MedicationType classification
//
// Distinguishes basal / scheduled medications (taken preventively on a
// schedule) from PRN / rescue medications (taken as-needed in response
// to acute symptoms).
//
// Rationale: Sprint F introduces post-event action prompts that offer
// to log medications taken in response to a symptom. To avoid
// cluttering the picker with basal preventive meds (irrelevant
// post-event), the F.B+C prompt filters to
// `prnRescue | both | undefined` and hides `basalScheduled`.
//
// The `undefined` value is the default for MedicationDef records
// created before Sprint F — retro-compat. The user reclassifies
// existing meds via the Botiquín form (F.E+F) at their own pace.
//
// Design pattern references (from Sprint F planning turno C research):
//   - Folia Health: distinción formal a nivel base de datos entre
//     medicación programada y PRN, con reporte cruzado en export
//   - ClarityDTX MCAS Tracker: separación explícita entre
//     mantenimiento mastocitario (H1/H2, DAO) y rescate agudo
//     (autoinyector de epinefrina)
//   - ClarityDTX POTS/Fibro: pre-post design con curvas de respuesta
//     30-60 min para medicación de rescate

enum MedicationType {
  basalScheduled('basal_scheduled'),
  prnRescue('prn_rescue'),
  both('both'),
  undefined('undefined');

  final String serializationKey;
  const MedicationType(this.serializationKey);

  static MedicationType? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}
