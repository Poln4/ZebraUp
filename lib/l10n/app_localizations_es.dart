// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navHoy => 'Hoy';

  @override
  String get navSintomas => 'Síntomas';

  @override
  String get navMovimiento => 'Movimiento';

  @override
  String get navBotiquin => 'Botiquín';

  @override
  String get navClinica => 'Clínica';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionUnderstood => 'Entendido';

  @override
  String get languageSectionTitle => 'IDIOMA / LANGUAGE';

  @override
  String get languageFootnote =>
      'El idioma se aplica a toda la aplicación. Tus datos no cambian.';

  @override
  String get myDataTitle => 'MIS DATOS';

  @override
  String get arcoRightsBlurb =>
      'Tienes derecho a acceder, exportar, importar o eliminar tus datos en cualquier momento.';

  @override
  String get exportDataButton => 'EXPORTAR MIS DATOS';

  @override
  String get importFileButton => 'IMPORTAR DESDE ARCHIVO';

  @override
  String get importPasteButton => 'IMPORTAR PEGANDO TEXTO';

  @override
  String get wipeAllButton => 'BORRAR TODO';

  @override
  String get wipeWarningFootnote =>
      'Esta acción borra todos los perfiles, registros y configuraciones. Irreversible.';

  @override
  String exportSuccess(String filename) {
    return 'Datos exportados: $filename';
  }

  @override
  String exportError(String reason) {
    return 'Error al exportar: $reason';
  }

  @override
  String importCancelled(String reason) {
    return 'Importación cancelada: $reason';
  }

  @override
  String get importSuccess => 'Perfil importado correctamente.';

  @override
  String get importDialogTitle => 'Importar este perfil';

  @override
  String importDialogName(String name) {
    return 'Nombre: $name';
  }

  @override
  String importDialogExportedAt(String date) {
    return 'Exportado: $date';
  }

  @override
  String importDialogContains(int count) {
    return 'Contiene $count registros:';
  }

  @override
  String get importDialogFootnote =>
      'Esto se agregará como un perfil nuevo. Tu perfil actual no se borra.';

  @override
  String get nounSymptoms => 'síntomas';

  @override
  String get nounDoses => 'dosis';

  @override
  String get nounStructural => 'eventos estructurales';

  @override
  String get nounActivities => 'actividades';

  @override
  String get nounTherapies => 'terapias';

  @override
  String get nounMoods => 'estados de ánimo';

  @override
  String get nounMental => 'registros mentales';

  @override
  String get pasteImportTitle => 'Importar pegando texto';

  @override
  String get pasteImportInstructions =>
      'Abre tu archivo .json exportado (por ejemplo, desde la app Archivos), selecciona todo el texto, cópialo y pégalo aquí.';

  @override
  String get pasteImportHint => 'Pega aquí el contenido del archivo…';

  @override
  String get errImportUnreadable => 'No se pudo leer el archivo.';

  @override
  String get errImportInvalidJson => 'El texto no es JSON válido.';

  @override
  String get errImportNotZebra => 'Este archivo no parece ser de ZebraUpp.';

  @override
  String get errImportUnknownSchema => 'Versión de esquema desconocida.';

  @override
  String errImportSchemaMismatch(String found, String expected) {
    return 'Este archivo es de una versión diferente (v$found). Versión esperada: v$expected.';
  }

  @override
  String get errImportMissingProfile => 'No se encontró perfil en el archivo.';

  @override
  String get errImportCorruptProfile =>
      'El perfil está dañado o tiene un formato inesperado.';
}
