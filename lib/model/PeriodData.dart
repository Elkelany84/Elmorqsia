class PeriodData {
  final String subject;
  final String teacher;
  final String room;

  const PeriodData({
    required this.subject,
    required this.teacher,
    required this.room,
  });

  factory PeriodData.empty() => PeriodData(
        subject: 'Free Period',
        teacher: '',
        room: '',
      );
}
