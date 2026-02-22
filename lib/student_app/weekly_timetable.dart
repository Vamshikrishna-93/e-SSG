import 'package:flutter/material.dart';
import 'package:student_app/theme_controllers.dart';

class WeeklyTimetablePage extends StatelessWidget {
  const WeeklyTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current day (for demo, using Monday as today)
    final today = DateTime.now();
    final currentDayIndex = today.weekday - 1; // 0 = Monday, 6 = Sunday

    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,

            body: SafeArea(
              child: Column(
                children: [
                  // Current Day Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: theme.cardColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.brightness == Brightness.dark
                              ? Colors.blue.shade300
                              : Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDayName(currentDayIndex),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge!.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue.shade900
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Today",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _DaySchedule(
                            dayName: "Monday",
                            isToday: currentDayIndex == 0,
                            schedules: _getMondaySchedule(),
                          ),
                          _DaySchedule(
                            dayName: "Tuesday",
                            isToday: currentDayIndex == 1,
                            schedules: _getTuesdaySchedule(),
                          ),
                          _DaySchedule(
                            dayName: "Wednesday",
                            isToday: currentDayIndex == 2,
                            schedules: _getWednesdaySchedule(),
                          ),
                          _DaySchedule(
                            dayName: "Thursday",
                            isToday: currentDayIndex == 3,
                            schedules: _getThursdaySchedule(),
                          ),
                          _DaySchedule(
                            dayName: "Friday",
                            isToday: currentDayIndex == 4,
                            schedules: _getFridaySchedule(),
                          ),
                          _DaySchedule(
                            dayName: "Saturday",
                            isToday: currentDayIndex == 5,
                            schedules: _getSaturdaySchedule(),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Back to Day View Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: const Center(child: _BackToDayViewButton()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(int index) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (index < 0 || index >= days.length) return "Monday";
    return days[index];
  }

  List<ScheduleItem> _getMondaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem(
        "Physics",
        "09:50 - 10:35",
        "Ms. Anjali",
        isHighlighted: true,
      ),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem("Social", "02:40 - 03:25", "Mr. Naresh"),
    ];
  }

  List<ScheduleItem> _getTuesdaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem("Physics", "09:50 - 10:35", "Ms. Anjali"),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem(
        "Social",
        "02:40 - 03:25",
        "Mr. Naresh",
        isHighlighted: true,
      ),
    ];
  }

  List<ScheduleItem> _getWednesdaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem(
        "Physics",
        "09:50 - 10:35",
        "Ms. Anjali",
        isHighlighted: true,
      ),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem("Social", "02:40 - 03:25", "Mr. Naresh"),
    ];
  }

  List<ScheduleItem> _getThursdaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem(
        "Physics",
        "09:50 - 10:35",
        "Ms. Anjali",
        isHighlighted: true,
      ),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem("Social", "02:40 - 03:25", "Mr. Naresh"),
    ];
  }

  List<ScheduleItem> _getFridaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem(
        "Physics",
        "09:50 - 10:35",
        "Ms. Anjali",
        isHighlighted: true,
      ),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem("Social", "02:40 - 03:25", "Mr. Naresh"),
    ];
  }

  List<ScheduleItem> _getSaturdaySchedule() {
    return [
      ScheduleItem("Maths", "09:00 - 09:45", "Mr. Ramesh"),
      ScheduleItem(
        "Physics",
        "09:50 - 10:35",
        "Ms. Anjali",
        isHighlighted: true,
      ),
      ScheduleItem("Chemistry", "10:40 - 11:25", "Dr. Suresh"),
      ScheduleItem("English", "11:30 - 12:15", "Mrs. Kavitha"),
      ScheduleItem("Lunch Break", "12:15 - 01:00", null),
      ScheduleItem("Biology", "01:00 - 01:45", "Mr. Prakash"),
      ScheduleItem("Computer Science", "01:50 - 02:35", "Ms. Swathi"),
      ScheduleItem("Social", "02:40 - 03:25", "Mr. Naresh"),
    ];
  }
}

class ScheduleItem {
  final String subject;
  final String time;
  final String? instructor;
  final bool isHighlighted;

  ScheduleItem(
    this.subject,
    this.time,
    this.instructor, {
    this.isHighlighted = false,
  });
}

class _DaySchedule extends StatelessWidget {
  final String dayName;
  final List<ScheduleItem> schedules;
  final bool isToday;
  final bool isLast;

  const _DaySchedule({
    required this.dayName,
    required this.schedules,
    this.isToday = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header
        Padding(
          padding: EdgeInsets.only(bottom: 12, top: isLast ? 0 : 16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.brightness == Brightness.dark
                    ? Colors.blue.shade300
                    : Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.brightness == Brightness.dark
                      ? Colors.blue.shade300
                      : Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        // Schedule Cards
        ...schedules.asMap().entries.map((entry) {
          final index = entry.key;
          final schedule = entry.value;
          return _ScheduleCard(
            subject: schedule.subject,
            time: schedule.time,
            instructor: schedule.instructor,
            isHighlighted: schedule.isHighlighted,
            isLast: index == schedules.length - 1,
          );
        }),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String subject;
  final String time;
  final String? instructor;
  final bool isHighlighted;
  final bool isLast;

  const _ScheduleCard({
    required this.subject,
    required this.time,
    this.instructor,
    this.isHighlighted = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? (theme.brightness == Brightness.dark
                    ? Colors.blue.shade700
                    : Colors.blue)
              : theme.dividerColor,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.textTheme.bodySmall!.color,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Instructor
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: theme.textTheme.bodySmall!.color,
              ),
              const SizedBox(width: 6),
              Text(
                instructor ?? "-",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackToDayViewButton extends StatelessWidget {
  const _BackToDayViewButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.calendar_today,
        color: theme.brightness == Brightness.dark
            ? Colors.blue.shade300
            : const Color(0xFF2563EB),
        size: 18,
      ),
      label: Text(
        "Back to Day View",
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.blue.shade300
              : const Color(0xFF2563EB),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.blue.shade300
              : const Color(0xFF2563EB),
          width: 1.5,
        ),
        backgroundColor: theme.cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
