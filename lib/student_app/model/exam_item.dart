import 'package:flutter/material.dart';

class ExamModel {
  final String title;
  final String date;
  final String time;
  final String board;
  final double progress;
  final String type;
  final String id;
  final String subject;
  final Color color;
  final String? marks;
  final String? percentage;
  final String? grade;
  final String? rank;
  final String? performance;

  // New fields for the updated UI
  final String? duration;
  final int? questions;
  final String? passingMarks;
  final String? platform;
  final bool isProctored;
  final bool hasWebcam;
  final bool hasInternet;

  const ExamModel({
    required this.title,
    required this.date,
    required this.time,
    required this.board,
    required this.progress,
    required this.type,
    required this.id,
    required this.subject,
    required this.color,
    this.marks,
    this.percentage,
    this.grade,
    this.rank,
    this.performance,
    this.duration,
    this.questions,
    this.passingMarks,
    this.platform,
    this.isProctored = false,
    this.hasWebcam = false,
    this.hasInternet = false,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      title:
          json['examname'] ??
          json['exam_name'] ??
          json['title'] ??
          'Untitled Exam',
      date: json['date'] ?? json['exam_date'] ?? 'N/A',
      time: json['timefrom'] ?? json['exam_time'] ?? json['time'] ?? 'N/A',
      board: json['branch_name'] ?? json['board'] ?? 'N/A',
      progress: (json['exam_submit_status'] == 'Submitted')
          ? 100.0
          : (json['progress'] != null)
          ? double.tryParse(json['progress'].toString()) ?? 0.0
          : 0.0,
      type: (json['exam_type']?.toString() == '1') ? 'Offline' : 'Online',
      id: json['exam_id']?.toString() ?? json['id']?.toString() ?? '',
      subject:
          json['category'] ??
          json['subject_name'] ??
          json['subject'] ??
          'General',
      color: Colors.blue,
      marks: json['total_marks']?.toString() ?? json['marks']?.toString(),
      percentage: json['percentage']?.toString(),
      grade: json['grade'],
      rank: json['rank']?.toString(),
      performance: json['performance'],
      duration: json['duration'],
      questions: json['questions_count'] != null
          ? int.tryParse(json['questions_count'].toString())
          : (json['total_questions'] != null
                ? int.tryParse(json['total_questions'].toString())
                : null),
      passingMarks:
          json['exam_total_marks']?.toString() ?? json['passing_marks'],
      platform: json['platform'],
      isProctored: json['is_proctored'] == 1 || json['is_proctored'] == true,
      hasWebcam: json['has_webcam'] == 1 || json['has_webcam'] == true,
      hasInternet: json['has_internet'] == 1 || json['has_internet'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'exam_name': title,
      'date': date,
      'time': time,
      'board': board,
      'branch_name': board,
      'progress': progress,
      'type': type,
      'exam_type': type,
      'id': id,
      'exam_id': id,
      'subject': subject,
      'marks': marks,
      'total_marks': marks,
      'percentage': percentage,
      'grade': grade,
      'rank': rank,
      'performance': performance,
      'duration': duration,
      'questions': questions,
      'passing_marks': passingMarks,
      'platform': platform,
      'is_proctored': isProctored,
      'has_webcam': hasWebcam,
      'has_internet': hasInternet,
    };
  }

  // ================== UPCOMING EXAMS ==================
  static List<ExamModel> upcomingExams = [
    ExamModel(
      title: "WEEKEND TEST-10",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2026-02-10",
      time: "8:00 PM",
      progress: 0,
      type: "Online",
      id: "589",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
      isProctored: true,
      hasWebcam: true,
      hasInternet: true,
      platform: "Online Exam Portal",
    ),
    ExamModel(
      title: "WEEKEND TEST-09",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 10,
      type: "Online",
      id: "563",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-08",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 55,
      type: "Online",
      id: "587",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-07",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "466",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-06",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 25,
      type: "Online",
      id: "417",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-05",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "398",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-04",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "354",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-03",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "312",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-02",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "288",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
    ExamModel(
      title: "WEEKEND TEST-01",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 0,
      type: "Online",
      id: "256",
      subject: "EAMCET",
      color: Colors.blue,
      duration: "3 hours",
      questions: 160,
      passingMarks: "35%",
    ),
  ];

  // ================== COMPLETED EXAMS ==================
  static List<ExamModel> completedExams = [
    ExamModel(
      title: "weekend Exam",
      board: "EAMCET • SSJC-VIDHYA BHAVAN",
      date: "2024-03-15",
      time: "10:00 AM",
      progress: 100,
      type: "Online",
      id: "696",
      subject: "EAMCET",
      color: Colors.green,
      marks: "15.00",
      percentage: "375.00%",
      grade: "A+",
      rank: "N/A",
      performance: "Outstanding",
      duration: "2 hours",
      questions: 50,
      passingMarks: "35%",
      platform: "Online Exam Portal",
      isProctored: true,
      hasWebcam: true,
      hasInternet: true,
    ),
  ];

  // ================== ONLINE EXAMS ==================
  static List<ExamModel> onlineExams = [
    ExamModel(
      title: "weekend Exam Testing",
      board: "SSJC-VRB CAMPUS",
      date: "2026-02-17",
      time: "17:00:00",
      progress: 100, // Completed as per image
      type: "Online",
      id: "699",
      subject: "General",
      color: Colors.blue,
      duration: "N/A",
      questions: 2,
      passingMarks: "10.00",
      isProctored: false,
      hasWebcam: true,
      hasInternet: true,
      platform: "Online Portal",
    ),
    ExamModel(
      title: "Physics Online Quiz",
      board: "STATE BOARD",
      date: "2024-03-20",
      time: "11:00 AM",
      progress: 0,
      type: "Online",
      id: "702",
      subject: "PHYSICS",
      color: Colors.blue,
      duration: "1 hour",
      questions: 30,
      passingMarks: "40%",
      platform: "Online Exam Portal",
    ),
  ];

  // ================== OFFLINE EXAMS ==================
  static List<ExamModel> offlineExams = [
    ExamModel(
      title: "Physics Lab Internal",
      board: "STATE BOARD",
      date: "2024-04-05",
      time: "02:00 PM",
      progress: 0,
      type: "Offline",
      id: "882",
      subject: "PHYSICS",
      color: Colors.orange,
      duration: "2 hours",
      questions: 0,
      passingMarks: "35%",
    ),
  ];
}
