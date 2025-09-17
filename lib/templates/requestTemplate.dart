import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TemplateForm extends StatefulWidget {
  @override
  _TemplateFormState createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final TextEditingController _field3Controller = TextEditingController();

  String? _dropdownValue1;
  String? _dropdownValue2;
  String? _dropdownValue3;

  final List<String> _dropdownOptions1 = ['Option 1', 'Option 2', 'Option 3'];
  final List<String> _dropdownOptions2 = ['Type A', 'Type B', 'Type C'];
  final List<String> _dropdownOptions3 = [
    'Category X',
    'Category Y',
    'Category Z'
  ];
  // Custom positioning values for PDF elements
  double titleX = 300; //Horizontal
  double titleY = 120; //Vertical
  double categoryX = 50;
  double categoryY = 100;
  double descriptionX = 50;
  double descriptionY = 150;
  double priorityX = 300;
  double priorityY = 100;
  double notesX = 50;
  double notesY = 250;
  double statusX = 300;
  double statusY = 150;
  double dateX = 50;
  double dateY = 500;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Text Field 1
                _buildTextField(
                  controller: _field1Controller,
                  label: 'Field 1',
                  hint: 'Enter text for field 1',
                ),
                SizedBox(height: 20),

                // Dropdown 1
                _buildDropdown(
                  value: _dropdownValue1,
                  options: _dropdownOptions1,
                  hint: 'Select Option 1',
                  onChanged: (value) {
                    setState(() {
                      _dropdownValue1 = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Text Field 2
                _buildTextField(
                  controller: _field2Controller,
                  label: 'Field 2',
                  hint: 'Enter text for field 2',
                ),
                SizedBox(height: 20),

                // Dropdown 2
                _buildDropdown(
                  value: _dropdownValue2,
                  options: _dropdownOptions2,
                  hint: 'Select Option 2',
                  onChanged: (value) {
                    setState(() {
                      _dropdownValue2 = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Text Field 3
                _buildTextField(
                  controller: _field3Controller,
                  label: 'Field 3',
                  hint: 'Enter text for field 3',
                ),
                SizedBox(height: 20),

                // Dropdown 3
                _buildDropdown(
                  value: _dropdownValue3,
                  options: _dropdownOptions3,
                  hint: 'Select Option 3',
                  onChanged: (value) {
                    setState(() {
                      _dropdownValue3 = value;
                    });
                  },
                ),
                SizedBox(height: 30),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> options,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: hint,
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an option';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        'Submit',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save to Firestore
        await _firestore.collection('templates').add({
          'field1': _field1Controller.text,
          'field2': _field2Controller.text,
          'field3': _field3Controller.text,
          'dropdown1': _dropdownValue1,
          'dropdown2': _dropdownValue2,
          'dropdown3': _dropdownValue3,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Generate PDF
        final pdfFile = await _generatePDF();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data saved successfully! PDF generated.'),
            backgroundColor: Colors.green,
          ),
        );

        // Show PDF preview
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfFile,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();
    //
    //   // Load background image
    // final backgroundImage = await _loadBackgroundImage();
    // final image = pw.MemoryImage(
    //   File('/assets/images/ground.jpg').readAsBytesSync(),
    // );
    // final netImage = await networkImage('https://www.nfet.net/nfet.jpg');
    final netImage1 =
        await networkImage('https://i.postimg.cc/qBcZyRdx/ground.png');
    // final networkImage = pw.MemoryImage(
    //   File('https://images.unsplash.com/photo-1754045502217-f4622c7d8d99?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D')
    //       .readAsBytesSync(),
    // );
    //
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // pw.Container(
              //   //add red color
              //   color: PdfColors.red,
              // ),
              // pw.Center(child: pw.Image(netImage, fit: pw.BoxFit.cover)),
              // Background image
              // if (backgroundImage != null)
              pw.Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: pw.Image(netImage1, fit: pw.BoxFit.cover)
                  // child: pw.Image(
                  //   pw.MemoryImage(backgroundImage),
                  //   fit: pw.BoxFit.cover,
                  // ),
                  ),
              //
              //             // Content
              pw.Container(
                padding: pw.EdgeInsets.all(40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // pw.Text(
                    //   'Template Data',
                    //   style: pw.TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: pw.FontWeight.bold,
                    //     color: PdfColors.blue,
                    //   ),
                    // ),
                    // Positioned elements - each can be customized individually

                    pw.SizedBox(height: 30),
                    // _buildPDFRow('Field 1:', _field1Controller.text),
                    // _buildPDFRow('Field 2:', _field2Controller.text),
                    // _buildPDFRow('Field 3:', _field3Controller.text),
                    // _buildPDFRow('Dropdown 1:', _dropdownValue1 ?? ''),
                    // _buildPDFRow('Dropdown 2:', _dropdownValue2 ?? ''),
                    // _buildPDFRow('Dropdown 3:', _dropdownValue3 ?? ''),
                    pw.SizedBox(height: 20),
                    // pw.Text(
                    //   'Generated on: ${DateTime.now().toString()}',
                    //   style: pw.TextStyle(
                    //     fontSize: 10,
                    //     color: PdfColors.grey,
                    //   ),
                    // ),
                  ],
                ),
              ),
              pw.Positioned(
                left: titleX,
                top: titleY,
                child: pw.Text(
                  'Title: ${_field1Controller.text}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Future<Uint8List?> _loadBackgroundImage() async {
  //   try {
  //     final ByteData data = await rootBundle.load('/assets/images/ground.jpg');
  //     return data.buffer.asUint8List();
  //   } catch (e) {
  //     print('Error loading background image: $e');
  //     return null;
  //   }
  // }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    super.dispose();
  }
}
