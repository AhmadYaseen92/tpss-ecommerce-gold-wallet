import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

class GenerateTaxInvoicePage extends StatefulWidget {
  final WalletTransactionEntity asset;

  const GenerateTaxInvoicePage({
    super.key,
    required this.asset,
  });

  @override
  State<GenerateTaxInvoicePage> createState() => _GenerateTaxInvoicePageState();
}

class _GenerateTaxInvoicePageState extends State<GenerateTaxInvoicePage> {
  bool _downloading = false;
  WalletActionPreviewResult? _preview;

  String get _reference =>
      'INV-${widget.asset.name.replaceAll(' ', '').toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  Widget build(BuildContext context) {
    final issueDate = DateTime.now();
    final actionType = _resolveActionType();
    final (leftLabel, rightLabel) = _partyLabels(actionType);

    final baseAmount = widget.asset.actionBaseAmount;
    final subTotal = _preview?.subTotalAmount ?? baseAmount;
    final fees = _preview?.totalFeesAmount ?? 0;
    const vat = 0.0;
    final discount = _preview?.discountAmount ?? 0;
    final grandTotal = _preview?.finalAmount ?? (subTotal + fees + vat - discount);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Tax Invoice',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.appPalette.primary,
          ),
        ),
      ),

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
                      'TAX INVOICE',
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
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                        ),
                        child: widget.asset.imageUrl.trim().isEmpty
                            ? const Icon(Icons.image_not_supported_outlined)
                            : Image.network(
                                widget.asset.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported_outlined),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.asset.name.isEmpty
                                  ? 'Unnamed Product'
                                  : widget.asset.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ref: $_reference',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          'Type: $actionType',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),

                  const Divider(height: 20),

                  _metaRow('Tax Invoice #', _reference, selectable: true),
                  _metaRow('Action Type', actionType),
                  _metaRow('Issue Date', _fmt(issueDate)),
                  _metaRow('Status', widget.asset.status),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _partyCard(
                          label: leftLabel,
                          name: _leftPartyName(actionType),
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

                  const SizedBox(height: 10),

                  _buildTable(),

                  const SizedBox(height: 10),

                  _buildBox(
                    title: 'Item Details',
                    children: [
                      _metaRow('Product SKU', widget.asset.productSku?.trim().isNotEmpty == true ? widget.asset.productSku! : 'N/A'),
                      _metaRow('Wallet Item Id', '${widget.asset.id}'),
                      _metaRow('Product Name', widget.asset.name),
                      _metaRow('Category / Material',
                          widget.asset.category.name.toUpperCase()),
                      _metaRow('Weight',
                          '${widget.asset.weightInGrams.toStringAsFixed(3)} g'),
                      _metaRow('Purity / Karat', widget.asset.purity),
                      _metaRow('Quantity', '${widget.asset.quantity}'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildBox(
                    title: 'Amount Summary',
                    children: [
                      ...?_preview?.feeBreakdowns.map(
                        (line) => _metaRow(
                          _displayFeeLabel(line.feeName, isDiscount: line.isDiscount),
                          '${line.isDiscount ? '-' : ''}${_currency(line.appliedValue)}',
                        ),
                      ),
                      if ((_preview?.feeBreakdowns.length ?? 0) > 0) const Divider(),
                      _metaRow('Sub Total', _currency(subTotal)),
                      _metaRow('Fees', _currency(fees)),
                      _metaRow('VAT / Tax', _currency(vat)),
                      if (!(_preview?.feeBreakdowns.any((line) => line.isDiscount) ?? false))
                        _metaRow('Discount', _currency(discount)),
                      const Divider(),
                      _metaRow('Grand Total', _currency(grandTotal),
                          bold: true),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildBox(
                    title: '',
                    children: const [
                      Text(
                        'This document serves as ownership and transaction proof.\nElectronically generated document.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
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
                  onPressed:
                      _downloading ? null : () => _downloadInvoice(context),
                  icon: _downloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
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

  Future<void> _loadPreview() async {
    try {
      final amount = widget.asset.actionBaseAmount;
      final unitPrice = widget.asset.actionUnitPrice;
      final quantity = widget.asset.quantity <= 0 ? 1 : widget.asset.quantity;
      final response = await InjectionContainer.dio().post(
        '/wallet/actions/preview',
        data: {
          'userId': AuthSessionStore.userId,
          'walletAssetId': widget.asset.id,
          'actionType': _resolveActionType().toLowerCase(),
          'quantity': quantity,
          'unitPrice': unitPrice,
          'weight': widget.asset.weightInGrams,
          'amount': amount,
        },
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((line) => WalletActionPreviewFeeLine(
                feeName: (line['feeName'] ?? '').toString(),
                appliedValue: (line['appliedValue'] as num?)?.toDouble() ?? 0,
                isDiscount: (line['isDiscount'] as bool?) ?? false,
              ))
          .toList();

      if (!mounted) return;
      setState(() {
        _preview = WalletActionPreviewResult(
          subTotalAmount: (data['subTotalAmount'] as num?)?.toDouble() ?? amount,
          totalFeesAmount: (data['totalFeesAmount'] as num?)?.toDouble() ?? 0,
          discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0,
          finalAmount: (data['finalAmount'] as num?)?.toDouble() ?? amount,
          currency: (data['currency'] ?? 'USD').toString(),
          feeBreakdowns: feeBreakdowns,
        );
      });
    } catch (_) {}
  }

  // ---------- UI HELPERS ----------

  Widget _buildTable() {
    return Table(
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
            Padding(padding: EdgeInsets.all(6), child: Text('#')),
            Padding(padding: EdgeInsets.all(6), child: Text('Item')),
            Padding(padding: EdgeInsets.all(6), child: Text('Price')),
            Padding(padding: EdgeInsets.all(6), child: Text('Qty')),
            Padding(padding: EdgeInsets.all(6), child: Text('Total')),
          ],
        ),
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(6), child: Text('1')),
          Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                widget.asset.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
          Padding(
              padding: const EdgeInsets.all(6),
              child: Text(_currency(widget.asset.actionUnitPrice))),
          Padding(
              padding: const EdgeInsets.all(6),
              child: Text('${widget.asset.quantity}')),
          Padding(
              padding: const EdgeInsets.all(6),
              child: Text(_currency(widget.asset.actionBaseAmount))),
        ]),
      ],
    );
  }

  Widget _buildBox({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _partyCard({
    required String label,
    required String name,
    required String role,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(role, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value,
      {bool bold = false, bool selectable = false}) {
    final valueWidget = selectable
        ? SelectableText(value,
            style:
                TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600))
        : Text(value,
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text('$label:')),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  // ---------- LOGIC (UNCHANGED) ----------

  String _resolveActionType() {
    final status = widget.asset.status.toLowerCase();
    if (status.contains('sell')) return 'Sold';
    if (status.contains('gift')) return 'Gift';
    if (status.contains('transfer')) return 'Transfer';
    return 'Bought';
  }

  (String, String) _partyLabels(String type) {
    return switch (type) {
      'Sold' => ('Investor Seller', 'Receiving Seller'),
      'Gift' => ('Sender', 'Recipient'),
      'Transfer' => ('From', 'To'),
      _ => ('Seller', 'Buyer'),
    };
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _currency(double v) => '\$${v.toStringAsFixed(2)}';

  String _leftPartyName(String type) =>
      widget.asset.sellerName.isEmpty ? 'N/A' : widget.asset.sellerName;

  String _displayFeeLabel(String feeName, {required bool isDiscount}) {
    if (!isDiscount) return feeName;
    if (feeName.toLowerCase().contains('premium')) return 'Premium';
    return 'Discount';
  }

  // ---------- DOWNLOAD (UNCHANGED LOGIC IDEA) ----------

  Future<void> _downloadInvoice(BuildContext context) async {
    setState(() => _downloading = true);
    try {
      final url = await _resolveDownloadUrl();
      if (url == null) throw Exception('No certificate URL');

      final bytes = await _downloadBytes(url);

      final fileName =
          'invoice-${widget.asset.id}-${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$fileName';
        await File(path).writeAsBytes(bytes);
        await OpenFilex.open(path);
      }

      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Success',
        message: 'Downloaded successfully',
        variant: AppModalAlertVariant.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Error',
        message: e.toString(),
        variant: AppModalAlertVariant.warning,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final res = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data ?? []);
  }

  Future<String?> _resolveDownloadUrl() async {
    try {
      final response = await InjectionContainer.dio().get(
        '/wallet/wallet-items/${widget.asset.id}/certificate',
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final ensuredUrl = (data['pdfUrl'] ?? '').toString();
      if (ensuredUrl.isNotEmpty) return ensuredUrl;
    } catch (_) {}

    final fallback = widget.asset.certificateUrl;
    if (fallback == null || fallback.isEmpty) return null;
    return fallback;
  }
}
