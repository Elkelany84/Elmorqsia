import 'package:elmorqsiaschool/reservations/reserveDateForTemplate.dart';
import 'package:elmorqsiaschool/reservations/showListViewReservedData.dart';
import 'package:elmorqsiaschool/reservations/showPdfData.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight / 10; // Each button takes 1/6th of screen
    final screenWidth = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth / 3; // Each button takes 1/6th of screen
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.only(right: 5.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/logo.jpg',
              ),
            ),
          ),
        ),
        title: const Text(
          // 'مدرسة المرقسية الثانوية',
          'إدارة وسط التعليمية',
          style: TextStyle(
            fontSize: 28,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            ),
          ),
        ],
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
      // AppBar(
      //   backgroundColor: Colors.indigo.shade700,
      //   elevation: 10,
      //   shadowColor: Colors.indigo.shade900,
      //   centerTitle: true,
      //   title: const Text(
      //     'مدرسة المرقسية الثانوية',
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
      //   ),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SchoolNewsPage()));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReservationForm()));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Button 1 Pressed!')),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF1565C0), // Blue 800
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                      const Color(0x22000000)), // Ripple effect
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3), // Blue 500
                        Color(0xFF0D47A1), // Blue 900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.8],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D47A1).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    // constraints:
                    //     const BoxConstraints(minWidth: 88.0, minHeight: 48.0),
                    alignment: Alignment.center,
                    child: const Text(
                      // 'أخبار المدرسة',
                      'استخراج بيان',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'Tajawal',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Old Button 1
            // SizedBox(
            //   height: buttonHeight,
            //   width: buttonWidth,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Button 1 Pressed!')),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //       backgroundColor: Colors.blue,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       elevation: 5,
            //       shadowColor: Colors.blue.withOpacity(0.5),
            //     ),
            //     child: const Text(
            //       'أخبار المدرسة',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 22,
            //           fontFamily: 'Tajawal'),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 100),

            //New Button 2
            SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  //navigate to WeeklyGridView page
                  // Navigator.push(
                  //     context,
                  // MaterialPageRoute(
                  //     builder: (context) => WeeklyGridView()));
                  //navigate to TimetableScreen
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => TimetableScreen()));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReservationReport()));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Button 1 Pressed!')),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF1565C0), // Blue 800
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                      const Color(0x22000000)), // Ripple effect
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3), // Blue 500
                        Color(0xFF0D47A1), // Blue 900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.8],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D47A1).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    // constraints:
                    //     const BoxConstraints(minWidth: 88.0, minHeight: 48.0),
                    alignment: Alignment.center,
                    child: const Text(
                      // 'جدول الحصص',
                      'عرض الداتا للموظف',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'Tajawal',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Old Button 2
            // SizedBox(
            //   height: buttonHeight,
            //   width: buttonWidth,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Button 2 Pressed!')),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //       backgroundColor: Colors.green,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       elevation: 8,
            //       shadowColor: Colors.green.withOpacity(0.5),
            //     ),
            //     child: const Text(
            //       'جدول الحصص',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 22,
            //           fontFamily: 'Tajawal'),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 100), // Spacer
//New Button 3
            SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SchoolContactsPage()));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ReservationForm()));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReservationsList()));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Button 1 Pressed!')),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF1565C0), // Blue 800
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                      const Color(0x22000000)), // Ripple effect
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2196F3), // Blue 500
                        Color(0xFF0D47A1), // Blue 900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.8],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D47A1).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    // constraints:
                    //     const BoxConstraints(minWidth: 88.0, minHeight: 48.0),
                    alignment: Alignment.center,
                    child: const Text(
                      // 'تواصل مع المدرسة'
                      'عرض الداتا للمدير',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'Tajawal',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Old Button 3 (Gradient Button)
            // SizedBox(
            //   height: buttonHeight,
            //   width: buttonWidth,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Button 3 Pressed!')),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //       backgroundColor: Colors.purple,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30),
            //       ),
            //       elevation: 10,
            //       shadowColor: Colors.purple.withOpacity(0.5),
            //     ),
            //     child: const Text(
            //       'تواصل مع المدرسة',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 22,
            //           fontFamily: 'Tajawal'),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
