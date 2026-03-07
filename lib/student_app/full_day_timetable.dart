import 'package:flutter/material.dart';
import 'package:student_app/student_app/weekly_timetable.dart';

class FullDayTimetablePage extends StatelessWidget {
  const FullDayTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7E49FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  "Full Day Time Table",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimetableItem(
                    subject: "Maths",
                    time: "09:00 - 09:45",
                    instructor: "Mr. Ramesh",
                    color: const Color(0xFF2196F3),
                  ),
                  _buildTimetableItem(
                    subject: "Physics",
                    time: "09:50 - 10:35",
                    instructor: "Ms. Anjali",
                    color: const Color(0xFF00BCD4),
                  ),
                  _buildTimetableItem(
                    subject: "Chemistry",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF2196F3),
                  ),
                  _buildTimetableItem(
                    subject: "English",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF00BCD4),
                  ),
                  _buildTimetableItem(
                    subject: "Chemistry",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF2196F3),
                  ),
                  _buildTimetableItem(
                    subject: "Lunch Break",
                    time: "01:05- 02:00",
                    instructor: "",
                    color: Colors.grey.shade400,
                  ),
                  _buildTimetableItem(
                    subject: "Chemistry",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF2196F3),
                  ),
                  _buildTimetableItem(
                    subject: "English",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF00BCD4),
                  ),
                  _buildTimetableItem(
                    subject: "Chemistry",
                    time: "10:40 - 11:25",
                    instructor: "Dr. Suresh",
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Fixed Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: Colors.black12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyTimetablePage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "View Weekly Time Table",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableItem({
    required String subject,
    required String time,
    required String instructor,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (instructor.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Text(
                              "•",
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              instructor,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
