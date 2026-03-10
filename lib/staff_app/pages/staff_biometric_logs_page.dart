import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class StaffBiometricLogsPage extends StatefulWidget {
  const StaffBiometricLogsPage({super.key});

  @override
  State<StaffBiometricLogsPage> createState() => _StaffBiometricLogsPageState();
}

class _StaffBiometricLogsPageState extends State<StaffBiometricLogsPage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  String query = "";
  String selectedDepartment = "All Departments";
  String selectedDateRange = "Nov 02 - 25";

  // SAMPLE DATA
  final List<Map<String, dynamic>> logData = [
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "entrance": "8:00 AM",
      "entranceStatus": "On Time",
      "exit": "12:30 PM",
      "exitStatus": "Early Exit",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "entrance": "8:00 AM",
      "entranceStatus": "On Time",
      "exit": "12:30 PM",
      "exitStatus": "Early Exit",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "entrance": "8:00 AM",
      "entranceStatus": "On Time",
      "exit": "12:30 PM",
      "exitStatus": "Early Exit",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "entrance": "8:00 AM",
      "entranceStatus": "On Time",
      "exit": "12:30 PM",
      "exitStatus": "Early Exit",
    },
    {
      "id": "666980",
      "name": "A.ANJANNEYULU",
      "initial": "B",
      "department": "Accountant",
      "entrance": "8:00 AM",
      "entranceStatus": "On Time",
      "exit": "12:30 PM",
      "exitStatus": "Early Exit",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Staff Biometric Logs"),

          // ================= STAFF LOGS & DATE =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Staff Logs",
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
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedDateRange,
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

          // ================= DEPARTMENT SELECTOR =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Department",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDepartment,
                      isExpanded: true,
                      items: [selectedDepartment].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 15, 16, 0),
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

                  // Staff Logs List
                  Expanded(
                    child: ListView.builder(
                      itemCount: logData.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemBuilder: (context, index) {
                        return _buildStaffLogCard(logData[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  log['initial'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID:${log['id']}  (Department:${log['department']})",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Entrance Row
          Row(
            children: [
              const Icon(Icons.login, color: Color(0xFF66BB6A), size: 18),
              const SizedBox(width: 10),
              const Text(
                "Entrance : ",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                log['entrance'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Spacer(),
              _buildStatusBadge(log['entranceStatus'], const Color(0xFF66BB6A)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 8),

          // Exit Row
          Row(
            children: [
              const Icon(Icons.logout, color: Color(0xFFEF5350), size: 18),
              const SizedBox(width: 10),
              const Text(
                "Exit : ",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                log['exit'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Spacer(),
              _buildStatusBadge(log['exitStatus'], const Color(0xFFFFB74D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
