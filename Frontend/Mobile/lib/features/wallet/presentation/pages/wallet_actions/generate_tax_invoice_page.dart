import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class GenerateTaxInvoicePage extends StatefulWidget {
  final WalletTransactionEntity asset;
  const GenerateTaxInvoicePage({super.key, required this.asset});

  @override
  State<GenerateTaxInvoicePage> createState() => _GenerateTaxInvoicePageState();
}

class _GenerateTaxInvoicePageState extends State<GenerateTaxInvoicePage> {
  bool _downloading = false;

  String get _reference =>
      'INV-${widget.asset.name.replaceAll(' ', '').toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final issueDate = DateTime.now();
    final actionType = _resolveActionType();
    final (leftLabel, rightLabel) = _partyLabels(actionType);
    final subTotal = _safeAmount(widget.asset.marketValue);
    const fees = 0.0;
    const vat = 0.0;
    const discount = 0.0;
    final grandTotal = subTotal + fees + vat - discount;

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Invoice'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ActionSectionCard(
              title: '',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'CERTIFICATE INVOICE',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                        child: widget.asset.imageUrl.trim().isEmpty
                            ? const Icon(Icons.image_not_supported_outlined)
                            : Image.network(
                                widget.asset.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.asset.name.trim().isEmpty ? 'Unnamed Product' : widget.asset.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Type: $actionType', style: const TextStyle(fontSize: 12)),
                          Text('Ref: $_reference', style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 20),
                  _metaRow('Certificate / Invoice #', _reference, selectable: true),
                  _metaRow('Action Type', actionType),
                  _metaRow('Issue Date', _fmt(issueDate)),
                  _metaRow('Status', widget.asset.status),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _partyCard(
                          label: leftLabel,
                          name: widget.asset.sellerName.isEmpty ? 'N/A' : widget.asset.sellerName,
                          role: 'Linked wallet party',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _partyCard(
                          label: rightLabel,
                          name: 'Wallet User',
                          role: 'Linked wallet owner',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black26),
                    columnWidths: const {
                      0: FixedColumnWidth(30),
                      1: FlexColumnWidth(2.4),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1.4),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                        children: [
                          Padding(padding: EdgeInsets.all(6), child: Text('#', style: TextStyle(fontWeight: FontWeight.w700))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Item Description', style: TextStyle(fontWeight: FontWeight.w700))),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Item Details', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _metaRow('Wallet Item Id', '${widget.asset.id}'),
                        _metaRow('Product Name', widget.asset.name),
                        _metaRow('Category / Material', widget.asset.category.name.toUpperCase()),
                        _metaRow('Weight', '${widget.asset.weightInGrams.toStringAsFixed(3)} g'),
                        _metaRow('Purity / Karat', widget.asset.purity),
                        _metaRow('Quantity', '${widget.asset.quantity}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount Summary', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _metaRow('Sub Total', _currency(subTotal)),
                        _metaRow('Fees', _currency(fees)),
                        _metaRow('VAT / Tax', _currency(vat)),
                        _metaRow('Discount', _currency(discount)),
                        const Divider(height: 12),
                        _metaRow('Grand Total', _currency(grandTotal), bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: const Text(
                      'This document serves as ownership and transaction proof for the linked wallet item.\nElectronically generated document.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ActionSectionCard(
              title: 'Actions',
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _downloading ? null : () => _downloadInvoice(context),
                  icon: _downloading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined),
                  label: const Text('Download PDF'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partyCard({required String label, required String name, required String role}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(role, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, {bool bold = false, bool selectable = false}) {
    final valueWidget = selectable
        ? SelectableText(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600))
        : Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 132, child: Text('$label: ', style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    setState(() => _downloading = true);
    try {
      final existingUrl = widget.asset.certificateUrl;
      final ensuredUrl = await _ensureCertificateUrlFromBackend(fallbackUrl: existingUrl);
      if (ensuredUrl == null || ensuredUrl.trim().isEmpty) {
        throw Exception('No linked invoice/certificate record exists for this wallet item.');
      }

      final bytes = await _downloadInvoiceBytes(ensuredUrl);

      final fileName = 'certificate-invoice-${widget.asset.id}-${DateTime.now().millisecondsSinceEpoch}.pdf';
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
        await File(filePath).writeAsBytes(bytes, flush: true);
        await OpenFilex.open(filePath);
      }

      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Download Complete',
        message: 'Certificate invoice PDF downloaded successfully.',
        variant: AppModalAlertVariant.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Download Failed',
        message: e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e',
        variant: AppModalAlertVariant.warning,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<String?> _ensureCertificateUrlFromBackend({String? fallbackUrl}) async {
    try {
      final response = await InjectionContainer.dio().get('/wallet/wallet-items/${widget.asset.id}/certificate');
      final payload = response.data as Map<String, dynamic>?;
      final data = payload?['data'];
      if (data is! Map<String, dynamic>) return _resolveDownloadUrl(fallbackUrl);
      final url = (data['pdfUrl'] ?? '').toString().trim();
      if (url.isNotEmpty) return _resolveDownloadUrl(url);
      return _resolveDownloadUrl(fallbackUrl);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        if ((fallbackUrl ?? '').trim().isEmpty) {
          throw Exception('No linked invoice/certificate record exists for this wallet item.');
        }
        return _resolveDownloadUrl(fallbackUrl);
      }
      throw Exception('Unable to generate certificate PDF from invoice data.');
    } catch (_) {
      if ((fallbackUrl ?? '').trim().isNotEmpty) {
        return _resolveDownloadUrl(fallbackUrl);
      }
      throw Exception('Unable to generate certificate PDF from invoice data.');
    }
  }

  Future<Uint8List> _downloadInvoiceBytes(String url) async {
    final resolvedUrl = _resolveDownloadUrl(url);
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      throw Exception('Unable to resolve certificate PDF URL.');
    }

    try {
      final response = await Dio().get<List<int>>(resolvedUrl, options: Options(responseType: ResponseType.bytes));
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Certificate invoice PDF is empty.');
      }
      return Uint8List.fromList(data);
    } on DioException {
      final refreshedUrl = await _ensureCertificateUrlFromBackend();
      if (refreshedUrl == null || refreshedUrl.isEmpty) {
        throw Exception('Unable to generate certificate PDF from invoice data.');
      }
      final retried = await Dio().get<List<int>>(refreshedUrl, options: Options(responseType: ResponseType.bytes));
      final data = retried.data;
      if (data == null || data.isEmpty) {
        throw Exception('Certificate invoice PDF is empty.');
      }
      return Uint8List.fromList(data);
    }
  }

  String _resolveActionType() {
    final status = widget.asset.status.toLowerCase();
    if (status.contains('sell')) return 'Sold';
    if (status.contains('gift')) return 'Gift';
    if (status.contains('transfer')) return 'Transfer';
    if (status.contains('pickup') || status.contains('delivered')) return 'Pickup';
    return 'Bought';
  }

  (String, String) _partyLabels(String actionType) {
    return switch (actionType) {
      'Sold' => ('Investor Seller', 'Receiving Seller'),
      'Gift' => ('Sender', 'Recipient'),
      'Transfer' => ('From Investor', 'To Investor'),
      'Pickup' => ('Owner', 'Pickup Provider'),
      _ => ('Seller', 'Investor'),
    };
  }

  String _fmt(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  double _safeAmount(String? rawValue) {
    final normalized = (rawValue ?? '').replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _currency(double? value) {
    final amount = value ?? 0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String? _resolveDownloadUrl(String? source) {
    final trimmed = (source ?? '').trim();
    if (trimmed.isEmpty) return null;
    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return trimmed;

    final baseUrl = InjectionContainer.dio().options.baseUrl;
    if (baseUrl.trim().isEmpty) return trimmed;
    return Uri.parse(baseUrl).resolve(trimmed).toString();
  }
}
