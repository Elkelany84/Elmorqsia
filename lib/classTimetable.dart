import 'package:flutter/material.dart';

class WeeklyGridView extends StatelessWidget {
  final Map<String, List<String>> timetable = {
    'الأحد': [
      'Arabic',
      'Math',
      'History',
      'Chemistry',
      'English',
      'Physics',
      'PE'
    ],
    // ... other days
    'الإثنين': [
      'Arabic',
      'Math',
      'History',
      'Chemistry',
      'English',
      'Physics',
      'PE'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جدول الحصص')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header row with times
            Row(
              children: [
                SizedBox(width: 100, child: Text('Time')),
                ...List.generate(
                    5,
                    (i) => Expanded(
                          child: Center(
                              child: Text([
                            'الأحد',
                            'الإثنين',
                            'الثلاثاء',
                            'الأربعاء',
                            'الخميس'
                          ][i])),
                        )),
              ],
            ),
            // Class rows
            ...List.generate(7, (period) {
              return Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('${8 + period}:00-${9 + period}:00'),
                    ),
                  ),
                  ...List.generate(5, (day) {
                    final dayName = [
                      'الأحد',
                      'الإثنين',
                      'Wednesday',
                      'Thursday',
                      'Friday'
                    ][day];
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          timetable[dayName]?[period] ?? 'Free',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
