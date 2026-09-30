import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../history/domain/assessment_record.dart';
import 'report_view.dart';

enum ReportFormat { pdf, image }

/// Share button for one assessment: pick PDF or image, then Android's share list.
class ShareReportButton extends StatelessWidget {
  const ShareReportButton({
    super.key,
    required this.record,
    this.compact = false,
  });

  final AssessmentRecord record;

  /// Small enough to sit beside a line of text, as on a history card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share_outlined, size: compact ? 18 : null),
      tooltip: AppLocalizations.of(context).shareReport,
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact ? EdgeInsets.zero : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 32, minHeight: 32)
          : null,
      onPressed: () => showShareReportSheet(context, record),
    );
  }
}

Future<void> showShareReportSheet(
  BuildContext context,
  AssessmentRecord record,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ReportFormat? format = await showModalBottomSheet<ReportFormat>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.shareReport,
              style: Theme.of(sheet).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.shareAsPdf),
            onTap: () => Navigator.pop(sheet, ReportFormat.pdf),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.shareAsImage),
            onTap: () => Navigator.pop(sheet, ReportFormat.image),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (format == null || !context.mounted) return;

  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: <Widget>[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.sharePreparing)),
          ],
        ),
      ),
    ),
  );

  final String date =
      DateFormat('d MMM yyyy', l10n.localeName).format(record.takenAt);
  bool dialogOpen = true;
  Object? failure;
  try {
    final XFile file = await _buildFile(context, record, format, l10n);
    navigator.pop();
    dialogOpen = false;
    await SharePlus.instance.share(ShareParams(
      files: <XFile>[file],
      subject: l10n.shareSubject(date),
    ));
    return;
  } catch (error, stack) {
    failure = error;
    debugPrint('Report share failed: $error\n$stack');
  }
  if (dialogOpen) navigator.pop();
  messenger.showSnackBar(SnackBar(
    // Debug builds show the cause, so a device-only failure can be diagnosed.
    content: Text(kDebugMode ? '${l10n.shareFailed}\n$failure' : l10n.shareFailed),
    duration: const Duration(seconds: 8),
  ));
}

Future<XFile> _buildFile(
  BuildContext context,
  AssessmentRecord record,
  ReportFormat format,
  AppLocalizations l10n,
) async {
  final Uint8List png = await ScreenshotController().captureFromLongWidget(
    MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Theme(
        data: AppTheme.light,
        child: Material(
          color: Colors.white,
          child: ReportView(record: record, l10n: l10n),
        ),
      ),
    ),
    context: context,
    pixelRatio: 3,
    delay: const Duration(milliseconds: 100),
    constraints: const BoxConstraints.tightFor(width: ReportView.width),
  );

  final Directory dir = await getTemporaryDirectory();
  final String stamp = DateFormat('yyyy-MM-dd_HHmm').format(record.takenAt);
  final String base = '${dir.path}/QoLGuard_report_$stamp';

  if (format == ReportFormat.image) {
    final File out = await File('$base.png').writeAsBytes(png);
    return XFile(out.path, mimeType: 'image/png');
  }
  final File out = await File('$base.pdf').writeAsBytes(await reportPdf(png));
  return XFile(out.path, mimeType: 'application/pdf');
}

/// Wraps the report image in a PDF one A4 page wide and as tall as it needs.
///
/// The image, not PDF text, carries the words: the PDF library cannot shape
/// Sinhala, so text would come out with broken letters.
Future<Uint8List> reportPdf(Uint8List png) {
  final pw.MemoryImage image = pw.MemoryImage(png);
  const double margin = 24;
  final double contentWidth = PdfPageFormat.a4.width - 2 * margin;
  final double contentHeight = contentWidth * image.height! / image.width!;
  final PdfPageFormat page = PdfPageFormat(
    PdfPageFormat.a4.width,
    math.max(PdfPageFormat.a4.height, contentHeight + 2 * margin),
    marginAll: margin,
  );

  final pw.Document doc = pw.Document(title: 'QoLGuard report');
  doc.addPage(pw.Page(
    pageFormat: page,
    build: (_) => pw.Image(image, width: contentWidth),
  ));
  return doc.save();
}
