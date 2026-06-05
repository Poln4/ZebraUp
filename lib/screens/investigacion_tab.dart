import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/pubmed_service.dart';

/// Research tab — auto-fetches PubMed results for each user condition.
class InvestigacionTab extends StatefulWidget {
  final Profile profile;
  final PubMedService service;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(String pmid) onToggleSave;

  const InvestigacionTab({
    super.key,
    required this.profile,
    required this.service,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onToggleSave,
  });

  @override
  State<InvestigacionTab> createState() => _InvestigacionTabState();
}

class _InvestigacionTabState extends State<InvestigacionTab>
    with AutomaticKeepAliveClientMixin {
  final Map<String, PubMedSearchResult> _results = {};
  final Set<String> _loading = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Auto-fetch on first open for each condition
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  Future<void> _fetchAll({bool force = false}) async {
    for (final cond in widget.profile.conditions) {
      if (!_results.containsKey(cond) || force) {
        _fetchOne(cond, force: force);
      }
    }
  }

  Future<void> _fetchOne(String condition, {bool force = false}) async {
    if (_loading.contains(condition)) return;
    setState(() => _loading.add(condition));
    try {
      final result = await widget.service.searchForCondition(
        condition: condition,
        forceRefresh: force,
      );
      if (mounted) {
        setState(() {
          _results[condition] = result;
          _loading.remove(condition);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading.remove(condition));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    if (widget.profile.conditions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "Añade un diagnóstico en configuración para ver investigación relevante.",
            style: TextStyle(color: cc, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchAll(force: true),
      color: cc,
      backgroundColor: ic,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Resultados recientes de PubMed",
            style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            "Desliza para actualizar. Solo informativo, no es consejo médico.",
            style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          ...widget.profile.conditions.map((c) => _buildConditionSection(c, cc, ic)),
        ],
      ),
    );
  }

  Widget _buildConditionSection(String condition, Color cc, Color ic) {
    final result = _results[condition];
    final isLoading = _loading.contains(condition);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(border: Border.all(color: cc)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: cc.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    condition.toUpperCase(),
                    style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                  ),
                ),
                if (result != null && result.fromCache)
                  Tooltip(
                    message: 'Resultados guardados (sin conexión)',
                    child: Icon(Icons.cloud_off_outlined, color: Colors.grey, size: 16),
                  ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cc),
                  ),
              ],
            ),
          ),
          if (result == null && !isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Sin datos. Tira hacia abajo para buscar.",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          if (result != null) ...[
            if (result.error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(result.error!,
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            if (result.articles.isEmpty && result.error == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("No se encontraron resultados recientes.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ...result.articles.map((a) => _buildArticleTile(a, cc, ic)),
            if (result.articles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  "Actualizado: ${DateFormat('d MMM HH:mm').format(result.fetchedAt)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildArticleTile(PubMedArticle a, Color cc, Color ic) {
    final isSaved = widget.profile.savedArticlePmids.contains(a.pmid);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cc.withValues(alpha: 0.3))),
      ),
      child: ExpansionTile(
        iconColor: cc,
        collapsedIconColor: cc,
        title: Text(
          a.title,
          style: TextStyle(color: cc, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${a.authorsShort} · ${a.journal} · ${DateFormat('MMM y').format(a.publicationDate)}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),
        children: [_ArticleDetail(article: a, service: widget.service, contrastColor: cc, inverseContrastColor: ic, isSaved: isSaved, onToggleSave: () => widget.onToggleSave(a.pmid))],
      ),
    );
  }
}

/// Lazy-loaded abstract + actions for an expanded article.
class _ArticleDetail extends StatefulWidget {
  final PubMedArticle article;
  final PubMedService service;
  final Color contrastColor;
  final Color inverseContrastColor;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const _ArticleDetail({
    required this.article,
    required this.service,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  State<_ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<_ArticleDetail> {
  String? _abstract;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAbstract();
  }

  Future<void> _loadAbstract() async {
    final a = await widget.service.fetchAbstract(widget.article.pmid);
    if (mounted) {
      setState(() {
        _abstract = a;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cc)),
                  const SizedBox(width: 8),
                  Text("Cargando resumen…",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          else if (_abstract == null || _abstract!.isEmpty)
            Text("Resumen no disponible. Abre el artículo en PubMed para más detalles.",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))
          else
            SelectableText(_abstract!,
                style: TextStyle(color: cc, fontSize: 12, height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: cc)),
                icon: Icon(
                  widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: cc, size: 16,
                ),
                label: Text(widget.isSaved ? 'Guardado' : 'Guardar',
                    style: TextStyle(color: cc, fontSize: 12)),
                onPressed: widget.onToggleSave,
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: cc)),
                icon: Icon(Icons.open_in_new, color: cc, size: 16),
                label: Text('Abrir en PubMed',
                    style: TextStyle(color: cc, fontSize: 12)),
                onPressed: () async {
                  final uri = Uri.parse(widget.article.pubmedUrl);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: cc)),
                icon: Icon(Icons.copy, color: cc, size: 16),
                label: Text('Copiar PMID',
                    style: TextStyle(color: cc, fontSize: 12)),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.article.pmid));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PMID ${widget.article.pmid} copiado.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}