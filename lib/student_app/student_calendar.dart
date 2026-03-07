import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching calendar events in UI: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

          final mainColumn = Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.chevron_left,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month - 1,
                                      );
                                      _isLoading = true;
                                    });
                                    _fetchEvents();
                                  },
                          ),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month + 1,
                                      );
                                      _isLoading = true;
                                    });
                                    _fetchEvents();
                                  },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _WeekDayLabel("S"),
                          _WeekDayLabel("M"),
                          _WeekDayLabel("T"),
                          _WeekDayLabel("W"),
                          _WeekDayLabel("T"),
                          _WeekDayLabel("F"),
                          _WeekDayLabel("S"),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                          ),
                      itemCount: totalSlots,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday || index >= totalSlots) {
                          return const SizedBox();
                        }

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

                        final dayEvents = _events[date] ?? [];

                        return Column(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: isToday ? theme.primaryColor : null,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$day",
                                style: TextStyle(
                                  color: isToday
                                      ? Colors.white
                                      : theme.textTheme.bodyLarge?.color,
                                  fontWeight: isToday ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                            if (dayEvents.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dayEvents.take(3).map((e) {
                                  return Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: e.color,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "EVENTS THIS MONTH",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.withOpacity(0.15),
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < 0 || index >= events.length)
                    return const SizedBox.shrink();
                  final entry = events[index];
                  final e = entry.event;

                  return InkWell(
                    onTap: () {
                      _showEventDetails(context, e);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: e.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${entry.date.day}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                if (e.startTime != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${e.startTime}${e.endTime != null ? ' - ${e.endTime}' : ''}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: e.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: e.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 40),
            ],
          );

          if (widget.isInline) {
            return mainColumn;
          }

          return Scaffold(
            appBar: widget.showAppBar ? AppBar(title: const Text("Academic Calendar"), centerTitle: true) : null,
            body: SafeArea(
              child: Column(
                children: [
                  if (!widget.showAppBar)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Academic Calendar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(child: SingleChildScrollView(child: mainColumn)),
                ],
              ),
            ),
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
      if (_events.containsKey(d)) {
        for (var e in _events[d]!) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: event.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(DateFormat('EEEE, d MMMM yyyy').format(event.date)),
              ],
            ),
            if (event.startTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
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
            if (event.subjectId != null) ...[
              const SizedBox(height: 8),
              Text(
                "Subject ID: ${event.subjectId}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE"),
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
