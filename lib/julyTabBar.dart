import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elmorqsiaschool/model/PeriodData.dart';
import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس'
  ];
  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _classNames = [];
  String? _selectedClass;
  List<List<PeriodData>> _timetableData =
      List.generate(5, (_) => List.filled(7, PeriodData.empty()));
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Get current weekday (Sunday=0 to Saturday=6)
    final today = DateTime.now().weekday % 7; // Ensures Sunday=0
    // Convert to our tab index (Sunday=0 to Thursday=4)
    final initialIndex =
        today < 5 ? today : 0; // If Friday/Saturday, default to Sunday
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _fetchClassNames();
  }

  Future<void> _fetchClassNames() async {
    try {
      final snapshot = await _firestore.collection('classes').get();
      setState(() {
        _classNames =
            snapshot.docs.map((doc) => doc['className'] as String).toList();
        _isLoading = false;
      });

      if (_classNames.isNotEmpty) {
        _loadTimetable(_classNames.first);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load classes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimetable(String className) async {
    setState(() {
      _selectedClass = className;
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('timetables')
          .where('className', isEqualTo: className)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _timetableData =
              List.generate(5, (_) => List.filled(7, PeriodData.empty()));

          for (int day = 0; day < _days.length; day++) {
            for (int period = 0; period < 7; period++) {
              final prefix = '${_days[day]}_P${period + 1}_';
              _timetableData[day][period] = PeriodData(
                subject: data['${prefix}subject'] ?? 'حصة فاضية',
                teacher: data['${prefix}teacher'] ?? '',
                room: data['${prefix}room'] ?? '',
              );
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No timetable found for $className';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load timetable: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول الحصص'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'اختر الفصل الدراسى',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _classNames.map((className) {
                    return DropdownMenuItem<String>(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      value != null ? _loadTimetable(value) : null,
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabDays.map((day) => Tab(text: day)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : TabBarView(
                  controller: _tabController,
                  children: List.generate(5, (dayIndex) {
                    return ListView.builder(
                      itemCount: 7,
                      itemBuilder: (context, periodIndex) {
                        final period = _timetableData[dayIndex][periodIndex];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getSubjectColor(period.subject),
                              child: Text('${periodIndex + 1}'),
                            ),
                            title: Text(period.subject),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (period.teacher.isNotEmpty)
                                  Text('Teacher: ${period.teacher}'),
                                if (period.room.isNotEmpty)
                                  Text('Room: ${period.room}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'arabic':
        return Colors.blue;
      case 'english':
        return Colors.yellow;
      case 'math':
        return Colors.green;
      case 'history':
        return Colors.orange;
      case 'chemistry':
        return Colors.purple;
      case 'physics':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class TimetableScreen extends StatefulWidget {
//   @override
//   _TimetableScreenState createState() => _TimetableScreenState();
// }
//
// class _TimetableScreenState extends State<TimetableScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final List<String> _days = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday'
//   ];
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // State variables
//   List<String> _classNames = [];
//   String? _selectedClass;
//   List<List<String>> _timetableData =
//       List.generate(5, (_) => List.filled(7, ''));
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _days.length, vsync: this);
//     _fetchClassNames();
//   }
//
//   Future<void> _fetchClassNames() async {
//     try {
//       final snapshot = await _firestore.collection('classes').get();
//       setState(() {
//         _classNames =
//             snapshot.docs.map((doc) => doc['className'] as String).toList();
//         _isLoading = false;
//       });
//
//       if (_classNames.isNotEmpty) {
//         _loadTimetable(_classNames.first);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load classes: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _loadTimetable(String className) async {
//     setState(() {
//       _selectedClass = className;
//       _isLoading = true;
//     });
//
//     try {
//       final snapshot = await _firestore
//           .collection('timetables')
//           .where('className', isEqualTo: className)
//           .get();
//
//       if (snapshot.docs.isNotEmpty) {
//         final data = snapshot.docs.first.data();
//         setState(() {
//           // Clear existing data
//           _timetableData = List.generate(5, (_) => List.filled(7, ''));
//
//           // Load data from Firestore string fields
//           for (int day = 0; day < _days.length; day++) {
//             for (int period = 0; period < 7; period++) {
//               final fieldName = '${_days[day]}_P${period + 1}';
//               if (data.containsKey(fieldName)) {
//                 _timetableData[day][period] = data[fieldName] as String;
//               }
//             }
//           }
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _timetableData = List.generate(5, (_) => List.filled(7, ''));
//           _errorMessage = 'No timetable found for $className';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load timetable: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('School Timetable'),
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(100),
//           child: Column(
//             children: [
//               // Class selection dropdown
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedClass,
//                   decoration: InputDecoration(
//                     labelText: 'Select Class',
//                     border: OutlineInputBorder(),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   items: _classNames.map((className) {
//                     return DropdownMenuItem<String>(
//                       value: className,
//                       child: Text(className),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       _loadTimetable(value);
//                     }
//                   },
//                 ),
//               ),
//               // Day tabs
//               TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 tabs: _days.map((day) => Tab(text: day)).toList(),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(child: Text(_errorMessage!))
//               : TabBarView(
//                   controller: _tabController,
//                   children: List.generate(5, (dayIndex) {
//                     return _buildDayTimetable(dayIndex);
//                   }),
//                 ),
//     );
//   }
//
//   Widget _buildDayTimetable(int dayIndex) {
//     return ListView.builder(
//       itemCount: 7, // 7 periods per day
//       itemBuilder: (context, periodIndex) {
//         final periodData = _timetableData[dayIndex][periodIndex];
//         final parts = periodData.split('|');
//
//         return Card(
//           margin: EdgeInsets.all(8),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor:
//                   _getSubjectColor(parts.isNotEmpty ? parts[0] : null),
//               child: Text('${periodIndex + 1}'),
//             ),
//             title: Text(
//               parts.isNotEmpty ? parts[0] : 'Free Period',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: parts.length > 1
//                 ? Text(
//                     'Teacher: ${parts[1]}${parts.length > 2 ? '\nRoom: ${parts[2]}' : ''}')
//                 : null,
//           ),
//         );
//       },
//     );
//   }
//
//   Color _getSubjectColor(String? subject) {
//     switch (subject?.toLowerCase()) {
//       case 'arabic':
//         return Colors.blue;
//       case 'Math':
//         return Colors.green;
//       case 'history':
//         return Colors.orange;
//       case 'chemistry':
//         return Colors.purple;
//       case 'physics':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }
