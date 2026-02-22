class HostelAttendance {
  final bool success;
  final List<MonthlyAttendance> attendance;
  final double? overallPercentage;
  final int? totalPresent;
  final int? totalDays;
  final int? totalAbsent;
  final int? totalLeaves;
  final int? totalNightOuts;
  final int? currentStreak;
  final int? bestStreak;
  final String? hostelName;
  final String? floorName;
  final String? roomName;
  final String? wardenName;

  HostelAttendance({
    required this.success,
    required this.attendance,
    this.overallPercentage,
    this.totalPresent,
    this.totalDays,
    this.totalAbsent,
    this.totalLeaves,
    this.totalNightOuts,
    this.currentStreak,
    this.bestStreak,
    this.hostelName,
    this.floorName,
    this.roomName,
    this.wardenName,
  });

  factory HostelAttendance.fromJson(Map<String, dynamic> json) {
    final root = json['data'] ?? json;

    List<dynamic> list = [];
    Map<String, dynamic> stats = {};

    if (root is List) {
      list = root;
      stats = json;
    } else if (root is Map<String, dynamic>) {
      list =
          root['attendance'] ?? root['monthlyData'] ?? root['data_list'] ?? [];
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
          (m) => MonthlyAttendance.fromJson(m is Map<String, dynamic> ? m : {}),
        )
        .toList();

    final hostelInfo = json['hostel_info'] as Map<String, dynamic>?;

    var result = HostelAttendance(
      success: json['success'] == true,
      attendance: attendanceList,
      overallPercentage: safeDouble(
        stats['overall_percentage'] ?? stats['overall_perc'],
      ),
      totalPresent: safeInt(stats['total_present'] ?? stats['present']),
      totalDays: safeInt(
        stats['total_days'] ?? stats['total'] ?? stats['working_days'],
      ),
      totalAbsent: safeInt(stats['total_absent'] ?? stats['absent']),
      totalLeaves: safeInt(stats['total_leaves'] ?? stats['leaves']),
      totalNightOuts: safeInt(stats['total_night_outs'] ?? stats['night_outs']),
      currentStreak: safeInt(stats['current_streak'] ?? stats['streak']),
      bestStreak: safeInt(stats['best_streak'] ?? stats['max_streak']),
      hostelName:
          hostelInfo?['hostel_name']?.toString() ??
          stats['hostel_name']?.toString(),
      floorName:
          hostelInfo?['floorname']?.toString() ??
          stats['floor_name']?.toString(),
      roomName:
          hostelInfo?['roomname']?.toString() ?? stats['room_name']?.toString(),
      wardenName:
          hostelInfo?['incharge']?.toString() ??
          stats['warden_name']?.toString(),
    );

    // Synthesize stats if missing from root but present in list
    if (result.totalPresent == null && result.attendance.isNotEmpty) {
      int p = 0, a = 0, t = 0;
      for (var m in result.attendance) {
        p += m.present;
        a += m.absent;
        t += m.total;
      }
      result = HostelAttendance(
        success: result.success,
        attendance: result.attendance,
        overallPercentage: t > 0 ? (p / t) * 100 : 0.0,
        totalPresent: p,
        totalDays: t,
        totalAbsent: a,
        totalLeaves: result.totalLeaves,
        totalNightOuts: result.totalNightOuts,
        currentStreak: result.currentStreak,
        bestStreak: result.bestStreak,
        hostelName: result.hostelName,
        floorName: result.floorName,
        roomName: result.roomName,
        wardenName: result.wardenName,
      );
    }

    return result;
  }
}

class MonthlyAttendance {
  final String monthName;
  final int present;
  final int absent;
  final int holidays;
  final int outings;
  final int leaves;
  final int total;
  final double percentage;
  final List<DayAttendance>? details;
  final Map<String, dynamic> rawJson;

  MonthlyAttendance({
    required this.monthName,
    required this.present,
    required this.absent,
    required this.holidays,
    required this.outings,
    required this.leaves,
    required this.total,
    required this.percentage,
    this.details,
    required this.rawJson,
  });

  factory MonthlyAttendance.fromJson(Map<String, dynamic> json) {
    String clean(dynamic v) => v?.toString().replaceAll('%', '').trim() ?? '';
    int safeInt(dynamic v, int fallback) {
      final s = clean(v);
      if (s.isEmpty) return fallback;
      return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? fallback;
    }

    double safeDouble(dynamic v, double fallback) {
      return double.tryParse(clean(v)) ?? fallback;
    }

    // Safely parse integers and doubles
    int p = safeInt(json['present'] ?? json['attended'], 0);
    int a = safeInt(json['absent'], 0);
    int h = safeInt(json['holidays'] ?? json['holiday_days'], 0);
    int o = safeInt(json['outings'] ?? json['outing_days'], 0);
    int l = safeInt(json['leaves'] ?? json['leave_days'], 0);
    int t = safeInt(
      json['total'] ?? json['working_days'] ?? json['total_working_days'],
      (p + a + h + o + l),
    );
    double perc = safeDouble(
      json['percentage'] ?? json['attendance_percentage'],
      t > 0 ? (p / t) * 100 : 0.0,
    );

    List<DayAttendance> synthDetails = [];
    if (json.keys.any((k) => k.startsWith('Day_'))) {
      int sp = 0, sa = 0, sl = 0, sh = 0, sn = 0, so = 0;
      json.forEach((key, value) {
        if (key.startsWith('Day_') && value != null) {
          final dayStr = key.substring(4);
          final status = value.toString().toUpperCase();
          if (status == 'P') {
            sp++;
          } else if (status == 'A') {
            sa++;
          } else if (status == 'L') {
            sl++;
          } else if (status == 'H') {
            sh++;
          } else if (status == 'N' || status == 'NO') {
            sn++;
          } else if (status == 'O') {
            so++;
          } else if (status == 'SO' || status == 'M') {
            // Mapping SO/M to Night Out for now, or could be others
            so++;
          }

          synthDetails.add(
            DayAttendance(
              date:
                  "${json['month_name'] ?? json['month'] ?? json['Month'] ?? ''} $dayStr",
              status: status,
            ),
          );
        }
      });
      // Only override if they were zero/missing
      if (p == 0) p = sp;
      if (a == 0) a = sa;
      if (h == 0) h = sh;
      if (o == 0) o = so;
      if (l == 0) l = sl;
      if (t == 0) t = sp + sa + sl + sh + sn + so;
      if (perc == 0 && t > 0) perc = (p / t) * 100;
    }

    return MonthlyAttendance(
      monthName: (json['month_name'] ?? json['month'] ?? json['Month'] ?? '')
          .toString(),
      present: p,
      absent: a,
      holidays: h,
      outings: o,
      leaves: l,
      total: t,
      percentage: perc,
      details: synthDetails.isNotEmpty ? synthDetails : null,
      rawJson: json,
    );
  }
}

class DayAttendance {
  final String date;
  final String status;

  DayAttendance({required this.date, required this.status});
}
