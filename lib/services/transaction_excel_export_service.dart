import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/transaction_model.dart';

class TransactionExcelExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<Uint8List> buildExcelBytes({
    required List<TransactionModel> transactions,
    required String selectedPeriod,
    required String selectedType,
    required String selectedStatus,
    required String selectedSeller,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    sheet
      ..cell(CellIndex.indexByString('A1')).value = TextCellValue('Seller Filter')
      ..cell(CellIndex.indexByString('B1')).value = TextCellValue(selectedSeller)
      ..cell(CellIndex.indexByString('A2')).value = TextCellValue('Period Filter')
      ..cell(CellIndex.indexByString('B2')).value = TextCellValue(selectedPeriod)
      ..cell(CellIndex.indexByString('A3')).value = TextCellValue('Type Filter')
      ..cell(CellIndex.indexByString('B3')).value = TextCellValue(selectedType)
      ..cell(CellIndex.indexByString('A4')).value = TextCellValue('Status Filter')
      ..cell(CellIndex.indexByString('B4')).value = TextCellValue(selectedStatus)
      ..cell(CellIndex.indexByString('A6')).value = TextCellValue('Transaction ID')
      ..cell(CellIndex.indexByString('B6')).value = TextCellValue('Title')
      ..cell(CellIndex.indexByString('C6')).value = TextCellValue('Type')
      ..cell(CellIndex.indexByString('D6')).value = TextCellValue('Status')
      ..cell(CellIndex.indexByString('E6')).value = TextCellValue('Date')
      ..cell(CellIndex.indexByString('F6')).value = TextCellValue('Primary Amount')
      ..cell(CellIndex.indexByString('G6')).value = TextCellValue('Secondary Amount')
      ..cell(CellIndex.indexByString('H6')).value = TextCellValue('Seller');

    for (var i = 0; i < transactions.length; i++) {
      final row = i + 7;
      final transaction = transactions[i];
      sheet
        ..cell(CellIndex.indexByString('A$row')).value = TextCellValue(transaction.id)
        ..cell(CellIndex.indexByString('B$row')).value = TextCellValue(transaction.title)
        ..cell(CellIndex.indexByString('C$row')).value = TextCellValue(transaction.type)
        ..cell(CellIndex.indexByString('D$row')).value = TextCellValue(transaction.status)
        ..cell(CellIndex.indexByString('E$row')).value = TextCellValue(_dateFormat.format(transaction.date))
        ..cell(CellIndex.indexByString('F$row')).value = TextCellValue(transaction.amount)
        ..cell(CellIndex.indexByString('G$row')).value = TextCellValue(transaction.secondaryAmount ?? '-')
        ..cell(CellIndex.indexByString('H$row')).value = TextCellValue(transaction.sellerName);
    }

    final rawBytes = excel.encode();
    if (rawBytes == null) {
      throw Exception('Failed to encode Excel file.');
    }
    return Uint8List.fromList(rawBytes);
  }

  Future<void> downloadExcel({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }
}
