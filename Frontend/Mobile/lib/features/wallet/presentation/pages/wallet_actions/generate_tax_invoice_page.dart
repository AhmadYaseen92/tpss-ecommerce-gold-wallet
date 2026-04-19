import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class GenerateTaxInvoicePage extends StatefulWidget {
  final WalletTransactionEntity asset;
  const GenerateTaxInvoicePage({super.key, required this.asset});

  @override
  State<GenerateTaxInvoicePage> createState() => _GenerateTaxInvoicePageState();
}

class _GenerateTaxInvoicePageState extends State<GenerateTaxInvoicePage> {
  bool _loadingView = false;
  bool _loadingDownload = false;

  String get _reference =>
      'INV-${widget.asset.name.replaceAll(' ', '').toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final issueDate = DateTime.now();
    final dueDate = issueDate.add(const Duration(days: 3));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Certificate Invoice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ActionSectionCard(
              title: 'Invoice Preview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          border: Border.all(color: Colors.black26),
                        ),
                        child: const Text('TPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'TPSS\nAmman',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TAX INVOICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          Text('Type: ${widget.asset.status}', style: const TextStyle(fontSize: 12)),
                          Text('Ref: $_reference', style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(child: _meta('Invoice #', _reference)),
                      Expanded(child: _meta('Action Type', widget.asset.status)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _meta('Issue Date', _fmt(issueDate))),
                      Expanded(child: _meta('Due Date', _fmt(dueDate))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _partyCard('Seller', widget.asset.sellerName, 'Wallet Metals Provider')),
                      const SizedBox(width: 8),
                      Expanded(child: _partyCard('Investor', 'Current Wallet User', 'Wallet Holder')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black26),
                    columnWidths: const {
                      0: FixedColumnWidth(30),
                      1: FlexColumnWidth(2.5),
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.6),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                        children: [
                          Padding(padding: EdgeInsets.all(6), child: Text('#', style: TextStyle(fontWeight: FontWeight.w700))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Description', style: TextStyle(fontWeight: FontWeight.w700))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w700))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w700))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                        ],
                      ),
                      TableRow(children: [
                        const Padding(padding: EdgeInsets.all(6), child: Text('1')),
                        Padding(padding: const EdgeInsets.all(6), child: Text(widget.asset.name)),
                        Padding(padding: const EdgeInsets.all(6), child: Text('\$${widget.asset.marketPricePerGram.toStringAsFixed(2)}')),
                        Padding(padding: const EdgeInsets.all(6), child: Text('${widget.asset.quantity}')),
                        Padding(padding: const EdgeInsets.all(6), child: Text(widget.asset.marketValue)),
                      ])
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                          child: Text(
                            'Wallet Item Id: ${widget.asset.id}\nWeight: ${widget.asset.weightInGrams.toStringAsFixed(3)} g\nPurity: ${widget.asset.purity}\nStatus: ${widget.asset.status}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _meta('Taxable', widget.asset.marketValue),
                            _meta('VAT', '\$0.00'),
                            const Divider(height: 12),
                            _meta('Grand Total', widget.asset.marketValue, bold: true),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ActionSectionCard(
              title: 'Actions',
              child: Column(
                children: [
                  _actionBtn(
                    context,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'View Invoice',
                    loading: _loadingView,
                    onTap: () => _openInvoice(context, openAfterDownload: true),
                  ),
                  const SizedBox(height: 10),
                  _actionBtn(
                    context,
                    icon: Icons.download_outlined,
                    label: 'Download PDF',
                    loading: _loadingDownload,
                    onTap: () => _openInvoice(context, openAfterDownload: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _partyCard(String title, String name, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(details, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _meta(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600))),
        ],
      ),
    );
  }

  Future<void> _openInvoice(BuildContext context, {required bool openAfterDownload}) async {
    final invoiceUrl = widget.asset.certificateUrl;
    if (invoiceUrl == null || invoiceUrl.trim().isEmpty) {
      AppModalAlert.show(
        context,
        title: 'Invoice Not Available',
        message: 'No invoice PDF is linked to this wallet item yet.',
        variant: AppModalAlertVariant.warning,
      );
      return;
    }

    if (openAfterDownload) {
      setState(() => _loadingView = true);
    } else {
      setState(() => _loadingDownload = true);
    }

    try {
      final bytes = await _downloadInvoiceBytes(invoiceUrl);
      final fileName = 'wallet-invoice-${widget.asset.id}-${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        if (openAfterDownload) {
          await OpenFilex.open(filePath);
        }
      }

      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: openAfterDownload ? 'Invoice Opened' : 'Download Complete',
        message: openAfterDownload
            ? 'Invoice PDF was opened successfully.'
            : 'Invoice PDF downloaded successfully.',
        variant: AppModalAlertVariant.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Invoice Error',
        message: 'Unable to load invoice PDF: $e',
        variant: AppModalAlertVariant.warning,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingView = false;
          _loadingDownload = false;
        });
      }
    }
  }

  Future<Uint8List> _downloadInvoiceBytes(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw Exception('Invoice file response is empty.');
    }
    return Uint8List.fromList(data);
  }

  String _fmt(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
