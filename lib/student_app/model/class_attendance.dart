class ClassAttendance {
  final bool success;
  final List<MonthlyClassAttendance> attendance;
  final double? overallPercentage;
  final int? totalPresent;
  final int? totalDays;
  final int? totalAbsent;
  final int? totalLeaves;
  final int? leavesRemaining;
  final int? currentStreak;
  final int? bestStreak;

  ClassAttendance({
    required this.success,
    required this.attendance,
    this.overallPercentage,
    this.totalPresent,
    this.totalDays,
    this.totalAbsent,
    this.totalLeaves,
    this.leavesRemaining,
    this.currentStreak,
    this.bestStreak,
  });

  factory ClassAttendance.fromJson(Map<String, dynamic> json) {
    final root = json['data'] ?? json;

    List<dynamic> list = [];
    Map<String, dynamic> stats = {};

    if (root is List) {
      list = root;
      stats = json;
    } else if (root is Map<String, dynamic>) {
      list =
          root['attendance'] ?? root['monthlyData'] ?? root['data_list'] ?? [];
      // Sometimes the root itself is the stats object or contains a 'data' object
      if (list.isEmpty && root['data'] is List) {
        list = root['data'];
      }
      // If still empty and root map has Day_ keys, it's a single month object
      if (list.isEmpty && root.keys.any((k) => k.startsWith('Day_'))) {
        list = [root];
      }
      stats = root;
    }

    String clean(dynamic v) => v?.toString().replaceAll('%', '').trim() ?? '';
    double? safeDouble(dynamic v) => double.tryParse(clean(v));
    int? safeInt(dynamic v) {
      final s = clean(v);
      if (s.isEmpty) return null;
      return int.tryParse(s) ?? double.tryParse(s)?.toInt();
    }

    final attendanceList = list
        .map(
          (m) => MonthlyClassAttendance.fromJson(
            m is Map<String, dynamic> ? m : {},
          ),
        )
        .toList();

    var result = ClassAttendance(
      success: json['success'] == true,
      attendance: attendanceList,
      overallPercentage: safeDouble(
        stats['overallAttendance'] ??
            stats['overall_percentage'] ??
            stats['attendance_percentage'],
      ),
      totalPresent: safeInt(
        stats['daysAttended'] ?? stats['present_days'] ?? stats['present'],
      ),
      totalDays: safeInt(
        stats['totalDays'] ?? stats['total_working_days'] ?? stats['total'],
      ),
      totalAbsent: safeInt(
        stats['daysAbsent'] ?? stats['absent_days'] ?? stats['absent'],
      ),
      totalLeaves: safeInt(
        stats['leavesTaken'] ?? stats['leave_days'] ?? stats['leaves'],
      ),
      leavesRemaining: safeInt(
        stats['leavesRemaining'] ?? stats['leaves_remaining'],
      ),
      currentStreak: safeInt(stats['currentStreak'] ?? stats['current_streak']),
      bestStreak: safeInt(stats['bestStreak'] ?? stats['best_streak']),
    );

    // Synthesize stats if missing from root but present in list
    if (result.totalPresent == null && result.attendance.isNotEmpty) {
      int p = 0, a = 0, t = 0, l = 0;
      for (var m in result.attendance) {
        p += m.present;
        a += m.absent;
        l += m
            .leaves; // Assuming leaves are counted in absent or separately? Usually part of total
        // Total usually includes P + A + L + H
        t += m.total;
      }

      // Recalculate if totals are 0 but individual parts are not
      if (t == 0) {
        t = p + a + l; // Simple fallback
      }

      result = ClassAttendance(
        success: result.success,
        attendance: result.attendance,
        overallPercentage: t > 0 ? (p / t) * 100 : 0.0,
        totalPresent: p,
        totalDays: t,
        totalAbsent: a,
        totalLeaves: l,
        leavesRemaining: result.leavesRemaining,
        currentStreak: result.currentStreak,
        bestStreak: result.bestStreak,
      );
    }

    return result;
  }

  // Method to check if attendance is empty
  bool get isEmpty => attendance.isEmpty;
}

class MonthlyClassAttendance {
  final String monthName;
  final int present;
  final int absent;
  final int leaves;
  final int outings;
  final int holidays;
  final int total;
  final double percentage;
  final List<ClassDayAttendance>? details;
  final Map<String, dynamic> rawJson;

  MonthlyClassAttendance({
    required this.monthName,
    required this.present,
    required this.absent,
    required this.leaves,
    required this.outings,
    required this.holidays,
    required this.total,
    required this.percentage,
    this.details,
    required this.rawJson,
  });

  factory MonthlyClassAttendance.fromJson(Map<String, dynamic> json) {
    String clean(dynamic v) => v?.toString().replaceAll('%', '').trim() ?? '';
    int safeInt(dynamic v, int fallback) {
      final s = clean(v);
      if (s.isEmpty) return fallback;
      return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? fallback;
    }

    double safeDouble(dynamic v, double fallback) {
      return double.tryParse(clean(v)) ?? fallback;
    }

    int p = safeInt(
      json['present'] ?? json['present_days'] ?? json['attended'],
      0,
    );
    int a = safeInt(json['absent'] ?? json['absent_days'], 0);
    int l = safeInt(json['leaves'] ?? json['leave_days'], 0);
    int o = safeInt(json['outings'] ?? json['outing_days'], 0);
    int h = safeInt(json['holidays'], 0);
    int t = safeInt(
      json['total'] ?? json['total_working_days'] ?? json['working_days'],
      p + a + l + o + h,
    );
    double perc = safeDouble(
      json['percentage'] ?? json['attendance_percentage'],
      t > 0 ? (p / t) * 100 : 0.0,
    );

    List<ClassDayAttendance> synthDetails = [];

    // Check for Day_01...Day_31 pattern
    if (json.keys.any((k) => k.startsWith('Day_'))) {
      int sp = 0, sa = 0, sl = 0, so = 0, sh = 0;
      json.forEach((key, value) {
        if (key.startsWith('Day_') && value != null) {
          final dayStr = key.substring(4);
          final status = value.toString().toUpperCase();

          if (status == 'P')
            sp++;
          else if (status == 'A')
            sa++;
          else if (status == 'L')
            sl++;
          else if (status == 'O')
            so++;
          else if (status == 'H')
            sh++;
          // Treat others as absent or ignore?

          synthDetails.add(
            ClassDayAttendance(
              date:
                  "${json['month_name'] ?? json['month'] ?? json['monthName'] ?? ''} $dayStr",
              status: status,
            ),
          );
        }
      });

      // Use synthesized values if they are more complete than the basic stats
      if ((sp + sa + sl + so + sh) > (p + a + l + o + h) ||
          (t == 0 && (sp + sa + sl + so + sh) > 0)) {
        p = sp;
        a = sa;
        l = sl;
        o = so;
        h = sh;
        t = p + a + l + o + h;
        perc = t > 0 ? (p / t) * 100 : 0.0;
      }
    } else {
      // Look for 'details' list if 'Day_XX' fields aren't present
      final detailsList =
          json['details'] ??
          json['attendance_details'] ??
          json['day_wise_details'];
      if (detailsList is List) {
        for (var d in detailsList) {
          if (d is Map<String, dynamic>) {
            synthDetails.add(
              ClassDayAttendance(
                date: d['attendance_date'] ?? d['date'],
                status: d['status'],
              ),
            );
          }
        }
      }
    }

    return MonthlyClassAttendance(
      monthName:
          (json['month_name'] ?? json['month'] ?? json['monthName'] ?? '')
              .toString(),
      present: p,
      absent: a,
      leaves: l,
      outings: o,
      holidays: h,
      total: t,
      percentage: perc,
      details: synthDetails.isNotEmpty ? synthDetails : null,
      rawJson: json,
    );
  }
}

class ClassDayAttendance {
  final String date;
  final String status;

  ClassDayAttendance({required this.date, required this.status});
}
