import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../components/constants.dart';

class Dentals extends StatefulWidget {
  @override
  _DentalsState createState() => _DentalsState();
}

class _DentalsState extends State<Dentals> {
  bool _showWidget = false;
  List<String> dentalsRegion = [''];

  //get all the unique reqion from allMedical collection based on its type
  Future<List<String>> _fetchMedicalNames() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('classes')
        // .where('className', isEqualTo: 'أسنان')
        .get();
    List<String> names = querySnapshot.docs
        .map((doc) => doc['className'] as String)
        .toSet()
        .toList();
    // print(names);
    dentalsRegion.addAll(names);
    print(dentalsRegion);
    return names;
  }

  @override
  void initState() {
    _fetchMedicalNames();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showWidget = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawer: drawer(context),
        appBar: AppBar(
          backgroundColor: Colors.purple,
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.contain,
            child: Row(
              children: [
                Text(
                  'مراكـز الأسنـان',
                  style: kReusableTextStyle,
                ),
                // SizedBox(width:10.0),Container(width: 40.0,color: Colors.white, child: androidDropdown()),
              ],
            ),
          ),
          // leading:
          //   Row(
          //     children: [SizedBox(width:5),
          //       Container(width: 40.0,color: Colors.white, child: androidDropdown()),
          //     ],
          //   ),
        ),
        body: _content(context));
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return _error(context, 'No Connection is Made');
                    break;
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      _error(context, snapshot.error.toString());
                    }
                    if (!snapshot.hasData) {
                      return _error(context, 'No Data');
                    }
                    break;
                }
                return _drawScreen(context, snapshot.data);
              },
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  // .where(
                  //   'region',
                  //   isEqualTo: selectedRegion,
                  // )
                  // .where('type', isEqualTo: 'أسنان')
                  .snapshots(),
            ),
          )
          // ),Advalue(),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, String message) {
    return Center(
        child: Text(
      message,
      style: TextStyle(color: Colors.red),
    ));
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    TabController _tabController;
    final Map<String, List<Map<String, String>>> _timetable = {
      'Monday': [
        {'time': '8:00-9:00', 'subject': 'عربى', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
        {'time': '8:00-9:00', 'subject': 'تاريخ', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'فلسفة', 'teacher': 'Ms. Fatima'},
        {'time': '8:00-9:00', 'subject': 'ألمانى', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
        // ... more classes
      ],
      // ... other days
      'الأجد': [
        {'time': '8:00-9:00', 'subject': 'عربى', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
        {'time': '8:00-9:00', 'subject': 'تاريخ', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'فلسفة', 'teacher': 'Ms. Fatima'},
        {'time': '8:00-9:00', 'subject': 'ألمانى', 'teacher': 'Mr. Ahmed'},
        {'time': '9:00-10:00', 'subject': 'رياضيات', 'teacher': 'Ms. Fatima'},
        // ... more classes
      ],
    };
    final List<String> _days = [
      'الأجد',
      'Monday',
      'الثلاثاء',
      'الأربعاء',
      'الخميس'
    ];
    Future<void> _launched;
    // var _phone = '01066932261';
    return Column(
      children: [
        _showWidget
            ? Flexible(flex: 1, child: androidDropdown())
            : CircularProgressIndicator(),
        Flexible(
          flex: 6,
          child: TabBarView(
            // controller: _tabController,
            children: _days.map((day) {
              return ListView.builder(
                itemCount: _timetable[day]?.length ?? 0,
                itemBuilder: (context, index) {
                  final classInfo = _timetable[day]![index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(classInfo['subject']!),
                      subtitle: Text(
                          '${classInfo['time']}\nTeacher: ${classInfo['teacher']}'),
                      trailing: Icon(Icons.book),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          // child: ListView.builder(
          //     itemCount: data.docs.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return
          //           //   Card(
          //           //   color: Colors.white,
          //           //   child: ExpansionTile(
          //           //       trailing: data.docs[index]['tel1'] != null
          //           //           ? IconButton(
          //           //               icon: Icon(
          //           //                 Icons.call,
          //           //                 color: Colors.purple[900],
          //           //               ),
          //           //               onPressed: () async {
          //           //                 var _phone = data.docs[index]['tel1'];
          //           //                 final Uri url =
          //           //                     Uri(scheme: "tel", path: _phone);
          //           //                 await launchUrl(url);
          //           //               },
          //           //             )
          //           //           : null,
          //           //       title: Text(data.docs[index]['finalName'],
          //           //           style: kCardTextStyle, textAlign: TextAlign.start),
          //           //       subtitle: Text(
          //           //         data.docs[index]['address'],
          //           //         style: kCardSubtitleTextStyle,
          //           //         textAlign: TextAlign.start,
          //           //       ),
          //           //       initiallyExpanded: false,
          //           //       children: [
          //           //         ListTile(
          //           //           title: Row(
          //           //             children: [
          //           //               TextButton(
          //           //                 child: Text('أكتب أو شاهد التقييمات',
          //           //                     style: kCardSubtitleTextStyle,
          //           //                     textAlign: TextAlign.start),
          //           //                 onPressed: () {
          //           //                   Navigator.push(
          //           //                     context,
          //           //                     MaterialPageRoute(
          //           //                       builder: (context) => NewToDo(
          //           //                         dentalName: data.docs[index]
          //           //                             ['finalName'],
          //           //                       ),
          //           //                     ),
          //           //                   );
          //           //                 },
          //           //               ),
          //           //             ],
          //           //           ),
          //           //           leading: IconButton(
          //           //             icon: Icon(
          //           //               Icons.rate_review,
          //           //               color: Colors.orange[900],
          //           //             ),
          //           //             onPressed: () {
          //           //               Navigator.push(
          //           //                 context,
          //           //                 MaterialPageRoute(
          //           //                   builder: (context) => NewToDo(
          //           //                     dentalName: data.docs[index]['finalName'],
          //           //                   ),
          //           //                 ),
          //           //               );
          //           //             },
          //           //           ),
          //           //           trailing: IconButton(
          //           //             onPressed: () {
          //           //               // print(data.docs[index]['name'] +   ' والعنوان هو ' + data.docs[index]['address']+' ورقم التليفون '+ data.docs[index]['tel1'] );
          //           //               Share.share(
          //           //                 (data.docs[index]['finalName'] +
          //           //                     ' والعنوان هو ' +
          //           //                     data.docs[index]['address'] +
          //           //                     ' ورقم التليفون ' +
          //           //                     data.docs[index]['tel1']),
          //           //               );
          //           //             },
          //           //             icon: FaIcon(
          //           //               FontAwesomeIcons.shareAlt,
          //           //               color: Colors.orange[900],
          //           //             ),
          //           //           ),
          //           //         ),
          //           //       ]),
          //           // );
          //           Column(
          //         children: [
          //           // ListTile(
          //           //   title: Row(
          //           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           //     children: [
          //           //       Text(data.docs[index]['finalName'],
          //           //           style: kCardTextStyle.copyWith(fontSize: 16)),
          //           //       // IconButton(
          //           //       //   icon: Icon(
          //           //       //     Icons.call,
          //           //       //     color: Colors.purple[900],
          //           //       //   ),
          //           //       //   onPressed: () async {
          //           //       //     var _phone = data.docs[index]['tel1'];
          //           //       //     final Uri url = Uri(scheme: "tel", path: _phone);
          //           //       //     await launchUrl(url);
          //           //       //   },
          //           //       // ),
          //           //       // IconButton(
          //           //       //   icon: Icon(
          //           //       //     Icons.my_location,
          //           //       //     color: Colors.purple[900],
          //           //       //   ),
          //           //       //   onPressed: () {
          //           //       //     _openInGoogleMaps(data.docs[index]['finalName'] +
          //           //       //         data.docs[index]['address']);
          //           //       //   },
          //           //       // ),
          //           //       // IconButton(
          //           //       //   onPressed: () {
          //           //       //     // print(data.docs[index]['name'] +   ' والعنوان هو ' + data.docs[index]['address']+' ورقم التليفون '+ data.docs[index]['tel1'] );
          //           //       //     Share.share(
          //           //       //       (data.docs[index]['finalName'] +
          //           //       //           ' والعنوان هو ' +
          //           //       //           data.docs[index]['address'] +
          //           //       //           ' ورقم التليفون ' +
          //           //       //           data.docs[index]['tel1']),
          //           //       //     );
          //           //       //   },
          //           //       //   icon: FaIcon(
          //           //       //     FontAwesomeIcons.shareNodes,
          //           //       //     color: Colors.orange[900],
          //           //       //   ),
          //           //       // ),
          //           //     ],
          //           //   ),
          //           //   subtitle: Text(
          //           //     data.docs[index]['address'],
          //           //     style: kCardSubtitleTextStyle,
          //           //   ),
          //           // ),
          //           // Row(
          //           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           //   children: [
          //           //     IconButton(
          //           //       icon: Icon(
          //           //         Icons.call,
          //           //         color: Colors.purple[900],
          //           //       ),
          //           //       onPressed: () async {
          //           //         // var _phone = data.docs[index]['tel1'];
          //           //         // final Uri url = Uri(scheme: "tel", path: _phone);
          //           //         // await launchUrl(url);
          //           //       },
          //           //     ),
          //           //     IconButton(
          //           //       icon: Icon(
          //           //         Icons.my_location,
          //           //         color: Colors.purple[900],
          //           //       ),
          //           //       onPressed: () {
          //           //         // _openInGoogleMaps(data.docs[index]['finalName'] +
          //           //         //     " " +
          //           //         //     data.docs[index]['address']);
          //           //       },
          //           //     ),
          //           //     IconButton(
          //           //       onPressed: () {
          //           //         // print(data.docs[index]['name'] +   ' والعنوان هو ' + data.docs[index]['address']+' ورقم التليفون '+ data.docs[index]['tel1'] );
          //           //         // Share.share(
          //           //         //   (data.docs[index]['finalName'] +
          //           //         //       ' والعنوان هو ' +
          //           //         //       data.docs[index]['address'] +
          //           //         //       ' ورقم التليفون ' +
          //           //         //       data.docs[index]['tel1']),
          //           //         // );
          //           //       },
          //           //       icon: FaIcon(
          //           //         FontAwesomeIcons.shareNodes,
          //           //         color: Colors.orange[900],
          //           //       ),
          //           //     ),
          //           //   ],
          //           // ),
          //           Divider(height: 1.0),
          //         ],
          //       );
          //     }),
        ),
      ],
    );
  }

  String? selectedRegion = 'اختر الفصل';
  // void _openInGoogleMaps(String address) async {
  //   final url =
  //       Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
  //   await launchUrl(url);
  // }

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    dentalsRegion.sort((a, b) => a.compareTo(b));
    for (String currency in dentalsRegion) {
      var newItem = DropdownMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              currency,
              style: kCardTextStyle,
              // TextStyle(
              //     color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedRegion,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedRegion = value;
          print(selectedRegion);
          // getData();
        });
      },
    );
  }

// DropdownButton<String> pharRegion() {
//   List<DropdownMenuItem<String>> dropDownItems = [];
//   for (String region in pharmRegion) {
//     var newItem = DropdownMenuItem(
//       child: Text(region),
//       value: region,
//     );
//     dropDownItems.add(newItem);
//   }
//   }
}
