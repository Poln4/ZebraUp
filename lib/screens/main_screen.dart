import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math'; // <-- Agregado para los números aleatorios
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../services/pubmed_service.dart';
import 'hoy_tab.dart';
import 'investigacion_tab.dart';
import 'timestamp_picker.dart';

class MainAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final double fontScale;
  final ValueChanged<double> onScaleFont;

  const MainAppScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.fontScale,
    required this.onScaleFont,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late List<Profile> _profiles;
  Profile? _activeProfile;

  // Variables para la Base de Datos Clínica y de Sabiduría
  List<WisdomQuote> _wisdomDatabase = [];
  List<ClinicalArticle> _clinicalLibraryDatabase = [];
  
  WisdomQuote? _currentWisdom; // Guarda la frase actual que se muestra
  final Random _random = Random(); // Generador de aleatoriedad

  final PubMedService _pubmed = PubMedService();

  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String _clinicaTabView = "Reporte"; // Reporte | Biblioteca | Investigación

  final _profileNameController = TextEditingController();
  final _newDiagnosisController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedNameController = TextEditingController();
  final _newMedDoseController = TextEditingController();

  // -------------------------------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadLibraries(); // Reemplaza al _loadSimulatedLibraries
    _loadUserProfiles();
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _newDiagnosisController.dispose();
    _newSymptomController.dispose();
    _newMedNameController.dispose();
    _newMedDoseController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // DATOS Y JSON (La nueva integración)
  // -------------------------------------------------------------------------

  Future<void> _loadLibraries() async {
    // 1. Tus frases originales (puedes dejarlas o borrarlas si solo quieres las del JSON)
    List<WisdomQuote> baseQuotes = [
      WisdomQuote(text: "Descansar no es rendirse; es una intervención médica necesaria para tu sistema nervioso.", category: "Pacing"),
      WisdomQuote(text: "Tus síntomas son reales, incluso cuando los exámenes de rutina no los muestran.", category: "Validación"),
      WisdomQuote(text: "El mundo es tu papa. Hoy toca reparar.", category: "Potato Day"),
    ];

    try {
      // OJO: Asegúrate de usar el nombre exacto de tu archivo. 
      // Si le pusiste zebra_wisdom.json, usa ese. Si guardaste el que generamos con Python, 
      // probablemente se llame consolidated_eds_facts.json
      final String jsonString = await rootBundle.loadString('assets/zebra_wisdom.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      final List<dynamic> jsonFacts = jsonData['facts'] ?? [];

      setState(() {
        // 2. Alimentar la Biblioteca Clínica
        _clinicalLibraryDatabase = jsonFacts.map((item) {
          return ClinicalArticle(
            category: item['condition'] ?? 'General',
            title: item['tone'] ?? 'Información', 
            content: item['fact_es'] ?? '', 
          );
        }).toList();

        // 3. Alimentar las Frases de Sabiduría (WisdomDatabase)
        // Juntamos las 3 bases + los 51 facts del JSON
        _wisdomDatabase = baseQuotes + jsonFacts.map((item) {
          return WisdomQuote(
            text: item['fact_es'] ?? '',
            category: item['condition'] ?? 'Dato Clínico',
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Error cargando el JSON: $e");
      // ESTO MOSTRARÁ EL ERROR DIRECTAMENTE EN LA TARJETA
      setState(() {
        _wisdomDatabase = [
          WisdomQuote(text: "ERROR: $e", category: "Debugging")
        ];
        _currentWisdom = _wisdomDatabase.first;
      });
    }

    // 4. Elegir una frase inicial al terminar de cargar todo
    _changeWisdomQuote(); 
  }

  // Método para cambiar la frase aleatoriamente
  void _changeWisdomQuote() {
    if (_wisdomDatabase.isEmpty) return;
    
    setState(() {
      int randomIndex = _random.nextInt(_wisdomDatabase.length);
      _currentWisdom = _wisdomDatabase[randomIndex];
    });
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  String _getDateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  DateTime _timestampForLog() {
    final now = DateTime.now();
    final sel = _selectedDate;
    final isToday = sel.year == now.year && sel.month == now.month && sel.day == now.day;
    if (isToday) return now;
    return DateTime(sel.year, sel.month, sel.day, now.hour, now.minute, now.second);
  }

  // -------------------------------------------------------------------------
  // PERSISTENCE
  // -------------------------------------------------------------------------

  void _saveData() {
    final box = Hive.box('zebraBox');
    final encoded = json.encode(_profiles.map((p) => p.toMap()).toList());
    box.put('profiles', encoded);
  }

  void _loadUserProfiles() {
    final box = Hive.box('zebraBox');
    final storedData = box.get('profiles');
    if (storedData != null) {
      final decoded = json.decode(storedData) as List<dynamic>;
      _profiles = decoded.map((x) => Profile.fromMap(x)).toList();
    } else {
      _profiles = [
        Profile(
          id: '1',
          name: 'Paulina (Me)',
          conditions: ['clEDS', 'Adenomiosis', 'POTS', 'Anemia'],
          botiquin: [
            MedicationDef(name: 'Hierro', defaultDose: '14mg', outcomeCheckHours: null),
            MedicationDef(name: 'Vitamina C', defaultDose: '1000mg', outcomeCheckHours: null),
            MedicationDef(name: 'Duloxetina', defaultDose: '60mg', outcomeCheckHours: null),
            MedicationDef(name: 'Ibuprofeno', defaultDose: '400mg (SOS)', outcomeCheckHours: 3),
            MedicationDef(name: 'Paracetamol', defaultDose: '500mg (SOS)', outcomeCheckHours: 3),
          ],
          symptomVault: [
            'Fatiga crónica', 'Niebla mental', 'Taquicardia ortostática',
            'Mareos al pararse', 'Reflujo gástrico', 'Náuseas',
            'Moratones', 'Dolor de cabeza',
          ],
        ),
      ];
      _saveData();
    }
    if (_profiles.isNotEmpty) {
      _activeProfile = _profiles.first;
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (_activeProfile != null) {
      _profileNameController.text = _activeProfile!.name;
    }
  }

  // -------------------------------------------------------------------------
  // BUILD ROOT
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final contrastColor = widget.isDarkMode ? Colors.white : Colors.black;
    final inverseContrastColor = widget.isDarkMode ? Colors.black : Colors.white;

    if (_activeProfile == null) {
      return _buildEmptyProfileScaffold(contrastColor, inverseContrastColor);
    }

    final dueOutcomesCount = _activeProfile!.getDueOutcomes().length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: inverseContrastColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: contrastColor, height: 1.0),
        ),
        title: DropdownButton<Profile>(
          value: _activeProfile,
          dropdownColor: inverseContrastColor,
          icon: Icon(Icons.arrow_drop_down, color: contrastColor),
          style: TextStyle(fontSize: 20, color: contrastColor, fontWeight: FontWeight.bold, letterSpacing: 1),
          underline: Container(),
          onChanged: (Profile? newProfile) {
            if (newProfile != null) {
              setState(() {
                _activeProfile = newProfile;
                _updateControllers();
              });
            }
          },
          items: _profiles.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
        ),
        actions: [
          IconButton(
            tooltip: "Tamaño de texto",
            icon: Icon(Icons.text_fields, color: contrastColor),
            onPressed: () => widget.onScaleFont(widget.fontScale >= 1.4 ? 1.0 : widget.fontScale + 0.2),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? "Modo claro" : "Modo oscuro",
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: contrastColor),
            onPressed: widget.onToggleTheme,
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: "Configuración",
              icon: Icon(Icons.settings_outlined, color: contrastColor, size: 28),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(contrastColor, inverseContrastColor),
      body: Column(
        children: [
          _buildCalendarStrip(contrastColor, inverseContrastColor),
          Expanded(
            child: _buildCurrentTab(contrastColor, inverseContrastColor),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: inverseContrastColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: contrastColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'Hoy'),
          const BottomNavigationBarItem(icon: Icon(Icons.accessibility_new_rounded), label: 'Síntomas'),
          BottomNavigationBarItem(
            icon: _buildBotiquinIcon(dueOutcomesCount, contrastColor),
            label: 'Botiquín',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Clínica'),
        ],
      ),
    );
  }

Widget _buildCurrentTab(Color cc, Color ic) {
    switch (_currentNavIndex) {
      case 0:
        return HoyTab(
          profile: _activeProfile!,
          selectedDate: _selectedDate,
          wisdom: _currentWisdom ?? WisdomQuote(text: "Cargando sabiduría...", category: "Loading"),
          contrastColor: cc,
          inverseContrastColor: ic,
          onTogglePacing: _togglePacing,
          onLogMental: _logMental,
          onAnswerOutcome: _answerOutcome,
          onChangeWisdom: _changeWisdomQuote, // <-- THIS FIXES THE ERROR
        );
      case 1:
        return _buildSintomasTab(cc, ic);
      case 2:
        return _buildBotiquinTab(cc, ic);
      case 3:
      default:
        return _buildClinicaTab(cc, ic);
    }
  }

  /// Botiquín icon with a small badge if there are pending outcomes.
  Widget _buildBotiquinIcon(int dueCount, Color cc) {
    if (dueCount == 0) return const Icon(Icons.medical_services_outlined);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.medical_services_outlined),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$dueCount',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProfileScaffold(Color cc, Color ic) {
    return Scaffold(
      backgroundColor: ic,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: cc, size: 64),
              const SizedBox(height: 16),
              Text("Crea tu primer perfil",
                  style: TextStyle(color: cc, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _createNewProfile,
                child: Text("CREAR PERFIL",
                    style: TextStyle(color: cc, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP
  // -------------------------------------------------------------------------

  Widget _buildCalendarStrip(Color cc, Color ic) {
    return Container(
      height: 70,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cc))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        reverse: true,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: index));
          final dateKey = _getDateKey(date);
          final isSelected = dateKey == _getDateKey(_selectedDate);
          final isPacing = _activeProfile!.pacingDays.contains(dateKey);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cc : Colors.transparent,
                border: Border.all(color: cc, width: isPacing ? 2 : 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(date).toUpperCase(),
                      style: TextStyle(fontSize: 10, color: isSelected ? ic : cc, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  isPacing
                      ? Icon(Icons.shield_outlined, color: isSelected ? ic : cc, size: 18)
                      : Text(DateFormat('d').format(date),
                          style: TextStyle(fontSize: 14, color: isSelected ? ic : cc, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SÍNTOMAS TAB
  // -------------------------------------------------------------------------

  Widget _buildSintomasTab(Color cc, Color ic) {
    final todaysStructs = _activeProfile!.getStructuralForDay(_selectedDate);
    final todaysSymptoms = _activeProfile!.getSymptomsForDay(_selectedDate);
    final todaysActivity = _activeProfile!.getActivityForDay(_selectedDate);
    final trendingSymptoms = _activeProfile!.getTrendingSymptoms();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("ZONAS ESTRUCTURALES",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ["Cervicales", "Hombros", "Muñecas", "Manos", "Lumbar/Pelvis", "Caderas", "Rodillas", "Tobillos"]
              .map((zone) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: cc),
                    label: Text(zone, style: TextStyle(color: cc, fontSize: 12)),
                    onPressed: () => _openStructuralMenu(zone, cc, ic),
                  ))
              .toList(),
        ),
        if (todaysStructs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Column(
              children: todaysStructs
                  .map((e) => InkWell(
                        onLongPress: () => _editStructuralEvent(e, cc, ic),
                        child: Row(
                          children: [
                            Icon(Icons.adjust, color: cc, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text("[${DateFormat('HH:mm').format(e.timestamp)}] ${e.zone}: ${e.type}",
                                  style: TextStyle(color: cc, fontSize: 14)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 18),
                              onPressed: () => setState(() {
                                _activeProfile!.structuralHistory.remove(e);
                                _saveData();
                              }),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 32),

        if (todaysSymptoms.isNotEmpty) ...[
          Text("REGISTROS DE HOY",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Column(
              children: todaysSymptoms
                  .map((event) => InkWell(
                        onLongPress: () => _editSymptomEvent(event, cc, ic),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("[${DateFormat('HH:mm').format(event.timestamp)}] ${event.name} (${event.severity.label})",
                                        style: TextStyle(color: cc, fontSize: 14)),
                                    if (event.note != null && event.note!.trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text(event.note!,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() {
                                  _activeProfile!.symptomHistory.remove(event);
                                  _saveData();
                                }),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text("Mantén pulsado un registro para editar fecha/gravedad/nota.",
              style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
          const SizedBox(height: 32),
        ],

        Text("EN TENDENCIA (ÚLTIMOS 7 DÍAS)",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
        const SizedBox(height: 8),
        trendingSymptoms.isEmpty
            ? Text("No hay síntomas consistentes esta semana.",
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trendingSymptoms
                    .map((s) => ActionChip(
                          backgroundColor: ic,
                          side: BorderSide(color: cc, width: 2),
                          label: Text(s, style: TextStyle(color: cc, fontSize: 14, fontWeight: FontWeight.bold)),
                          onPressed: () => _openSeverityMenu(s, cc, ic),
                        ))
                    .toList(),
              ),
        const SizedBox(height: 32),

        Text("BAÚL DE SÍNTOMAS",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _activeProfile!.symptomVault
              .map((s) => ActionChip(
                    backgroundColor: ic,
                    side: const BorderSide(color: Colors.grey),
                    label: Text(s, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    onPressed: () => _openSeverityMenu(s, cc, ic),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _newSymptomController,
          style: TextStyle(color: cc),
          decoration: InputDecoration(
            hintText: "+ Añadir síntoma al baúl...",
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: cc),
              onPressed: () {
                if (_newSymptomController.text.trim().isNotEmpty) {
                  setState(() {
                    _activeProfile!.symptomVault.insert(0, _newSymptomController.text.trim());
                    _newSymptomController.clear();
                    _saveData();
                  });
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Activity section (the calisthenics layer, kept minimal)
        Text("ACTIVIDAD",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kExerciseCatalog
              .map((ex) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: cc),
                    label: Text(ex.name, style: TextStyle(color: cc, fontSize: 12)),
                    onPressed: () => _openActivityMenu(ex, cc, ic),
                  ))
              .toList(),
        ),
        if (todaysActivity.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Column(
              children: todaysActivity.map((a) {
                final detail = a.durationMinutes != null
                    ? '${a.durationMinutes}min'
                    : '${a.sets ?? "?"}×${a.reps ?? "?"}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center, color: cc, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "[${DateFormat('HH:mm').format(a.timestamp)}] ${a.name}: $detail · esfuerzo ${a.effort}/10 · sentir ${a.feeling}/5",
                          style: TextStyle(color: cc, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() {
                          _activeProfile!.activityHistory.remove(a);
                          _saveData();
                        }),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // BOTIQUÍN TAB
  // -------------------------------------------------------------------------

  Widget _buildBotiquinTab(Color cc, Color ic) {
    final flags = InteractionEngine.evaluate(
      medicationsToday: _activeProfile!.getDosesForDay(_selectedDate).map((e) => e.medicationName).toList(),
      conditions: _activeProfile!.conditions,
    );
    final todaysDoses = _activeProfile!.getDosesForDay(_selectedDate);
    final dueOutcomes = _activeProfile!.getDueOutcomes();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (dueOutcomes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc, width: 2)),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: cc),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${dueOutcomes.length} seguimiento(s) pendiente(s). Ve a la pestaña Hoy para responder.",
                    style: TextStyle(color: cc, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (flags.isNotEmpty) ...[
          Text("ALERTAS DE INTERACCIÓN",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
          const SizedBox(height: 8),
          ...flags.map((rule) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: rule.level == InteractionLevel.severe ? Colors.redAccent : cc,
                    width: 2,
                  ), 
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.message,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cc)),
                    if (rule.reference != null) ...[
                      const SizedBox(height: 4),
                      Text(rule.reference!,
                          style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              )),
          const SizedBox(height: 24),
        ],
        Text("REGISTRAR DOSIS",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
        const SizedBox(height: 8),
        ..._activeProfile!.botiquin.map((med) => _buildMedRow(med, todaysDoses, cc, ic)),
        if (todaysDoses.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text("HISTORIAL DE TOMAS (HOY)",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: cc)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Column(
              children: todaysDoses
                  .map((e) => InkWell(
                        onLongPress: () => _editDoseEvent(e, cc, ic),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "[${DateFormat('HH:mm').format(e.timestamp)}] ${e.medicationName}",
                                  style: TextStyle(color: cc, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Text("ADMINISTRAR BOTIQUÍN",
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Column(
            children: [
              TextField(
                controller: _newMedNameController,
                style: TextStyle(color: cc),
                decoration: const InputDecoration(
                  hintText: "Nombre Medicamento",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newMedDoseController,
                      style: TextStyle(color: cc),
                      decoration: const InputDecoration(
                        hintText: "Dosis (Ej. 14mg)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, size: 32, color: cc),
                    onPressed: () {
                      if (_newMedNameController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile!.botiquin.add(MedicationDef(
                            name: _newMedNameController.text.trim(),
                            defaultDose: _newMedDoseController.text.trim(),
                            outcomeCheckHours: 3,
                          ));
                          _newMedNameController.clear();
                          _newMedDoseController.clear();
                          _saveData();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedRow(MedicationDef med, List<DoseEvent> todaysDoses, Color cc, Color ic) {
    final doseCount = _activeProfile!.getDoseCountForDayAndMed(_selectedDate, med.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cc)),
                Text(med.defaultDose, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: cc),
                onPressed: doseCount == 0
                    ? null
                    : () {
                        DoseEvent? lastDose;
                        for (final e in todaysDoses) {
                          if (e.medicationName == med.name) lastDose = e;
                        }
                        if (lastDose != null) {
                          setState(() {
                            _activeProfile!.doseHistory.remove(lastDose);
                            _saveData();
                          });
                        }
                      },
              ),
              Text("$doseCount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cc)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: cc),
                onPressed: () => _logDose(med, cc, ic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CLÍNICA TAB
  // -------------------------------------------------------------------------

  Widget _buildClinicaTab(Color cc, Color ic) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: _clinicaTabBtn("Reporte", "REPORTE", cc, ic)),
              const SizedBox(width: 6),
              Expanded(child: _clinicaTabBtn("Biblioteca", "COMPENDIO", cc, ic)),
              const SizedBox(width: 6),
              Expanded(child: _clinicaTabBtn("Investigación", "INVESTIGACIÓN", cc, ic)),
            ],
          ),
        ),
        Expanded(
          child: switch (_clinicaTabView) {
            "Reporte" => _buildReportContent(cc, ic),
            "Biblioteca" => _buildCompendiumLibraryContent(cc, ic),
            "Investigación" => InvestigacionTab(
                profile: _activeProfile!,
                service: _pubmed,
                contrastColor: cc,
                inverseContrastColor: ic,
                onToggleSave: _toggleSavedArticle,
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  Widget _clinicaTabBtn(String value, String label, Color cc, Color ic) {
    final selected = _clinicaTabView == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? cc : ic,
        side: BorderSide(color: cc),
      ),
      onPressed: () => setState(() => _clinicaTabView = value),
      child: Text(label,
          style: TextStyle(color: selected ? ic : cc, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  String _buildReportPlainText() {
    final todaysSymptoms = _activeProfile!.getSymptomsForDay(_selectedDate);
    final todaysDoses = _activeProfile!.getDosesForDay(_selectedDate);
    final todaysStructs = _activeProfile!.getStructuralForDay(_selectedDate);
    final todaysMental = _activeProfile!.getMentalForDay(_selectedDate);

    final grouped = <String, SymptomSeverity>{};
    for (final s in todaysSymptoms) {
      final existing = grouped[s.name];
      if (existing == null || s.severity.index > existing.index) {
        grouped[s.name] = s.severity;
      }
    }

    final groupedDoses = <String, int>{};
    for (final d in todaysDoses) {
      groupedDoses[d.medicationName] = (groupedDoses[d.medicationName] ?? 0) + 1;
    }

    final mentalSummary = <MentalState, int>{};
    for (final m in todaysMental) {
      final cur = mentalSummary[m.state];
      if (cur == null || m.severity > cur) mentalSummary[m.state] = m.severity;
    }

    final buf = StringBuffer();
    buf.writeln("PACIENTE: ${_activeProfile!.name}");
    buf.writeln("FECHA EVALUADA: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
    buf.writeln("─────────────────────────────");
    buf.writeln("DIAGNÓSTICOS:");
    for (final c in _activeProfile!.conditions) {
      buf.writeln(" • $c");
    }
    buf.writeln();
    buf.writeln("TRATAMIENTO (dosis del día):");
    if (groupedDoses.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final m in groupedDoses.entries) {
        buf.writeln(" • ${m.key} — ${m.value} dosis");
      }
    }
    buf.writeln();
    buf.writeln("SÍNTOMAS:");
    if (grouped.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final s in grouped.entries) {
        buf.writeln(" • ${s.key} [${s.value.label.toUpperCase()}]");
      }
    }
    if (mentalSummary.isNotEmpty) {
      buf.writeln();
      buf.writeln("SALUD MENTAL (máx. del día, 1–5):");
      for (final m in mentalSummary.entries) {
        buf.writeln(" • ${m.key.label}: ${m.value}/5");
      }
    }
    if (todaysStructs.isNotEmpty) {
      buf.writeln();
      buf.writeln("EVENTOS ESTRUCTURALES:");
      for (final e in todaysStructs) {
        buf.writeln(" • [${DateFormat('HH:mm').format(e.timestamp)}] ${e.zone}: ${e.type}");
      }
    }

    // Effectiveness summaries
    final effPairs = <String>{};
    for (final o in _activeProfile!.medicationOutcomes) {
      effPairs.add('${o.medicationName}→${o.symptomName}');
    }
    if (effPairs.isNotEmpty) {
      buf.writeln();
      buf.writeln("EFECTIVIDAD (histórico):");
      for (final pair in effPairs) {
        final parts = pair.split('→');
        final eff = _activeProfile!.effectivenessFor(parts[0], parts[1]);
        if (eff != null) {
          final pct = (eff.better / eff.total * 100).toStringAsFixed(0);
          buf.writeln(" • ${parts[0]} → ${parts[1]}: $pct% mejora (${eff.better}/${eff.total})");
        }
      }
    }
    return buf.toString();
  }

  Widget _buildReportContent(Color cc, Color ic) {
    final reportText = _buildReportPlainText();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: cc)),
          child: SelectableText(reportText,
              style: TextStyle(fontFamily: 'Courier', fontSize: 14, color: cc)),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cc, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: Icon(Icons.copy, color: cc),
          label: Text("COPIAR AL PORTAPAPELES",
              style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14)),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: reportText));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Reporte copiado."), duration: Duration(seconds: 2)),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompendiumLibraryContent(Color cc, Color ic) {
    final savedCount = _activeProfile!.savedArticlePmids.length;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (savedCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Row(
              children: [
                Icon(Icons.bookmark, color: cc, size: 18),
                const SizedBox(width: 8),
                Text("$savedCount artículo(s) guardado(s) — ve a Investigación.",
                    style: TextStyle(color: cc, fontSize: 12)),
              ],
            ),
          ),
        ..._clinicalLibraryDatabase.map((article) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(border: Border.all(color: cc)),
              child: ExpansionTile(
                iconColor: cc,
                collapsedIconColor: cc,
                title: Text(article.title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: cc, fontSize: 16)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(article.content,
                        style: TextStyle(height: 1.5, color: cc, fontSize: 14)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // SETTINGS DRAWER
  // -------------------------------------------------------------------------

  Widget _buildSettingsDrawer(Color cc, Color ic) {
    return Drawer(
      backgroundColor: ic,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          Text("CONFIGURACIÓN DE PERFIL",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1, color: cc)),
          Divider(color: cc),
          const SizedBox(height: 16),
          const Text("NOMBRE DEL PACIENTE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _profileNameController,
            style: TextStyle(color: cc, fontSize: 16),
            onChanged: (val) => setState(() {
              _activeProfile!.name = val;
              _saveData();
            }),
          ),
          const SizedBox(height: 24),
          const Text("COMORBILIDADES / DIAGNÓSTICOS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newDiagnosisController,
                  style: TextStyle(color: cc, fontSize: 16),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: cc),
                onPressed: () {
                  if (_newDiagnosisController.text.trim().isNotEmpty) {
                    setState(() {
                      _activeProfile!.conditions.add(_newDiagnosisController.text.trim());
                      _newDiagnosisController.clear();
                      _saveData();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _activeProfile!.conditions
                .map((condition) => InputChip(
                      label: Text(condition, style: TextStyle(color: ic, fontSize: 14)),
                      backgroundColor: cc,
                      onDeleted: () => setState(() {
                        _activeProfile!.conditions.remove(condition);
                        _saveData();
                      }),
                      deleteIconColor: ic,
                    ))
                .toList(),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: Icon(Icons.person_add_alt_1_rounded, color: cc),
            label: Text("CREAR NUEVO PERFIL",
                style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () {
              _createNewProfile();
              Navigator.pop(context);
            },
          ),
          if (_profiles.length > 1) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text("ELIMINAR ESTE PERFIL",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: () => _confirmDeleteProfile(),
            ),
          ],
        ],
      ),
    );
  }

  void _createNewProfile() {
    setState(() {
      final newId = "${DateTime.now().millisecondsSinceEpoch}-${_profiles.length + 1}";
      final newProfile = Profile(
        id: newId,
        name: "NUEVO PERFIL ${_profiles.length + 1}",
        conditions: [],
        botiquin: [],
        symptomVault: [],
      );
      _profiles.add(newProfile);
      _activeProfile = newProfile;
      _updateControllers();
      _saveData();
    });
  }

  Future<void> _confirmDeleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar perfil"),
        content: Text("¿Eliminar el perfil \"${_activeProfile!.name}\" y todos sus datos? Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _profiles.remove(_activeProfile);
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
      _updateControllers();
      _saveData();
    });
    if (mounted) Navigator.pop(context);
  }

  // -------------------------------------------------------------------------
  // ACTIONS: logging, editing, outcome answering
  // -------------------------------------------------------------------------

  void _togglePacing() {
    final dateKey = _getDateKey(_selectedDate);
    setState(() {
      if (_activeProfile!.pacingDays.contains(dateKey)) {
        _activeProfile!.pacingDays.remove(dateKey);
      } else {
        _activeProfile!.pacingDays.add(dateKey);
      }
      _saveData();
    });
  }

  void _logMental(MentalState state, int severity, {DateTime? timestamp}) {
    setState(() {
      _activeProfile!.mentalHistory.add(MentalEvent(
        timestamp: timestamp ?? _timestampForLog(),
        state: state,
        severity: severity,
      ));
      _saveData();
    });
  }

  void _answerOutcome(MedicationOutcome o, MedicationOutcomeStatus status) {
    setState(() {
      final idx = _activeProfile!.medicationOutcomes.indexOf(o);
      if (idx >= 0) {
        _activeProfile!.medicationOutcomes[idx] =
            o.copyWith(status: status, respondedAt: DateTime.now());
        _saveData();
      }
    });
  }

  void _toggleSavedArticle(String pmid) {
    setState(() {
      if (_activeProfile!.savedArticlePmids.contains(pmid)) {
        _activeProfile!.savedArticlePmids.remove(pmid);
      } else {
        _activeProfile!.savedArticlePmids.add(pmid);
      }
      _saveData();
    });
  }

  // ---- LOGGING ----

  void _openSeverityMenu(String symptom, Color cc, Color ic) {
    final noteCtrl = TextEditingController();
    DateTime ts = _timestampForLog();

    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GRAVEDAD DE: ${symptom.toUpperCase()}",
                        style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                      icon: Icon(Icons.access_time, color: cc, size: 16),
                      label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                          style: TextStyle(color: cc, fontSize: 12)),
                      onPressed: () async {
                        final picked = await pickTimestamp(
                          context: ctx, initial: ts,
                          contrastColor: cc, inverseContrastColor: ic,
                        );
                        if (picked != null) setSheet(() => ts = picked);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteCtrl,
                      style: TextStyle(color: cc),
                      decoration: const InputDecoration(
                        hintText: "Nota opcional (contexto, gatillo, etc.)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...SymptomSeverity.values.map((sev) => ListTile(
                          leading: Icon(Icons.circle, color: _severityColor(sev)),
                          title: Text(sev.label, style: TextStyle(color: cc, fontSize: 14)),
                          onTap: () {
                            final note = noteCtrl.text.trim();
                            setState(() {
                              _activeProfile!.symptomHistory.add(SymptomEvent(
                                timestamp: ts,
                                name: symptom,
                                severity: sev,
                                note: note.isEmpty ? null : note,
                              ));
                              _saveData();
                            });
                            Navigator.pop(ctx);
                          },
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editSymptomEvent(SymptomEvent event, Color cc, Color ic) {
    final noteCtrl = TextEditingController(text: event.note ?? '');
    DateTime ts = event.timestamp;
    SymptomSeverity sev = event.severity;

    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EDITAR: ${event.name.toUpperCase()}",
                        style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                      icon: Icon(Icons.access_time, color: cc, size: 16),
                      label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                          style: TextStyle(color: cc, fontSize: 12)),
                      onPressed: () async {
                        final picked = await pickTimestamp(
                          context: ctx, initial: ts,
                          contrastColor: cc, inverseContrastColor: ic,
                        );
                        if (picked != null) setSheet(() => ts = picked);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteCtrl,
                      style: TextStyle(color: cc),
                      decoration: const InputDecoration(hintText: "Nota opcional", hintStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                    ...SymptomSeverity.values.map((s) => ListTile(
                          leading: Icon(Icons.circle, color: _severityColor(s)),
                          title: Text(s.label, style: TextStyle(color: cc)),
                          trailing: sev == s ? Icon(Icons.check, color: cc) : null,
                          onTap: () => setSheet(() => sev = s),
                        )),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cc,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        final note = noteCtrl.text.trim();
                        setState(() {
                          final idx = _activeProfile!.symptomHistory.indexOf(event);
                          if (idx >= 0) {
                            _activeProfile!.symptomHistory[idx] = event.copyWith(
                              timestamp: ts,
                              severity: sev,
                              note: note.isEmpty ? null : note,
                            );
                            _saveData();
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text('GUARDAR CAMBIOS',
                          style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _severityColor(SymptomSeverity sev) => switch (sev) {
        SymptomSeverity.mild => Colors.green,
        SymptomSeverity.moderate => Colors.orange,
        SymptomSeverity.severe => Colors.red,
      };

  void _openStructuralMenu(String zone, Color cc, Color ic) {
    DateTime ts = _timestampForLog();
    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("REGISTRAR EN: ${zone.toUpperCase()}",
                        style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                      icon: Icon(Icons.access_time, color: cc, size: 16),
                      label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                          style: TextStyle(color: cc, fontSize: 12)),
                      onPressed: () async {
                        final picked = await pickTimestamp(
                            context: ctx,
                            initial: ts,
                            contrastColor: cc,
                            inverseContrastColor: ic);
                        if (picked != null) setSheet(() => ts = picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    ...["Subluxación", "Dislocación", "Inestabilidad Articular", "Dolor Articular", "Dolor Miofascial", "Dolor Neuropático"]
                        .map((type) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.warning_amber_rounded, color: cc),
                              title: Text(type, style: TextStyle(color: cc, fontSize: 14)),
                              onTap: () {
                                setState(() {
                                  _activeProfile!.structuralHistory.add(StructuralEvent(
                                    timestamp: ts, zone: zone, type: type,
                                  ));
                                  _saveData();
                                });
                                Navigator.pop(ctx);
                              },
                            )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editStructuralEvent(StructuralEvent event, Color cc, Color ic) {
    DateTime ts = event.timestamp;
    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("EDITAR: ${event.zone.toUpperCase()} / ${event.type}",
                    style: TextStyle(color: cc, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                  icon: Icon(Icons.access_time, color: cc, size: 16),
                  label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                      style: TextStyle(color: cc, fontSize: 12)),
                  onPressed: () async {
                    final picked = await pickTimestamp(
                        context: ctx, initial: ts, contrastColor: cc, inverseContrastColor: ic);
                    if (picked != null) setSheet(() => ts = picked);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc, minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() {
                      final idx = _activeProfile!.structuralHistory.indexOf(event);
                      if (idx >= 0) {
                        _activeProfile!.structuralHistory[idx] = event.copyWith(timestamp: ts);
                        _saveData();
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text('GUARDAR', style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editDoseEvent(DoseEvent event, Color cc, Color ic) {
    DateTime ts = event.timestamp;
    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("EDITAR HORA: ${event.medicationName.toUpperCase()}",
                    style: TextStyle(color: cc, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                  icon: Icon(Icons.access_time, color: cc, size: 16),
                  label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                      style: TextStyle(color: cc, fontSize: 12)),
                  onPressed: () async {
                    final picked = await pickTimestamp(
                        context: ctx, initial: ts, contrastColor: cc, inverseContrastColor: ic);
                    if (picked != null) setSheet(() => ts = picked);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc, minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() {
                      final idx = _activeProfile!.doseHistory.indexOf(event);
                      if (idx >= 0) {
                        _activeProfile!.doseHistory[idx] = event.copyWith(timestamp: ts);
                        _saveData();
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text('GUARDAR', style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logDose(MedicationDef med, Color cc, Color ic) {
    DateTime ts = _timestampForLog();
    final recentSymptoms = _activeProfile!.recentSignificantSymptoms(hours: 4);
    SymptomEvent? selectedSymptom;
    final trackOutcome = ValueNotifier<bool>(med.outcomeCheckHours != null && recentSymptoms.isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("REGISTRAR: ${med.name.toUpperCase()}",
                      style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(med.defaultDose,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                    icon: Icon(Icons.access_time, color: cc, size: 16),
                    label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: cc, fontSize: 12)),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                          context: ctx, initial: ts, contrastColor: cc, inverseContrastColor: ic);
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  if (med.outcomeCheckHours != null && recentSymptoms.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: cc.withValues(alpha: 0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: trackOutcome,
                            builder: (_, val, __) => Row(
                              children: [
                                Checkbox(
                                  value: val,
                                  activeColor: cc,
                                  onChanged: (v) => trackOutcome.value = v ?? false,
                                ),
                                Expanded(
                                  child: Text(
                                    "Hacer seguimiento ${med.outcomeCheckHours}h después",
                                    style: TextStyle(color: cc, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: trackOutcome,
                            builder: (_, val, __) {
                              if (!val) return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text("¿Para qué síntoma?",
                                      style: TextStyle(color: cc, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  ...recentSymptoms.take(5).map((s) => RadioListTile<SymptomEvent>(
                                        value: s,
                                        groupValue: selectedSymptom,
                                        activeColor: cc,
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          "${s.name} (${s.severity.label}) — ${DateFormat('HH:mm').format(s.timestamp)}",
                                          style: TextStyle(color: cc, fontSize: 12),
                                        ),
                                        onChanged: (v) => setSheet(() => selectedSymptom = v),
                                      )),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cc, minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final dose = DoseEvent(
                        timestamp: ts,
                        medicationName: med.name,
                        linkedSymptomIds: selectedSymptom != null ? [selectedSymptom!.id] : const [],
                      );
                      setState(() {
                        _activeProfile!.doseHistory.add(dose);
                        if (trackOutcome.value &&
                            selectedSymptom != null &&
                            med.outcomeCheckHours != null) {
                          _activeProfile!.medicationOutcomes.add(MedicationOutcome(
                            doseId: dose.id,
                            symptomId: selectedSymptom!.id,
                            medicationName: med.name,
                            symptomName: selectedSymptom!.name,
                            doseTimestamp: ts,
                            checkAt: ts.add(Duration(hours: med.outcomeCheckHours!)),
                          ));
                        }
                        _saveData();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text('REGISTRAR DOSIS',
                        style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openActivityMenu(ExerciseDef ex, Color cc, Color ic) {
    DateTime ts = _timestampForLog();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final hhrCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    int effort = 5;
    int feeling = 3;

    showModalBottomSheet(
      context: context,
      backgroundColor: ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.name.toUpperCase(),
                      style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                    icon: Icon(Icons.access_time, color: cc, size: 16),
                    label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: cc, fontSize: 12)),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                          context: ctx, initial: ts, contrastColor: cc, inverseContrastColor: ic);
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (ex.durationBased)
                    TextField(
                      controller: durationCtrl,
                      style: TextStyle(color: cc),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "Duración (min)", hintStyle: TextStyle(color: Colors.grey)),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: setsCtrl,
                            style: TextStyle(color: cc),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: "Sets", hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            style: TextStyle(color: cc),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: "Reps", hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hhrCtrl,
                    style: TextStyle(color: cc),
                    decoration: const InputDecoration(
                        hintText: "HHR opcional (ej. 70→110)", hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  Text("Esfuerzo: $effort/10",
                      style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 12)),
                  Slider(
                    value: effort.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: cc,
                    label: '$effort',
                    onChanged: (v) => setSheet(() => effort = v.toInt()),
                  ),
                  Text("Cómo me sentí: $feeling/5",
                      style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_feelingLabel(feeling),
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Slider(
                    value: feeling.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: cc,
                    label: '$feeling',
                    onChanged: (v) => setSheet(() => feeling = v.toInt()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: cc),
                    decoration: const InputDecoration(
                        hintText: "Nota opcional", hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cc, minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      setState(() {
                        _activeProfile!.activityHistory.add(ActivityEvent(
                          timestamp: ts,
                          name: ex.name,
                          sets: int.tryParse(setsCtrl.text),
                          reps: int.tryParse(repsCtrl.text),
                          durationMinutes: int.tryParse(durationCtrl.text),
                          effort: effort,
                          feeling: feeling,
                          hhr: hhrCtrl.text.trim().isEmpty ? null : hhrCtrl.text.trim(),
                          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                        ));
                        _saveData();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text('GUARDAR ACTIVIDAD',
                        style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _feelingLabel(int v) => switch (v) {
        1 => '🤕 En dolor / lesión',
        2 => '😟 Incómodo / preocupado',
        3 => '😐 Neutral',
        4 => '😊 Relajado',
        5 => '💪 Fuerte y seguro',
        _ => '$v',
      };
}