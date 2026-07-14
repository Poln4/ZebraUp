// Sprint P.C — Account & data (ARCO rights), split out of the
// monolithic settings Drawer. Pure presentation: every action
// (export/import/wipe) stays in main_screen.dart's ProfileIoService
// calls and is injected here as a callback, since those methods need
// main_screen.dart's own BuildContext/SnackBar/setState plumbing.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AccountDataScreen extends StatelessWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final Future<void> Function() onExport;
  final Future<void> Function() onImportFile;
  final Future<void> Function() onImportPaste;
  final Future<void> Function() onWipeAll;

  const AccountDataScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onExport,
    required this.onImportFile,
    required this.onImportPaste,
    required this.onWipeAll,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final ic = inverseContrastColor;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ic,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.settingsMyDataTitle,
                      style: TextStyle(
                        color: cc,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settingsDataHelper,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.download_outlined, color: cc),
                      label: Text(
                        t.settingsExportDataButton,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: onExport,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.upload_file_outlined, color: cc),
                      label: Text(
                        t.importFileButton,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: onImportFile,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.content_paste_go_outlined, color: cc),
                      label: Text(
                        t.importPasteButton,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: onImportPaste,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                      ),
                      label: Text(
                        t.settingsWipeAllButton,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: onWipeAll,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.settingsWipeAllHelper,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
