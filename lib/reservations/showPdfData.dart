import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReservationReport extends StatefulWidget {
  const ReservationReport({super.key});

  @override
  State<ReservationReport> createState() => _ReservationReportState();
}

class _ReservationReportState extends State<ReservationReport> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _reservations = [];
  Set<String> _availableDates = {};
  String? _selectedDate;
  bool _isLoading = false;
  bool _isGeneratingPdf = false;

  // Arabic font
  late pw.Font _arabicFont;

  @override
  void initState() {
    super.initState();
    _loadAvailableDates();
    _loadArabicFont();
  }

  Future<void> _loadArabicFont() async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    _arabicFont = pw.Font.ttf(fontData);
  }

  Future<void> _loadAvailableDates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .orderBy('date', descending: true)
          .get();

      final dates = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          dates.add(data['date']);
        }
      }

      setState(() {
        _availableDates = dates;
        _reservations = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservationsForDate(String date) async {
    setState(() {
      _isLoading = true;
      _selectedDate = date;
    });

    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('date', isEqualTo: date)
          .orderBy('createdAt')
          .get();

      setState(() {
        _reservations = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reservations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndPrintPdf() async {
    if (_selectedDate == null || _reservations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date with reservations')),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = await _createPdf();
      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<pw.Document> _createPdf() async {
    final pdf = pw.Document();

    // Arabic text style
    final arabicTextStyle = pw.TextStyle(
      font: _arabicFont,
      fontSize: 10,
    );

    final arabicHeaderStyle = pw.TextStyle(
      font: _arabicFont,
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
      color: PdfColors.white,
    );

    final arabicTitleStyle = pw.TextStyle(
      font: _arabicFont,
      fontWeight: pw.FontWeight.bold,
      fontSize: 18,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl, // RTL for Arabic
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Report Header - Arabic
                pw.Center(
                  child: pw.Text(
                    'تقرير الحجوزات',
                    style: arabicTitleStyle,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'التاريخ: $_selectedDate',
                    style: pw.TextStyle(
                      font: _arabicFont,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'تم الإنشاء: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 15),

                // Summary - Arabic
                pw.Row(
                  children: [
                    pw.Text(
                      'إجمالي الحجوزات: ${_reservations.length}',
                      style: pw.TextStyle(
                        font: _arabicFont,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Table with Arabic headers
                pw.Table(
                  border:
                      pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration:
                          pw.BoxDecoration(color: PdfColors.blue.shade(700)),
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        _buildArabicHeaderCell('م', arabicHeaderStyle), // No.
                        _buildArabicHeaderCell(
                            'نص الحجز', arabicHeaderStyle), // Reservation Text
                        _buildArabicHeaderCell(
                            'الحالة', arabicHeaderStyle), // Info
                        _buildArabicHeaderCell(
                            'الفترة', arabicHeaderStyle), // Period
                        _buildArabicHeaderCell(
                            'الوقت', arabicHeaderStyle), // Time Slot
                        _buildArabicHeaderCell(
                            'وقت الإنشاء', arabicHeaderStyle), // Created At
                      ],
                    ),
                    // Data Rows
                    ..._getTableRows(arabicTextStyle),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  pw.Padding _buildArabicHeaderCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: style,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Padding _buildArabicDataCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: style,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  List<pw.TableRow> _getTableRows(pw.TextStyle textStyle) {
    final rows = <pw.TableRow>[];

    for (int i = 0; i < _reservations.length; i++) {
      final doc = _reservations[i];
      final reservation = doc.data() as Map<String, dynamic>;

      final createdAt = reservation['createdAt'] != null
          ? DateFormat('HH:mm')
              .format((reservation['createdAt'] as Timestamp).toDate())
          : 'N/A';

      // Translate values to Arabic if needed
      final info = _translateToArabic(reservation['info']?.toString() ?? 'N/A');
      final period =
          _translateToArabic(reservation['period']?.toString() ?? 'N/A');

      rows.add(
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            _buildArabicDataCell('${i + 1}', textStyle),
            _buildArabicDataCell(
                reservation['الجهة']?.toString() ?? 'N/A', textStyle),
            _buildArabicDataCell(info, textStyle),
            _buildArabicDataCell(period, textStyle),
            _buildArabicDataCell(
                reservation['periodDetails']?.toString() ?? 'N/A', textStyle),
            _buildArabicDataCell(createdAt, textStyle),
          ],
        ),
      );
    }

    return rows;
  }

  String _translateToArabic(String value) {
    // Simple translation mapping - extend this as needed
    const translations = {
      'success': 'نجاح',
      'failure': 'فشل',
      'stayed': 'مقيم',
      'first period': 'الفترة الأولى',
      'second period': 'الفترة الثانية',
      'N/A': 'غير متوفر',
    };

    return translations[value.toLowerCase()] ?? value;
  }

  Widget _buildDateChip(String date) {
    return ChoiceChip(
      label: Text(date),
      selected: _selectedDate == date,
      onSelected: (selected) {
        if (selected) {
          _loadReservationsForDate(date);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيان بالحجوزات',
            style: TextStyle(fontFamily: 'Arabic')),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Selection - Arabic
            const Text(
              'اختر التاريخ:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Tajawal', // Arabic-friendly font
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),

            if (_isLoading && _availableDates.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_availableDates.isEmpty)
              const Center(
                  child: Text('لا توجد حجوزات متاحة',
                      style: TextStyle(fontFamily: 'Arabic'))),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableDates.map(_buildDateChip).toList(),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Selected Date Info - Arabic
            if (_selectedDate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التاريخ المحدد: $_selectedDate',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Arabic'),
                  ),
                  Text(
                    'الحجوزات: ${_reservations.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontFamily: 'Arabic',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],

            // Reservations List Preview
            if (_selectedDate != null && !_isLoading) ...[
              Expanded(
                child: _reservations.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد حجوزات للتاريخ المحدد',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Arabic'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _reservations.length,
                        itemBuilder: (context, index) {
                          final doc = _reservations[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[700],
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                // data['toWhom'] ?? 'لا يوجد نص',
                                'الجهة الموجه إليها الطلب: ${data['toWhom']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arabic'),
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'النوع: ${_translateToArabic(data['type'] ?? '')}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontFamily: 'Arabic')),
                                  Text(
                                      'الفترة: ${_translateToArabic(data['period'] ?? '')}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontFamily: 'Arabic')),
                                  if (data['periodDetails'] != null)
                                    Text('الوقت: ${data['periodDetails']}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontFamily: 'Arabic')),
                                ],
                              ),
                              trailing: Text(
                                data['createdAt'] != null
                                    ? DateFormat('HH:mm').format(
                                        (data['createdAt'] as Timestamp)
                                            .toDate())
                                    : '',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ] else if (_selectedDate == null) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'يرجى اختيار تاريخ لعرض الحجوزات',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Arabic'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Print Button - Arabic
            if (_selectedDate != null && _reservations.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _generateAndPrintPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.print),
                label: Text(
                  _isGeneratingPdf ? 'جاري إنشاء PDF...' : 'طباعة التقرير',
                  style: const TextStyle(fontFamily: 'Arabic'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
