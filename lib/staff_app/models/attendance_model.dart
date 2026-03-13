class AttendanceResponse {
  final bool success;
  final List<StudentAttendance> indexdata;

  AttendanceResponse({required this.success, required this.indexdata});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final successValue = json['success'];
    final bool isSuccess =
        successValue == true || successValue == "true" || successValue == 1;

    final List<dynamic>? listData =
        (json['indexdata'] ?? json['attendanceData']) as List<dynamic>?;

    return AttendanceResponse(
      success: isSuccess,
      indexdata:
          listData
              ?.map(
                (e) => StudentAttendance.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'indexdata': indexdata.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentAttendance {
  final int sid;
  final String sfname;
  final String slname;
  final String admno;
  final String one;
  final String two;
  final String three;
  final String four;
  final String five;
  final String six;
  final String seven;
  final String eight;
  final String nine;
  final String ten;
  final String oneone;
  final String onetwo;
  final String onethree;
  final String onefour;
  final String onefive;
  final String onesix;
  final String oneseven;
  final String oneeight;
  final String onenine;
  final String twozero;
  final String twoone;
  final String twotwo;
  final String twothree;
  final String twofour;
  final String twofive;
  final String twosix;
  final String twoseven;
  final String twoeight;
  final String twonine;
  final String threezero;
  final String threeone;

  StudentAttendance({
    required this.sid,
    required this.sfname,
    required this.slname,
    required this.admno,
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
    required this.six,
    required this.seven,
    required this.eight,
    required this.nine,
    required this.ten,
    required this.oneone,
    required this.onetwo,
    required this.onethree,
    required this.onefour,
    required this.onefive,
    required this.onesix,
    required this.oneseven,
    required this.oneeight,
    required this.onenine,
    required this.twozero,
    required this.twoone,
    required this.twotwo,
    required this.twothree,
    required this.twofour,
    required this.twofive,
    required this.twosix,
    required this.twoseven,
    required this.twoeight,
    required this.twonine,
    required this.threezero,
    required this.threeone,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['sid'] ??
        json['id'] ??
        json['stuid'] ??
        json['stu_id'] ??
        json['student_id'] ??
        json['ID'] ??
        json['SID'] ??
        json['st_id'] ??
        '0';

    final parsedSid = int.tryParse(rawId.toString()) ?? 0;

    // Robust Name Parsing
    final firstName =
        (json['sfname'] ??
                json['student_name'] ??
                json['full_name'] ??
                json['name'] ??
                '')
            .toString();
    final lastName = (json['slname'] ?? '').toString();

    return StudentAttendance(
      sid: parsedSid,
      sfname: firstName,
      slname: lastName,
      admno: (json['admno'] ?? '').toString(),
      one: json['one'] ?? '',
      two: json['two'] ?? '',
      three: json['three'] ?? '',
      four: json['four'] ?? '',
      five: json['five'] ?? '',
      six: json['six'] ?? '',
      seven: json['seven'] ?? '',
      eight: json['eight'] ?? '',
      nine: json['nine'] ?? '',
      ten: json['ten'] ?? '',
      oneone: json['oneone'] ?? '',
      onetwo: json['onetwo'] ?? '',
      onethree: json['onethree'] ?? '',
      onefour: json['onefour'] ?? '',
      onefive: json['onefive'] ?? '',
      onesix: json['onesix'] ?? '',
      oneseven: json['oneseven'] ?? '',
      oneeight: json['oneeight'] ?? '',
      onenine: json['onenine'] ?? '',
      twozero: json['twozero'] ?? '',
      twoone: json['twoone'] ?? '',
      twotwo: json['twotwo'] ?? '',
      twothree: json['twothree'] ?? '',
      twofour: json['twofour'] ?? '',
      twofive: json['twofive'] ?? '',
      twosix: json['twosix'] ?? '',
      twoseven: json['twoseven'] ?? '',
      twoeight: json['twoeight'] ?? '',
      twonine: json['twonine'] ?? '',
      threezero: json['threezero'] ?? '',
      threeone: json['threeone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'sfname': sfname,
      'slname': slname,
      'admno': admno,
      'one': one,
      'two': two,
      'three': three,
      'four': four,
      'five': five,
      'six': six,
      'seven': seven,
      'eight': eight,
      'nine': nine,
      'ten': ten,
      'oneone': oneone,
      'onetwo': onetwo,
      'onethree': onethree,
      'onefour': onefour,
      'onefive': onefive,
      'onesix': onesix,
      'oneseven': oneseven,
      'oneeight': oneeight,
      'onenine': onenine,
      'twozero': twozero,
      'twoone': twoone,
      'twotwo': twotwo,
      'twothree': twothree,
      'twofour': twofour,
      'twofive': twofive,
      'twosix': twosix,
      'twoseven': twoseven,
      'twoeight': twoeight,
      'twonine': twonine,
      'threezero': threezero,
      'threeone': threeone,
    };
  }

  String get fullName => '$sfname $slname';

  // Helper method to get attendance for a specific day
  String getAttendanceForDay(int day) {
    switch (day) {
      case 1:
        return one;
      case 2:
        return two;
      case 3:
        return three;
      case 4:
        return four;
      case 5:
        return five;
      case 6:
        return six;
      case 7:
        return seven;
      case 8:
        return eight;
      case 9:
        return nine;
      case 10:
        return ten;
      case 11:
        return oneone;
      case 12:
        return onetwo;
      case 13:
        return onethree;
      case 14:
        return onefour;
      case 15:
        return onefive;
      case 16:
        return onesix;
      case 17:
        return oneseven;
      case 18:
        return oneeight;
      case 19:
        return onenine;
      case 20:
        return twozero;
      case 21:
        return twoone;
      case 22:
        return twotwo;
      case 23:
        return twothree;
      case 24:
        return twofour;
      case 25:
        return twofive;
      case 26:
        return twosix;
      case 27:
        return twoseven;
      case 28:
        return twoeight;
      case 29:
        return twonine;
      case 30:
        return threezero;
      case 31:
        return threeone;
      default:
        return '';
    }
  }

  // Calculate attendance statistics
  int get totalPresent {
    int count = 0;
    for (int i = 1; i <= 31; i++) {
      if (getAttendanceForDay(i) == 'P') count++;
    }
    return count;
  }

  int get totalAbsent {
    int count = 0;
    for (int i = 1; i <= 31; i++) {
      if (getAttendanceForDay(i) == 'A') count++;
    }
    return count;
  }

  double get attendancePercentage {
    int total = totalPresent + totalAbsent;
    if (total == 0) return 0.0;
    return (totalPresent / total) * 100;
  }
}
