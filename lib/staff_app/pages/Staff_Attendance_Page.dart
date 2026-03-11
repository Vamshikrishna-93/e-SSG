import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/staff_header.dart';

class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  State<StaffAttendancePage> createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  String query = "";
  String selectedMonth = "Nov - 25";

  // SAMPLE DATA
  final List<Map<String, dynamic>> attendanceData = [
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "presentCount": 18,
      "absentCount": 5,
      "days": ["P", "A", "P", "P", "P", "P", "P"],
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "presentCount": 18,
      "absentCount": 5,
      "days": ["P", "A", "P", "P", "P", "P", "P"],
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "presentCount": 18,
      "absentCount": 5,
      "days": ["P", "A", "P", "P", "P", "P", "P"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = attendanceData.where((s) {
      return s["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          s["id"]!.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const StaffHeader(title: "Staff Attendance"),

              // ================= TITLE & MONTH SELECTOR =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Staff Month Wise",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C69FF).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            selectedMonth,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= MAIN CONTENT =================
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                  padding: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: lavenderBg.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: primaryPurple.withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => query = v),
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.search,
                                color: Colors.black54,
                                size: 20,
                              ),
                              hintText: "Search Staff name / ID",
                              hintStyle: TextStyle(
                                color: Colors.black38,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      // Staff List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemBuilder: (context, index) {
                            return _buildStaffAttendanceCard(filtered[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 80), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ================= BOTTOM ACTIONS =================
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: _buildGradientButton(
                    "Staff Biometric Logs",
                    [Color(0xFF7D74FC), Color(0xFFD08EF7)],
                    () => Get.toNamed('/staffBiometricLogs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGradientButton(
                    "Take Staff Attendance",
                    [Color(0xFF3FAFB9), Color(0xFFAED160)],
                    () => Get.toNamed('/takeStaffAttendance'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAttendanceCard(Map<String, dynamic> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB59CFF),
                radius: 25,
                child: Text(
                  staff['initial'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID:${staff['id']}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Attendance Overview:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(staff['days'].length, (i) {
                final status = staff['days'][i];
                final isPresent = status == "P";
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${i + 1}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? const Color(0xFF66BB6A).withOpacity(0.6)
                              : const Color(0xFFEF5350).withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildSummaryItem(
                const Color(0xFF4DB6AC),
                "Present:",
                staff['presentCount'],
              ),
              const SizedBox(width: 15),
              _buildSummaryItem(
                const Color(0xFFEF5350),
                "Absent:",
                staff['absentCount'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
    String label,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
