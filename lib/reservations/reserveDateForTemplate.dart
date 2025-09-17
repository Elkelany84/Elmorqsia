import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ReservationForm extends StatefulWidget {
  const ReservationForm({super.key});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _toWhomController =
      TextEditingController(); //الجهة الموجه إليها البيان
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentCodeController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _classStageController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate; // تاريخ الحجز
  String? _selectedInfo;
  String? _selectedPeriod;

  List<String> _infoOptions = []; // قيد - نجاح -رسوب
  List<String> _periodOptions = []; //الفترة الأولى ، الفترة الثانية
  Map<String, String> _periodDetails =
      {}; //من 10 صباحا حتى 11.30 صباحا ،من 12 ظهرا حتى 1.30 ظهرا

  bool _isLoading = false;
  bool _isDateActive = true;
  int _reservationsToday = 0;

  String _mobileMessage = '';
  String _idMessage = '';
  //Validation for Mobile Input
  void _validateMobileInput(String value) {
    if (value.length == 11) {
      setState(() {
        _mobileMessage = ''; // ✅ Hide message when correct
      });
    } else {
      setState(() {
        _mobileMessage = 'برجاء إدخال 11 رقم الخاص بالموبايل';
      });
    }
  }

//Validation for ID Input
  void _validateIDInput(String value) {
    if (value.length == 14) {
      setState(() {
        _idMessage = ''; // ✅ Hide message when correct
      });
    } else {
      setState(() {
        _idMessage = 'رجاء إدخال 14 رقم الخاص بالرقم القومى للطالب';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  //بيان قيد - نجاح - رسوب
  Future<void> _loadDropdownData() async {
    try {
      // Load Info options   قيد - نجاح - رسوب
      final infoDoc =
          await _firestore.collection('settings').doc('infoOptions').get();
      if (infoDoc.exists) {
        setState(() {
          _infoOptions = List<String>.from(infoDoc.data()?['options'] ?? []);
        });
      }
      //   داخل أو خارج الجمهورية
      final infoInOutside =
          await _firestore.collection('settings').doc('insideOutside').get();
      if (infoDoc.exists) {
        setState(() {
          _infoOptions = List<String>.from(infoDoc.data()?['options'] ?? []);
        });
      }
      //   عربى أو إنجليزى
      final infoLanguague =
          await _firestore.collection('settings').doc('infoLanguage').get();
      if (infoDoc.exists) {
        setState(() {
          _infoOptions = List<String>.from(infoDoc.data()?['options'] ?? []);
        });
      }

      // Load Period options
      final periodDoc =
          await _firestore.collection('settings').doc('periodOptions').get();
      if (periodDoc.exists) {
        final data = periodDoc.data();
        setState(() {
          _periodOptions = List<String>.from(data?['options'] ?? []);
          _periodDetails = Map<String, String>.from(data?['details'] ?? {});
        });
      }
    } catch (e) {
      print('Error loading dropdown data: $e');
    }
  }

  // اختيار تاريخ الحجز
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      await _checkDateAvailability(picked);
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _checkDateAvailability(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Format date for query (YYYY-MM-DD)
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Count reservations for the selected date
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        _reservationsToday = querySnapshot.size;
        _isDateActive = _reservationsToday < 3;
      });
    } catch (e) {
      print('Error checking date availability: $e');
      setState(() {
        _isDateActive = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (_selectedDate == null ||
        _selectedInfo == null ||
        _selectedPeriod == null ||
        _toWhomController.text.isEmpty ||
        _studentNameController.text.isEmpty ||
        _studentCodeController.text.isEmpty ||
        _studentIDController.text.isEmpty ||
        _schoolNameController.text.isEmpty ||
        _classStageController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء استكمال كافة البيانات')),
      );
      return;
    }

    if (!_isDateActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'نأسف ، تم اكتمال العدد للحجز فى هذا اليوم ، برجاء اختيار يوم أخر')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      await _firestore.collection('reservations').add({
        'toWhom': _toWhomController.text,
        'studentName': _studentNameController.text,
        'studentCode': _studentCodeController.text,
        'studentID': _studentIDController.text,
        'schoolName': _schoolNameController.text,
        'classStage': _classStageController.text,
        'mobile': _mobileController.text,
        'date': formattedDate,
        'type': _selectedInfo,
        'period': _selectedPeriod,
        'periodDetails': _periodDetails[_selectedPeriod],
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الحجز بنجاح')),
      );

      // Clear form
      _toWhomController.clear();
      _studentNameController.clear();
      _studentCodeController.clear();
      _studentIDController.clear();
      _schoolNameController.clear();
      _classStageController.clear();
      _mobileController.clear();
      _dateController.clear();
      setState(() {
        _selectedDate = null;
        _selectedInfo = null;
        _selectedPeriod = null;
        _isDateActive = true;
        _reservationsToday = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting reservation: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // 'مدرسة المرقسية الثانوية',
          'طلب حجز ميعاد للحصول على بيان',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Tajawal', // Arabic-friendly font
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 10,
        shadowColor: Colors.indigo.shade900,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade800,
                Colors.blue.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.school, size: 30),
        //     onPressed: () {},
        //     tooltip: 'عن المدرسة',
        //   ),
        // ],
        // leading: IconButton(
        //   icon: const Icon(Icons.menu_book_sharp),
        //   onPressed: () {},
        //   tooltip: 'القائمة',
        // ),
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(20),
        //   child: Container(
        //     height: 20,
        //     decoration: BoxDecoration(
        //       color: Colors.white.withOpacity(0.15),
        //       borderRadius: const BorderRadius.vertical(
        //         bottom: Radius.circular(25),
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text Field الجهة الموجه إليها البيان
              TextField(
                controller: _toWhomController,
                decoration: const InputDecoration(
                  labelText: 'اسم الجهة المُوجه إليها الطلب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // اسم الطالب
              TextField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'رجاء إدخال اسم الطالب رباعى',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // كود الطالب
              TextField(
                controller: _studentCodeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // allow only numbers// max 14 characters
                ],
                decoration: const InputDecoration(
                  labelText: 'كود الطالب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // الرقم القومى الطالب
              TextField(
                controller: _studentIDController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // allow only numbers
                  LengthLimitingTextInputFormatter(14), // max 14 characters
                ],
                onChanged: _validateIDInput,
                decoration: const InputDecoration(
                  labelText: 'رجاء إدخال 14 رقم الخاص بالرقم القومى للطالب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _idMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 8),
              // اسم المدرسة
              TextField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'مثال : مدرسة الحكمة الإعدادية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // السنة الدراسية - الصف الدراسى
              TextField(
                controller: _classStageController,
                decoration: const InputDecoration(
                  labelText: 'مثال: الصف الثالث الإبتدائى أو العام 2024-2025',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // رقم الموبايل
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // allow only numbers
                  LengthLimitingTextInputFormatter(11), // max 14 characters
                ],
                onChanged: _validateMobileInput,
                decoration: const InputDecoration(
                  labelText: 'برجاء إدخال 11 رقم الخاص بالموبايل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _mobileMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 8),
              // Info Dropdown نوع البيان المطلوب
              DropdownButtonFormField<String>(
                value: _selectedInfo,
                decoration: const InputDecoration(
                  labelText: 'اختر البيان المطلوب',
                  border: OutlineInputBorder(),
                ),
                items: _infoOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedInfo = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Date Picker
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'اختر اليوم للحجز',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              if (_selectedDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'عدد الحجوزات الكلى: $_reservationsToday/3',
                  style: TextStyle(
                    color: _isDateActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isDateActive) ...[
                  const SizedBox(height: 8),
                  Text(
                    'نأسف ، تم اكتمال العدد للحجز فى هذا اليوم ، برجاء اختيار يوم أخر',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),

              // Period Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'الفترة',
                  border: OutlineInputBorder(),
                ),
                items: _periodOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      '$value (${_periodDetails[value] ?? ''})',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              // ElevatedButton(
              //   onPressed: () {
              //     // Navigator.push(
              //     //     context,
              //     //     MaterialPageRoute(
              //     //         builder: (context) => SchoolContactsPage()));
              //     // Navigator.push(
              //     //     context,
              //     //     MaterialPageRoute(
              //     //         builder: (context) => ReservationForm()));
              //     _isLoading ? null : _submitReservation;
              //   },
              //   style: ElevatedButton.styleFrom(
              //     // padding:
              //     //     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              //     foregroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     elevation: 0,
              //     shadowColor: const Color(0xFF1565C0), // Blue 800
              //   ).copyWith(
              //     overlayColor: MaterialStateProperty.all(
              //         const Color(0x22000000)), // Ripple effect
              //   ),
              //   child: Ink(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       gradient: const LinearGradient(
              //         colors: [
              //           Color(0xFF2196F3), // Blue 500
              //           Color(0xFF0D47A1), // Blue 900
              //         ],
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         stops: [0.0, 0.8],
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: const Color(0xFF0D47A1).withOpacity(0.4),
              //           blurRadius: 10,
              //           spreadRadius: 2,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: Container(
              //       // constraints:
              //       //     const BoxConstraints(minWidth: 88.0, minHeight: 48.0),
              //       alignment: Alignment.center,
              //       child: const Text(
              //         // 'تواصل مع المدرسة'
              //         'اضغط لحجز ميعاد',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 24,
              //           fontFamily: 'Tajawal',
              //           shadows: [
              //             Shadow(
              //               color: Colors.black26,
              //               blurRadius: 2,
              //               offset: Offset(1, 1),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isDateActive ? null : Colors.grey,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('اضغط لحجز ميعاد'),
              ),

              const SizedBox(height: 24),

              // Show Data as ListView Button
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => ReservationsList()));
              //   },
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     backgroundColor: _isDateActive ? null : Colors.grey,
              //   ),
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('عرض الداتا للمدير'),
              // ),

              const SizedBox(height: 24),

              // Show Data as Pdf Button
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => ReservationReport()));
              //   },
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     backgroundColor: _isDateActive ? null : Colors.grey,
              //   ),
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('عرض الداتا للموظف'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toWhomController.dispose();
    _studentNameController.dispose();
    _studentCodeController.dispose();
    _studentIDController.dispose();
    _schoolNameController.dispose();
    _classStageController.dispose();
    _mobileController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
