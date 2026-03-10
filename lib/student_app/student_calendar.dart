import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/student_app/widgets/student_app_header.dart';
import 'package:student_app/student_app/services/calendar_service.dart';

class StudentCalendar extends StatefulWidget {
  final bool showAppBar;
  final bool isInline;

  const StudentCalendar({
    super.key,
    this.showAppBar = true,
    this.isInline = false,
  });

  @override
  State<StudentCalendar> createState() => _StudentCalendarState();
}

class _StudentCalendarState extends State<StudentCalendar> {
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final data = await CalendarService.getCalendarEvents();
      final Map<DateTime, List<CalendarEvent>> newEvents = {};

      for (var item in data) {
        final String title = item['title']?.toString() ?? 'Event';
        final String description = item['description']?.toString() ?? '';
        final String type = item['type']?.toString() ?? 'event';
        final String source = item['source']?.toString() ?? 'calendar';
        final String? dateStr = item['date']?.toString();
        final String? endDateStr = item['end_date']?.toString();
        final String? startTime = item['start_time']?.toString();
        final String? endTime = item['end_time']?.toString();
        final int? subjectId = item['subjectid'] != null
            ? int.tryParse(item['subjectid'].toString())
            : null;
        final int? examId = item['examid'] != null
            ? int.tryParse(item['examid'].toString())
            : null;

        if (dateStr != null) {
          try {
            final date = DateTime.parse(dateStr);
            final key = DateTime(date.year, date.month, date.day);

            DateTime? endDate;
            if (endDateStr != null) {
              endDate = DateTime.tryParse(endDateStr);
            }

            if (newEvents[key] == null) {
              newEvents[key] = [];
            }

            Color color = Colors.blue;
            if (type.toLowerCase() == 'exam') {
              color = Colors.red;
            } else if (type.toLowerCase() == 'holiday') {
              color = Colors.orange;
            } else if (type.toLowerCase() == 'activity') {
              color = Colors.green;
            }

            newEvents[key]!.add(
              CalendarEvent(
                title: title,
                description: description,
                type: type,
                source: source,
                date: date,
                endDate: endDate,
                startTime: startTime,
                endTime: endTime,
                subjectId: subjectId,
                examId: examId,
                color: color,
              ),
            );
          } catch (e) {
            debugPrint("Error parsing date: $dateStr");
          }
        }
      }

      if (mounted) {
        setState(() {
          _events = newEvents;
        });
      }
    } catch (e) {
      debugPrint("Error fetching calendar events in UI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInline) {
      return _buildCalendarContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Purple Header
          const StudentAppHeader(title: "Calendar"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCalendarContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;
    final totalSlots = firstWeekday + daysInMonth;
    final events = _getEventsForMonth();

    return Column(
      children: [
        // 2. Calendar Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                        _fetchEvents();
                      },
                    ),
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                        _fetchEvents();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekDayLabel("SUN"),
                    _WeekDayLabel("MON"),
                    _WeekDayLabel("TUE"),
                    _WeekDayLabel("WED"),
                    _WeekDayLabel("THU"),
                    _WeekDayLabel("FRI"),
                    _WeekDayLabel("SAT"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                ),
                itemCount: totalSlots,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox();

                  final day = index - firstWeekday + 1;
                  final date = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                  final isToday =
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFF7C3AED) : null,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$day",
                        style: TextStyle(
                          color: isToday
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. Events Section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  "Events This Month",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        // Note: Using a fallback if file doesn't exist might be safer,
                        // but keeping it as is since it was in the source.
                        Image.file(
                          File(
                            'C:/Users/Vamsikrishna/.gemini/antigravity/brain/89927662-878a-4dec-9931-3702b27753b3/no_events_illustration_1772960651369.png',
                          ),
                          height: 120,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No events this month",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final entry = events[index];
                    final e = entry.event;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: e.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${entry.date.day}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: e.color,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM',
                              ).format(entry.date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: e.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        e.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: e.startTime != null ? Text(e.startTime!) : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                      onTap: () => _showEventDetails(context, e),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<EventEntry> _getEventsForMonth() {
    final List<EventEntry> list = [];
    final lastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    for (int i = 1; i <= lastDay; i++) {
      final d = DateTime(_currentMonth.year, _currentMonth.month, i);
      final key = DateTime(d.year, d.month, d.day);
      if (_events.containsKey(key)) {
        for (var e in _events[key]!) {
          list.add(EventEntry(d, e));
        }
      }
    }
    return list;
  }

  void _showEventDetails(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 8),
                Text(DateFormat('EEEE, d MMMM yyyy').format(event.date)),
              ],
            ),
            if (event.startTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime}${event.endTime != null ? ' - ${event.endTime}' : ''}",
                  ),
                ],
              ),
            ],
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(event.description),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CLOSE",
              style: TextStyle(color: Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarEvent {
  final String title;
  final String description;
  final String type;
  final String source;
  final DateTime date;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int? subjectId;
  final int? examId;
  final Color color;

  CalendarEvent({
    required this.title,
    this.description = '',
    this.type = 'event',
    this.source = 'calendar',
    required this.date,
    this.endDate,
    this.startTime,
    this.endTime,
    this.subjectId,
    this.examId,
    required this.color,
  });
}

class EventEntry {
  final DateTime date;
  final CalendarEvent event;
  EventEntry(this.date, this.event);
}

class _WeekDayLabel extends StatelessWidget {
  final String label;
  const _WeekDayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
