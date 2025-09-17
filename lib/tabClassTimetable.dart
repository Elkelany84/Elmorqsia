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
//     'الأجد',
//     'Monday',
//     'الثلاثاء',
//     'الأربعاء',
//     'الخميس'
//   ];
//
//   // Sample timetable data
//   final Map<String, List<Map<String, String>>> _timetable = {
//     'Monday': [
//       {'time': '8:00-9:00', 'subject': 'عربى', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
//       {'time': '8:00-9:00', 'subject': 'تاريخ', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'فلسفة', 'teacher': 'Ms. Fatima'},
//       {'time': '8:00-9:00', 'subject': 'ألمانى', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
//       // ... more classes
//     ],
//     // ... other days
//     'الأجد': [
//       {'time': '8:00-9:00', 'subject': 'عربى', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
//       {'time': '8:00-9:00', 'subject': 'تاريخ', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'فلسفة', 'teacher': 'Ms. Fatima'},
//       {'time': '8:00-9:00', 'subject': 'ألمانى', 'teacher': 'Mr. Ahmed'},
//       {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
//       // ... more classes
//     ],
//   };
//   bool _showWidget = false;
//   List<String> dentalsRegion = [''];
//   Future<List<String>> _fetchMedicalNames() async {
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('classes')
//         // .where('type', isEqualTo: 'أسنان')
//         .get();
//     List<String> names = querySnapshot.docs
//         .map((doc) => doc['className'] as String)
//         .toSet()
//         .toList();
//     // print(names);
//     dentalsRegion.addAll(names);
//     // print(hospitalsRegion);
//     return names;
//   }
//
//   @override
//   void initState() {
//     _fetchMedicalNames();
//     Future.delayed(Duration(seconds: 2), () {
//       setState(() {
//         _showWidget = true;
//       });
//     });
//     super.initState();
//     _tabController = TabController(length: _days.length, vsync: this);
//   }
//
//   String _selectedFilter = '';
//   @override
//   Widget build(BuildContext context) {
//     final Stream<QuerySnapshot> _medicalStream = FirebaseFirestore.instance
//         .collection('classes')
//         // .orderBy('name')
//         // .orderBy('region')
//         // .where('type',
//         //     isEqualTo: _selectedFilter.isNotEmpty ? _selectedFilter : null)
//         .snapshots();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('جدول الحصص'),
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: _days.map((day) => Tab(text: day)).toList(),
//         ),
//       ),
//       body: Column(
//         children: [
//           Flexible(
//             child: StreamBuilder(
//               builder: (BuildContext context, AsyncSnapshot snapshot) {
//                 switch (snapshot.connectionState) {
//                   case ConnectionState.none:
//                     return _error(context, 'No Connection is Made');
//                     break;
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                     break;
//                   case ConnectionState.active:
//                   case ConnectionState.done:
//                     if (snapshot.hasError) {
//                       _error(context, snapshot.error.toString());
//                     }
//                     if (!snapshot.hasData) {
//                       return _error(context, 'No Data');
//                     }
//                     break;
//                 }
//                 return _drawScreen(context, snapshot.data);
//               },
//               stream: FirebaseFirestore.instance
//                   .collection('classes')
//                   // .where(
//                   //   'region',
//                   //   isEqualTo: selectedRegion,
//                   // )
//                   // .where('type', isEqualTo: 'أسنان')
//                   .snapshots(),
//             ),
//           ),
//           // TabBarView(
//           //   controller: _tabController,
//           //   children: _days.map((day) {
//           //     return ListView.builder(
//           //       itemCount: _timetable[day]?.length ?? 0,
//           //       itemBuilder: (context, index) {
//           //         final classInfo = _timetable[day]![index];
//           //         return Card(
//           //           margin: EdgeInsets.all(8),
//           //           child: ListTile(
//           //             leading: CircleAvatar(
//           //               child: Text('${index + 1}'),
//           //             ),
//           //             title: Text(classInfo['subject']!),
//           //             subtitle: Text(
//           //                 '${classInfo['time']}\nTeacher: ${classInfo['teacher']}'),
//           //             trailing: Icon(Icons.book),
//           //           ),
//           //         );
//           //       },
//           //     );
//           //   }).toList(),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _error(BuildContext context, String message) {
//     return Center(
//         child: Text(
//       message,
//       style: TextStyle(color: Colors.red),
//     ));
//   }
//
//   Widget _drawScreen(BuildContext context, QuerySnapshot data) {
//     Future<void> _launched;
//     // var _phone = '01066932261';
//     return Column(
//       children: [
//         _showWidget
//             ? Flexible(flex: 1, child: androidDropdown())
//             : CircularProgressIndicator(),
//         Flexible(
//           flex: 6,
//           child: TabBarView(
//             controller: _tabController,
//             children: _days.map((day) {
//               return ListView.builder(
//                 itemCount: _timetable[day]?.length ?? 0,
//                 itemBuilder: (context, index) {
//                   final classInfo = _timetable[day]![index];
//                   return Card(
//                     margin: EdgeInsets.all(8),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         child: Text('${index + 1}'),
//                       ),
//                       title: Text(classInfo['subject']!),
//                       subtitle: Text(
//                           '${classInfo['time']}\nTeacher: ${classInfo['teacher']}'),
//                       trailing: Icon(Icons.book),
//                     ),
//                   );
//                 },
//               );
//             }).toList(),
//           ),
//           // ListView.builder(
//           //     itemCount: data.docs.length,
//           //     itemBuilder: (BuildContext context, int index) {
//           //       return Column(
//           //         children: [
//           //           ListTile(
//           //             title: Row(
//           //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //               children: [
//           //                 Text(
//           //                   data.docs[index]['finalName'],
//           //                   // style: kCardTextStyle.copyWith(fontSize: 16)
//           //                 ),
//           //                 // IconButton(
//           //                 //   icon: Icon(
//           //                 //     Icons.call,
//           //                 //     color: Colors.purple[900],
//           //                 //   ),
//           //                 //   onPressed: () async {
//           //                 //     var _phone = data.docs[index]['tel1'];
//           //                 //     final Uri url = Uri(scheme: "tel", path: _phone);
//           //                 //     await launchUrl(url);
//           //                 //   },
//           //                 // ),
//           //                 // IconButton(
//           //                 //   icon: Icon(
//           //                 //     Icons.my_location,
//           //                 //     color: Colors.purple[900],
//           //                 //   ),
//           //                 //   onPressed: () {
//           //                 //     _openInGoogleMaps(data.docs[index]['finalName'] +
//           //                 //         data.docs[index]['address']);
//           //                 //   },
//           //                 // ),
//           //                 // IconButton(
//           //                 //   onPressed: () {
//           //                 //     // print(data.docs[index]['name'] +   ' والعنوان هو ' + data.docs[index]['address']+' ورقم التليفون '+ data.docs[index]['tel1'] );
//           //                 //     Share.share(
//           //                 //       (data.docs[index]['finalName'] +
//           //                 //           ' والعنوان هو ' +
//           //                 //           data.docs[index]['address'] +
//           //                 //           ' ورقم التليفون ' +
//           //                 //           data.docs[index]['tel1']),
//           //                 //     );
//           //                 //   },
//           //                 //   icon: FaIcon(
//           //                 //     FontAwesomeIcons.shareNodes,
//           //                 //     color: Colors.orange[900],
//           //                 //   ),
//           //                 // ),
//           //               ],
//           //             ),
//           //             subtitle: Text(
//           //               data.docs[index]['address'],
//           //               // style: kCardSubtitleTextStyle,
//           //             ),
//           //           ),
//           //           Row(
//           //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           //             children: [
//           //               IconButton(
//           //                 icon: Icon(
//           //                   Icons.call,
//           //                   color: Colors.purple[900],
//           //                 ),
//           //                 onPressed: () async {
//           //                   // var _phone = data.docs[index]['tel1'];
//           //                   // final Uri url = Uri(scheme: "tel", path: _phone);
//           //                   // await launchUrl(url);
//           //                 },
//           //               ),
//           //               IconButton(
//           //                 icon: Icon(
//           //                   Icons.my_location,
//           //                   color: Colors.purple[900],
//           //                 ),
//           //                 onPressed: () {
//           //                   // _openInGoogleMaps(data.docs[index]['finalName'] +
//           //                   //     " " +
//           //                   //     data.docs[index]['address']);
//           //                 },
//           //               ),
//           //               IconButton(
//           //                 onPressed: () {
//           //                   // print(data.docs[index]['name'] +   ' والعنوان هو ' + data.docs[index]['address']+' ورقم التليفون '+ data.docs[index]['tel1'] );
//           //                   // Share.share(
//           //                   //   (data.docs[index]['finalName'] +
//           //                   //       ' والعنوان هو ' +
//           //                   //       data.docs[index]['address'] +
//           //                   //       ' ورقم التليفون ' +
//           //                   //       data.docs[index]['tel1']),
//           //                   // );
//           //                 },
//           //                 icon: FaIcon(
//           //                   FontAwesomeIcons.shareNodes,
//           //                   color: Colors.orange[900],
//           //                 ),
//           //               ),
//           //             ],
//           //           ),
//           //           Divider(height: 1.0),
//           //         ],
//           //       );
//           //     }),
//         ),
//       ],
//     );
//   }
//
//   String? selectedRegion = 'الصف الأول الثانوى 1-4';
//
//   DropdownButton<String> androidDropdown() {
//     List<DropdownMenuItem<String>> dropdownItems = [];
//     dentalsRegion.sort((a, b) => a.compareTo(b));
//     for (String currency in dentalsRegion) {
//       var newItem = DropdownMenuItem(
//         value: currency,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               currency,
//               // style: kCardTextStyle,
//               // TextStyle(
//               //     color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
//               textAlign: TextAlign.center,
//               textDirection: TextDirection.rtl,
//             ),
//           ],
//         ),
//       );
//       dropdownItems.add(newItem);
//     }
//
//     return DropdownButton<String>(
//       value: selectedRegion,
//       items: dropdownItems,
//       onChanged: (value) {
//         setState(() {
//           selectedRegion = value;
//           print(selectedRegion);
//           // getData();
//         });
//       },
//     );
//   }
// }
