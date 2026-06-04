import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zebraBox');
  runApp(const ZebraUppApp());
}

class ZebraUppApp extends StatefulWidget {
  const ZebraUppApp({super.key});

  @override
  State<ZebraUppApp> createState() => _ZebraUppAppState();
}

class _ZebraUppAppState extends State<ZebraUppApp> {
  bool isDarkMode = true;
  double fontScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra Upp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16 * fontScale),
          bodyMedium: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14 * fontScale),
          titleLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 22 * fontScale, fontWeight: FontWeight.bold),
        ),
      ),
      home: MainAppScreen(
        isDarkMode: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        fontScale: fontScale,
        onScaleFont: (value) => setState(() => fontScale = value),
      ),
    );
  }
}

// ---------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------
class Medication {
  String name;
  String doseDetails;
  Map<String, int> dailyHistory;

  Medication({required this.name, required this.doseDetails, Map<String, int>? history}) : dailyHistory = history ?? {};

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  int getDoseForDate(DateTime date) => dailyHistory[_getDateKey(date)] ?? 0;
  void updateDose(DateTime date, int delta) {
    String key = _getDateKey(date);
    int currentDose = getDoseForDate(date);
    if (currentDose + delta >= 0) dailyHistory[key] = currentDose + delta;
  }

  Map<String, dynamic> toMap() => {'name': name, 'doseDetails': doseDetails, 'dailyHistory': dailyHistory};
  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
    name: map['name'], doseDetails: map['doseDetails'], history: Map<String, int>.from(map['dailyHistory'] ?? {})
  );
}

class StructuralEvent {
  String zone;
  String type; 
  String dateKey;

  StructuralEvent({required this.zone, required this.type, required this.dateKey});

  Map<String, dynamic> toMap() => {'zone': zone, 'type': type, 'dateKey': dateKey};
  factory StructuralEvent.fromMap(Map<String, dynamic> map) => StructuralEvent(zone: map['zone'], type: map['type'], dateKey: map['dateKey']);
}

class Profile {
  final String id;
  String name;
  String dob;
  List<String> conditions;
  List<Medication> medications;
  Map<String, String> activeSymptoms; 
  List<String> inactiveVault;
  Set<String> pacingDays; 
  List<StructuralEvent> structuralEvents; 

  Profile({
    required this.id, required this.name, required this.dob, required this.conditions,
    required this.medications, required this.activeSymptoms, required this.inactiveVault,
    Set<String>? pacing, List<StructuralEvent>? structural,
  }) : pacingDays = pacing ?? {}, structuralEvents = structural ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'dob': dob, 'conditions': conditions,
    'activeSymptoms': activeSymptoms, 'inactiveVault': inactiveVault, 'pacingDays': pacingDays.toList(),
    'medications': medications.map((x) => x.toMap()).toList(),
    'structuralEvents': structuralEvents.map((x) => x.toMap()).toList(),
  };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'], name: map['name'], dob: map['dob'],
    conditions: List<String>.from(map['conditions'] ?? []),
    activeSymptoms: Map<String, String>.from(map['activeSymptoms'] ?? {}),
    inactiveVault: List<String>.from(map['inactiveVault'] ?? []),
    pacing: Set<String>.from(map['pacingDays'] ?? []),
    medications: List<Medication>.from((map['medications'] ?? []).map((x) => Medication.fromMap(x))),
    structural: List<StructuralEvent>.from((map['structuralEvents'] ?? []).map((x) => StructuralEvent.fromMap(x))),
  );
}

class WisdomQuote {
  final String text;
  final String category;
  WisdomQuote({required this.text, required this.category});
}

class ClinicalArticle {
  final String category;
  final String title;
  final String content;
  ClinicalArticle({required this.category, required this.title, required this.content});
}

// ---------------------------------------------------------
// MAIN APPLICATION STATE
// ---------------------------------------------------------
class MainAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final double fontScale;
  final ValueChanged<double> onScaleFont;

  const MainAppScreen({
    super.key, required this.isDarkMode, required this.onToggleTheme,
    required this.fontScale, required this.onScaleFont,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late List<Profile> _profiles;
  late Profile _activeProfile;
  
  late List<WisdomQuote> _wisdomDatabase;
  late WisdomQuote _dailyWisdom;
  late List<ClinicalArticle> _clinicalLibraryDatabase;

  int _currentNavIndex = 0; 
  bool _isEditingMode = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedReportSpecialty = "General"; 

  final _profileNameController = TextEditingController();
  final _newDiagnosisController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedNameController = TextEditingController();
  final _newMedDoseController = TextEditingController();

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _loadSimulatedLibraries();
    _loadUserProfiles();
  }

  void _saveData() {
    var box = Hive.box('zebraBox');
    String encodedData = json.encode(_profiles.map((p) => p.toMap()).toList());
    box.put('profiles', encodedData);
  }

  void _loadSimulatedLibraries() {
    _wisdomDatabase = [
      WisdomQuote(text: "Descansar no es rendirse; es una intervención médica necesaria para tu sistema nervioso.", category: "Pacing"),
      WisdomQuote(text: "Tus síntomas son reales, incluso cuando los exámenes de rutina no los muestran.", category: "Validación"),
      WisdomQuote(text: "El mundo es tu papa. Hoy toca reparar.", category: "Potato Day"),
    ];
    _dailyWisdom = _wisdomDatabase[Random().nextInt(_wisdomDatabase.length)];

    _clinicalLibraryDatabase = [
      ClinicalArticle(category: "Tejido Conectivo", title: "Criterios Beighton", content: "Evaluación basada en 9 puntos de hipermovilidad articular. Implica fragilidad de tejidos blandos."),
      ClinicalArticle(category: "Disautonomía", title: "POTS e Intolerancia Ortostática", content: "Taquicardia severa al ponerse de pie acompañada de niebla mental debido al estancamiento del flujo sanguíneo.")
    ];
  }

  void _loadUserProfiles() {
    var box = Hive.box('zebraBox');
    String? storedData = box.get('profiles');

    if (storedData != null) {
      List<dynamic> decoded = json.decode(storedData);
      _profiles = decoded.map((x) => Profile.fromMap(x)).toList();
    } else {
      _profiles = [
        Profile(
          id: '1', name: 'Paulina (Me)', dob: '1991-09-04',
          conditions: ['clEDS', 'Adenomiosis', 'POTS', 'Anemia'],
          medications: [
            Medication(name: 'Hierro', doseDetails: '14mg'),
            Medication(name: 'Vitamina C', doseDetails: '1000mg'),
            Medication(name: 'Duloxetina', doseDetails: '60mg'),
            Medication(name: 'Ibuprofeno', doseDetails: '400mg (SOS)'),
          ],
          activeSymptoms: {'Fatiga crónica': 'Moderado', 'Niebla mental': 'Severo'},
          inactiveVault: ['Taquicardia ortostática', 'Mareos al pararse', 'Reflujo gástrico', 'Náuseas', 'Moratones'],
        ),
      ];
      _saveData();
    }
    
    if (_profiles.isNotEmpty) {
      _activeProfile = _profiles[0];
      _updateControllers();
    }
  }

  void _updateControllers() {
    _profileNameController.text = _activeProfile.name;
  }

  List<Map<String, dynamic>> _generateClinicalFlags() {
    List<Map<String, dynamic>> flags = [];
    final meds = _activeProfile.medications.map((m) => m.name.toLowerCase()).toList();
    final diagnoses = _activeProfile.conditions.map((c) => c.toLowerCase()).toList();

    if (meds.any((m) => m.contains('hierro')) && meds.any((m) => m.contains('vitamina c'))) {
      flags.add({"type": "positive", "message": "💡 SINERGIA ÓPTIMA: La Vitamina C potencia la absorción del hierro."});
    }
    
    if (meds.any((m) => m.contains('duloxetina')) && meds.any((m) => m.contains('ibuprofeno'))) {
      if (diagnoses.contains('cleds') || diagnoses.contains('adenomiosis')) {
        flags.add({
          "type": "severe", 
          "message": "🚨 ALERTA HEMORRÁGICA: Duloxetina + AINEs elevan el riesgo de sangrado debido a tus diagnósticos activos (clEDS/Adenomiosis)."
        });
      }
    }
    return flags;
  }

  @override
  Widget build(BuildContext context) {
    Color contrastColor = widget.isDarkMode ? Colors.white : Colors.black;
    Color inverseContrastColor = widget.isDarkMode ? Colors.black : Colors.white;

    String appBarTitle = _currentNavIndex == 0 ? _activeProfile.name.toUpperCase() 
                       : _currentNavIndex == 1 ? "PANEL DE INFORMES" 
                       : "BIBLIOTECA CLÍNICA";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: contrastColor, height: 1.0)),
        title: _currentNavIndex != 0 
            ? Text(appBarTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1))
            : DropdownButton<Profile>(
                value: _activeProfile,
                dropdownColor: inverseContrastColor,
                icon: Icon(Icons.arrow_drop_down, color: contrastColor),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1),
                underline: Container(),
                onChanged: (Profile? newProfile) {
                  if (newProfile != null) {
                    setState(() { _activeProfile = newProfile; _updateControllers(); });
                  }
                },
                items: _profiles.map<DropdownMenuItem<Profile>>((Profile profile) {
                  return DropdownMenuItem<Profile>(value: profile, child: Text(profile.name.toUpperCase()));
                }).toList(),
              ),
        actions: [
          if (_currentNavIndex == 0)
            IconButton(
              icon: Icon(_isEditingMode ? Icons.playlist_add_check_rounded : Icons.settings_outlined, color: contrastColor, size: 28),
              onPressed: () => setState(() => _isEditingMode = !_isEditingMode),
            ),
          IconButton(icon: Icon(Icons.text_fields, color: contrastColor), onPressed: () => widget.onScaleFont(widget.fontScale >= 1.4 ? 1.0 : widget.fontScale + 0.2)),
          IconButton(icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: contrastColor), onPressed: widget.onToggleTheme),
        ],
      ),
      body: _currentNavIndex == 0 
          ? (_isEditingMode ? _buildConfigurationView(contrastColor, inverseContrastColor) : _buildMainTrackingView(contrastColor, inverseContrastColor))
          : (_currentNavIndex == 1 ? _buildReportView(contrastColor, inverseContrastColor) : _buildCompendiumLibraryView(contrastColor)),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: contrastColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() { _currentNavIndex = index; _isEditingMode = false; }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Rastreador'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_outlined), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Biblioteca'),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(Color contrastColor, Color inverseContrastColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: contrastColor, width: 1))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        reverse: true,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().subtract(Duration(days: index));
          String dateKey = _getDateKey(date);
          bool isSelected = dateKey == _getDateKey(_selectedDate);
          bool isPacing = _activeProfile.pacingDays.contains(dateKey); 
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? contrastColor : Colors.transparent,
                border: Border.all(color: contrastColor, width: isPacing ? 2 : 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(date).toUpperCase(), style: TextStyle(fontSize: 10 * widget.fontScale, color: isSelected ? inverseContrastColor : contrastColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  isPacing 
                      ? Icon(Icons.shield_outlined, color: isSelected ? inverseContrastColor : contrastColor, size: 20 * widget.fontScale)
                      : Text(DateFormat('d').format(date), style: TextStyle(fontSize: 16 * widget.fontScale, color: isSelected ? inverseContrastColor : contrastColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSeverityMenu(String symptom, Color contrastColor, Color inverseContrastColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: inverseContrastColor,
      shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GRAVEDAD DE: ${symptom.toUpperCase()}", style: TextStyle(color: contrastColor, fontSize: 16 * widget.fontScale, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.green),
                title: Text("Leve", style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
                onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Leve"; _saveData(); }); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.orange),
                title: Text("Moderado", style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
                onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Moderado"; _saveData(); }); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.red),
                title: Text("Severo", style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
                onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Severo"; _saveData(); }); Navigator.pop(context); },
              ),
            ],
          ),
        );
      }
    );
  }

  void _openStructuralMenu(String zone, Color contrastColor, Color inverseContrastColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: inverseContrastColor,
      shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("REGISTRAR EN: ${zone.toUpperCase()}", style: TextStyle(color: contrastColor, fontSize: 16 * widget.fontScale, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...["Subluxación", "Dislocación", "Inestabilidad Articular", "Dolor Articular", "Dolor Miofascial", "Dolor Neuropático"]
                  .map((type) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.warning_amber_rounded, color: contrastColor),
                    title: Text(type, style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
                    onTap: () {
                      setState(() {
                        _activeProfile.structuralEvents.add(StructuralEvent(zone: zone, type: type, dateKey: _getDateKey(_selectedDate)));
                        _saveData();
                      });
                      Navigator.pop(context);
                    },
                  )),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMainTrackingView(Color contrastColor, Color inverseContrastColor) {
    String currentDateKey = _getDateKey(_selectedDate);
    bool isCurrentlyPacing = _activeProfile.pacingDays.contains(currentDateKey);
    List<StructuralEvent> todaysEvents = _activeProfile.structuralEvents.where((e) => e.dateKey == currentDateKey).toList();
    List<Map<String, dynamic>> activeFlags = _generateClinicalFlags();

    return Column(
      children: [
        _buildCalendarStrip(contrastColor, inverseContrastColor),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
                child: Text('"${_dailyWisdom.text}"', style: TextStyle(color: contrastColor, fontSize: 15 * widget.fontScale, fontStyle: FontStyle.italic, height: 1.4)),
              ),

              InkWell(
                onTap: () => setState(() {
                  isCurrentlyPacing ? _activeProfile.pacingDays.remove(currentDateKey) : _activeProfile.pacingDays.add(currentDateKey);
                  _saveData();
                }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrentlyPacing ? contrastColor : Colors.transparent,
                    border: Border.all(color: contrastColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(isCurrentlyPacing ? Icons.shield : Icons.shield_outlined, color: isCurrentlyPacing ? inverseContrastColor : contrastColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text("POTATO DAY (RECUPERACIÓN)", style: TextStyle(color: isCurrentlyPacing ? inverseContrastColor : contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text("MAPA DE ZONAS ESTRUCTURALES", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, letterSpacing: 1)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ["Cervicales", "Hombros", "Muñecas", "Manos", "Lumbar/Pelvis", "Caderas", "Rodillas", "Tobillos"]
                  .map((zone) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: contrastColor),
                    label: Text(zone, style: TextStyle(color: contrastColor, fontSize: 12 * widget.fontScale)),
                    onPressed: () => _openStructuralMenu(zone, contrastColor, inverseContrastColor),
                  )).toList(),
              ),
              
              if (todaysEvents.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: contrastColor)),
                  child: Column(
                    children: todaysEvents.map((event) => Row(
                      children: [
                        Icon(Icons.adjust, color: contrastColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text("${event.zone}: ${event.type}", style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale))),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 18), onPressed: () => setState(() { _activeProfile.structuralEvents.remove(event); _saveData(); }))
                      ],
                    )).toList(),
                  ),
                )
              ],
              const SizedBox(height: 24),

              if (activeFlags.isNotEmpty) ...[
                Text("ANÁLISIS CLÍNICO AUTOMÁTICO", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...activeFlags.map((flag) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: flag["type"] == "severe" ? Colors.redAccent : contrastColor, width: 2)),
                      child: Text(flag["message"], style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
                    )),
                const Divider(thickness: 1, color: Colors.grey),
              ],

              Text("SÍNTOMAS ACTIVOS", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _activeProfile.activeSymptoms.entries.map((entry) {
                  Color chipColor = entry.value == "Leve" ? (widget.isDarkMode ? Colors.green[900]! : Colors.green[100]!) 
                                  : entry.value == "Moderado" ? (widget.isDarkMode ? Colors.orange[900]! : Colors.orange[100]!) 
                                  : (widget.isDarkMode ? Colors.red[900]! : Colors.red[100]!);
                  return InputChip(
                    backgroundColor: chipColor,
                    side: BorderSide(color: contrastColor),
                    label: Text("${entry.key} (${entry.value})", style: TextStyle(fontSize: 14 * widget.fontScale)),
                    onPressed: () => _openSeverityMenu(entry.key, contrastColor, inverseContrastColor),
                    onDeleted: () => setState(() { _activeProfile.activeSymptoms.remove(entry.key); _activeProfile.inactiveVault.insert(0, entry.key); _saveData(); }),
                    deleteIconColor: contrastColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              Text("BAÚL INACTIVO (+)", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _activeProfile.inactiveVault.map((symptom) => ActionChip(
                  backgroundColor: inverseContrastColor,
                  side: BorderSide(color: contrastColor),
                  label: Text(symptom, style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
                  onPressed: () => setState(() { _activeProfile.inactiveVault.remove(symptom); _activeProfile.activeSymptoms[symptom] = "Moderado"; _saveData(); }),
                )).toList(),
              ),
              const SizedBox(height: 24),

              Text("SEGUIMIENTO DE SUPLEMENTOS / REMEDIOS", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, letterSpacing: 1)),
              const SizedBox(height: 8),
              ..._activeProfile.medications.map((med) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: contrastColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(med.name, style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 15 * widget.fontScale)), 
                      Text(med.doseDetails, style: TextStyle(fontSize: 12 * widget.fontScale, color: Colors.grey))
                    ])),
                    Row(children: [
                      IconButton(icon: Icon(Icons.remove_circle_outline, color: contrastColor), onPressed: () => setState(() { med.updateDose(_selectedDate, -1); _saveData(); })),
                      Text("${med.getDoseForDate(_selectedDate)}", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale)), 
                      IconButton(icon: Icon(Icons.add_circle_outline, color: contrastColor), onPressed: () => setState(() { med.updateDose(_selectedDate, 1); _saveData(); })),
                    ])
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationView(Color contrastColor, Color inverseContrastColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("CONFIGURACIÓN DE PERFIL CLÍNICO", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale, letterSpacing: 1)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: TextField(
            controller: _profileNameController,
            decoration: InputDecoration(labelText: "Nombre del Paciente", labelStyle: TextStyle(color: contrastColor)),
            style: TextStyle(color: contrastColor),
            onChanged: (val) => setState(() { _activeProfile.name = val; _saveData(); }),
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GESTIONAR DIAGNÓSTICOS / COMORBILIDADES", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newDiagnosisController,
                      style: TextStyle(color: contrastColor),
                      decoration: const InputDecoration(hintText: "Añadir diagnóstico (Ej. MCAS, CCI)", hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, size: 32, color: contrastColor),
                    onPressed: () {
                      if (_newDiagnosisController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile.conditions.add(_newDiagnosisController.text.trim());
                          _newDiagnosisController.clear();
                          _saveData();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _activeProfile.conditions.isEmpty 
                  ? const Text("Sin diagnósticos registrados.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                  : Wrap(
                      spacing: 8, runSpacing: 4,
                      children: _activeProfile.conditions.map((condition) => InputChip(
                        label: Text(condition, style: TextStyle(color: inverseContrastColor)),
                        backgroundColor: contrastColor,
                        onDeleted: () => setState(() { _activeProfile.conditions.remove(condition); _saveData(); }),
                        deleteIconColor: inverseContrastColor,
                      )).toList(),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Row(
            children: [
              Expanded(child: TextField(
                controller: _newSymptomController, 
                style: TextStyle(color: contrastColor),
                decoration: const InputDecoration(hintText: "Añadir síntoma personalizado al baúl", hintStyle: TextStyle(color: Colors.grey))
              )),
              IconButton(icon: Icon(Icons.add_box_rounded, size: 32, color: contrastColor), onPressed: () {
                if (_newSymptomController.text.trim().isNotEmpty) {
                  setState(() { _activeProfile.inactiveVault.insert(0, _newSymptomController.text.trim()); _newSymptomController.clear(); _saveData(); });
                }
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AÑADIR NUEVO MEDICAMENTO / SUPLEMENTO", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              TextField(controller: _newMedNameController, style: TextStyle(color: contrastColor), decoration: const InputDecoration(hintText: "Nombre (Ej. Visanne)", hintStyle: TextStyle(color: Colors.grey))),
              Row(
                children: [
                  Expanded(child: TextField(controller: _newMedDoseController, style: TextStyle(color: contrastColor), decoration: const InputDecoration(hintText: "Dosis (Ej. 2mg)", hintStyle: TextStyle(color: Colors.grey)))),
                  IconButton(icon: Icon(Icons.add_box_rounded, size: 32, color: contrastColor), onPressed: () {
                    if (_newMedNameController.text.trim().isNotEmpty) {
                      setState(() {
                        _activeProfile.medications.add(Medication(name: _newMedNameController.text.trim(), doseDetails: _newMedDoseController.text.trim()));
                        _newMedNameController.clear(); _newMedDoseController.clear(); _saveData();
                      });
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(side: BorderSide(color: contrastColor, width: 2), padding: const EdgeInsets.symmetric(vertical: 12)),
          icon: Icon(Icons.person_add_alt_1_rounded, color: contrastColor),
          label: Text("CREAR NUEVO PERFIL (EJ. MAMÁ)", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold)),
          onPressed: () {
            setState(() {
              final newId = (_profiles.length + 1).toString();
              final newProfile = Profile(
                id: newId, name: "NUEVO PERFIL $newId", dob: "1960-01-01",
                conditions: [], medications: [], activeSymptoms: {}, inactiveVault: [],
              );
              _profiles.add(newProfile);
              _activeProfile = newProfile;
              _updateControllers();
              _saveData();
            });
          },
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: contrastColor, foregroundColor: inverseContrastColor, padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () => setState(() => _isEditingMode = false),
          child: const Text("GUARDAR PERFIL", style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // FIX: Added inverseContrastColor to the method signature
  Widget _buildReportView(Color contrastColor, Color inverseContrastColor) {
    Map<String, String> filteredSymptoms = _activeProfile.activeSymptoms;
    List<Medication> filteredMeds = _activeProfile.medications;

    if (_selectedReportSpecialty == "Ortopedia/Fisio") {
      filteredMeds = _activeProfile.medications.where((m) => m.name.contains("Ibuprofeno") || m.name.contains("Duloxetina")).toList();
      filteredSymptoms = Map.fromEntries(_activeProfile.activeSymptoms.entries.where((e) => e.key.contains("Tensión") || e.key.contains("Dolor") || e.key.contains("Fatiga")));
    } else if (_selectedReportSpecialty == "Hematología") {
      filteredMeds = _activeProfile.medications.where((m) => m.name.contains("Hierro") || m.name.contains("Vitamina C")).toList();
      filteredSymptoms = Map.fromEntries(_activeProfile.activeSymptoms.entries.where((e) => e.key.contains("Moratones") || e.key.contains("Sangrado") || e.key.contains("Fatiga")));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("FILTRAR VISTA PARA CONSULTA MÉDICA", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ["General", "Ortopedia/Fisio", "Hematología"].map((spec) => ChoiceChip(
            backgroundColor: _selectedReportSpecialty == spec ? contrastColor : Colors.transparent,
            labelStyle: TextStyle(color: _selectedReportSpecialty == spec ? inverseContrastColor : contrastColor),
            side: BorderSide(color: contrastColor),
            label: Text(spec),
            selected: _selectedReportSpecialty == spec,
            onSelected: (bool selected) => setState(() => _selectedReportSpecialty = spec),
          )).toList(),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PACIENTE: ${_activeProfile.name}", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontSize: 14 * widget.fontScale)),
              Text("FECHA EVALUADA: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontSize: 14 * widget.fontScale)),
              Divider(color: contrastColor),
              
              Text("DIAGNÓSTICOS CLÍNICOS ACTIVOS:", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.conditions.map((c) => Text(" • $c", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              
              Text("SUPLEMENTACIÓN Y TRATAMIENTO:", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ...filteredMeds.map((m) => Text(" • ${m.name} - Tomado Hoy: ${m.getDoseForDate(_selectedDate)}", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              
              Text("SÍNTOMAS REPORTADOS:", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ...filteredSymptoms.entries.map((s) => Text(" • ${s.key} [${s.value.toUpperCase()}]", style: TextStyle(color: contrastColor, fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompendiumLibraryView(Color contrastColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: _clinicalLibraryDatabase.map((article) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
        child: ExpansionTile(
          iconColor: contrastColor, collapsedIconColor: contrastColor,
          title: Text(article.title, style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale)),
          children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(article.content, style: TextStyle(color: contrastColor, height: 1.5, fontSize: 14 * widget.fontScale)))],
        ),
      )).toList(),
    );
  }
}