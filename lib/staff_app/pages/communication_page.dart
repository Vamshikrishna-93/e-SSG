import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);

  String selectedFilter = "All";

  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Exam Schedule Announced',
      'desc': 'Exam dates and subjects will be posted tomorrow morning...',
      'type': 'General',
      'date': 'Feb 13, 11:00',
      'by': 'By Admin',
      'badgeColor': const Color(0xFF9E9CFF),
    },
    {
      'title': 'Maintenance Work',
      'desc':
          'There will be urgent maintenance work in the physics lab at 2pm today. the lab will be closed until further notice.',
      'type': 'urgent',
      'date': 'Feb 13, 11:00',
      'by': 'By Admin',
      'badgeColor': const Color(0xFFFF8B9C),
    },
    {
      'title': 'Staff Meeting Reminder',
      'desc': 'All Staff must attend meeting at 3 PM today',
      'type': 'Important',
      'date': 'Feb 12, 01:45',
      'by': 'By Admin',
      'badgeColor': const Color(0xFFEBB060),
    },
    {
      'title': 'Holiday on February 15th',
      'desc': 'Campus will be closed on feb 15th for public holiday',
      'type': 'General',
      'date': 'Feb 13, 11:00',
      'by': 'By Admin',
      'badgeColor': const Color(0xFF9E9CFF),
    },
    {
      'title': 'Exam Schedule Announced',
      'desc': 'Exam dates and subjects will be posted tomorrow morning...',
      'type': 'General',
      'date': 'Feb 13, 11:00',
      'by': 'By Admin',
      'badgeColor': const Color(0xFF9E9CFF),
    },
    {
      'title': 'Staff Meeting Reminder',
      'desc': 'All Staff must attend meeting at 3 PM today',
      'type': 'Important',
      'date': 'Feb 12, 01:45',
      'by': 'By Admin',
      'badgeColor': const Color(0xFFEBB060),
    },
    {
      'title': 'Holiday on February 15th',
      'desc': 'Campus will be closed on feb 15th for public holiday',
      'type': 'General',
      'date': 'Feb 13, 11:00',
      'by': 'By Admin',
      'badgeColor': const Color(0xFF9E9CFF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: "Communication"),

          // ================= SEARCH & FILTERS =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryPurple.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54, size: 20),
                  hintText: "Search exam / category...",
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                _buildFilterChip("All"),
                const SizedBox(width: 10),
                _buildFilterChip("Staff"),
                const SizedBox(width: 10),
                _buildFilterChip("Students"),
              ],
            ),
          ),

          // ================= CONTENT CONTAINER =================
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: lavenderBg.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _announcements.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return _buildAnnouncementCard(_announcements[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple : lavenderBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Text(
            data['title'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['desc'],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data['badgeColor'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['type'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data['date'],
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                data['by'],
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
