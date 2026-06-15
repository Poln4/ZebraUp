import 'package:flutter/material.dart';
import '../models/models.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

/// First-run onboarding. Four sequential steps with Skip available on
/// all but step 2 (name). Returns the created Profile on completion,
/// or null if the user backs out of the whole thing.
class OnboardingScreen extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final Future<void> Function(Profile profile) onComplete;
  // PHASE 5.1d — optional import flow. When supplied, the welcome step
  // shows a secondary CTA; the callback handles file/paste pick + validation
  // and returns a Profile ready to be persisted via [onComplete].
  final Future<Profile?> Function()? onImportFlow;

  const OnboardingScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onComplete,
    this.onImportFlow,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _medNameCtrl = TextEditingController();
  final _medDoseCtrl = TextEditingController();

  int _step = 0;
  final List<String> _conditions = [];
  final List<MedicationDef> _meds = [];

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _diagnosisCtrl.dispose();
    _medNameCtrl.dispose();
    _medDoseCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step >= 3) {
      _finish();
      return;
    }
    setState(() => _step++);
    _pageCtrl.animateToPage(_step,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageCtrl.animateToPage(_step,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim().isEmpty ? "Mi perfil" : _nameCtrl.text.trim();
    final profile = Profile(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      conditions: List.from(_conditions),
      botiquin: List.from(_meds),
      symptomVault: const [], // intentionally empty — they discover this in app
    );
    await widget.onComplete(profile);
  }

  void _addCondition() {
    final txt = _diagnosisCtrl.text.trim();
    if (txt.isEmpty || _conditions.contains(txt)) {
      _diagnosisCtrl.clear();
      return;
    }
    setState(() {
      _conditions.add(txt);
      _diagnosisCtrl.clear();
    });
  }

  void _addMed() {
    final name = _medNameCtrl.text.trim();
    final dose = _medDoseCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _meds.add(MedicationDef(
        name: name,
        // If your MedicationDef constructor needs strength + unit instead,
        // change the next line to your shape.
        notes: dose.isEmpty ? null : dose,
        outcomeCheckHours: null,
      ));
      _medNameCtrl.clear();
      _medDoseCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canGoNext = _step != 1 || _nameCtrl.text.trim().isNotEmpty;
    final isLastStep = _step == 3;
    final canSkip = _step != 1; // skip blocked on the name step
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _ic,
      body: SafeArea(
        child: Column(
          children: [
            // Progress strip + step indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(4, (i) {
                        final active = i <= _step;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            height: 3,
                            color: active ? _cc : _cc.withValues(alpha: 0.2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${_step + 1} / 4",
                      style: TextStyle(color: _cc.withValues(alpha: 0.6), fontSize: 11)),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _welcomeStep(),
                  _nameStep(),
                  _conditionsStep(),
                  _medsStep(),
                ],
              ),
            ),

            // Action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _back,
                      child: Text(l10n.onboardingActionBack,
                          style: TextStyle(color: _cc.withValues(alpha: 0.7))),
                    ),
                  const Spacer(),
                  if (canSkip && !isLastStep)
                    TextButton(
                      onPressed: _next,
                      child: Text(l10n.onboardingActionSkip,
                          style: TextStyle(color: _cc.withValues(alpha: 0.7))),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cc,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: canGoNext ? _next : null,
                    child: Text(
                      isLastStep ? l10n.onboardingActionFinish : l10n.onboardingActionNext,
                      style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 0 — Welcome
  // ---------------------------------------------------------------------------

  Widget _welcomeStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.medical_information_outlined, color: _cc, size: 48),
          const SizedBox(height: 24),
          Text(context.l10n.onboardingStepWelcomeTitle,
              style: TextStyle(color: _cc, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(context.l10n.onboardingStepWelcomeSubtitle,
              style: TextStyle(
                  color: _cc.withValues(alpha: 0.8), fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Text(context.l10n.onboardingStepWelcomeBody,
            style: TextStyle(color: _cc, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _cc.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: _cc.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.onboardingStepWelcomePrivacyNote,
                    style: TextStyle(
                        color: _cc.withValues(alpha: 0.7), fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _cc.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: _cc.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.onboardingStepWelcomeMedicalDisclaimer,
                    style: TextStyle(
                        color: _cc.withValues(alpha: 0.7), fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // PHASE 5.1d — Import existing profile shortcut
          if (widget.onImportFlow != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                final imported = await widget.onImportFlow!();
                if (imported != null && mounted) {
                  await widget.onComplete(imported);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _cc, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              child: Row(
                children: [
                  Icon(Icons.file_upload_outlined, color: _cc, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.onboardingHaveProfileTitle,
                          style: TextStyle(
                              color: _cc,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.onboardingHaveProfileSubtitle,
                          style: TextStyle(
                              color: _cc.withValues(alpha: 0.7),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: _cc.withValues(alpha: 0.6), size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — Name
  // ---------------------------------------------------------------------------

  Widget _nameStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingStepNameTitle,
              style: TextStyle(color: _cc, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(context.l10n.onboardingStepNameQuestion,
              style: TextStyle(color: _cc, fontSize: 16)),
          const SizedBox(height: 4),
          Text(context.l10n.onboardingStepNameFootnote,
              style: TextStyle(color: _cc.withValues(alpha: 0.6), fontSize: 12)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: TextStyle(color: _cc, fontSize: 22),
            decoration: InputDecoration(
              hintText: context.l10n.onboardingStepNameHint,
              hintStyle: TextStyle(color: _cc.withValues(alpha: 0.4), fontSize: 22),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _cc.withValues(alpha: 0.4)),
              ),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _cc, width: 2)),
            ),
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_nameCtrl.text.trim().isNotEmpty) _next();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — Diagnoses
  // ---------------------------------------------------------------------------

  Widget _conditionsStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingStepConditionsTitle,
              style: TextStyle(color: _cc, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboardingStepConditionsBody,
            style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _diagnosisCtrl,
                  style: TextStyle(color: _cc),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCondition(),
                  decoration: InputDecoration(
                    hintText: context.l10n.onboardingStepConditionsHint,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.add, color: _cc), onPressed: _addCondition),
            ],
          ),
          const SizedBox(height: 16),
          if (_conditions.isEmpty)
            Text(context.l10n.onboardingStepConditionsEmpty,
                style: TextStyle(
                    color: _cc.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _conditions
                  .map((c) => InputChip(
                        label: Text(c, style: TextStyle(color: _ic, fontSize: 13)),
                        backgroundColor: _cc,
                        onDeleted: () => setState(() => _conditions.remove(c)),
                        deleteIconColor: _ic,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 — Initial meds
  // ---------------------------------------------------------------------------

  Widget _medsStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingStepMedsTitle,
              style: TextStyle(color: _cc, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboardingStepMedsBody,
            style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _medNameCtrl,
                  style: TextStyle(color: _cc),
                  decoration: InputDecoration(
                    hintText: context.l10n.onboardingStepMedsNameHint,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _medDoseCtrl,
                  style: TextStyle(color: _cc),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addMed(),
                  decoration: InputDecoration(
                    hintText: context.l10n.onboardingStepMedsDoseHint,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.add, color: _cc), onPressed: _addMed),
            ],
          ),
          const SizedBox(height: 16),
          if (_meds.isEmpty)
            Text(context.l10n.onboardingStepMedsEmpty,
                style: TextStyle(
                    color: _cc.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic))
          else
            Column(
              children: _meds
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.medical_services_outlined,
                                color: _cc, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.value.notes != null && e.value.notes!.isNotEmpty
                                    ? "${e.value.name} — ${e.value.notes}"
                                    : e.value.name,
                                style: TextStyle(color: _cc, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  setState(() => _meds.removeAt(e.key)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}