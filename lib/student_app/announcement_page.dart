import 'package:flutter/material.dart';
import 'package:student_app/student_app/widgets/student_app_header.dart';
import 'model/anouncement.dart';

class AnnouncementsDialog extends StatefulWidget {
  const AnnouncementsDialog({super.key});

  @override
  State<AnnouncementsDialog> createState() => _AnnouncementsDialogState();
}

class _AnnouncementsDialogState extends State<AnnouncementsDialog> {
  final int itemsPerPage = 8; // Adjust to match image better
  int currentPage = 1;

  late final List<Announcement> announcements;

  @override
  void initState() {
    super.initState();

    announcements = [
      Announcement(
        message:
            "Unit Test-2 will be conducted from 22nd July. Students are advised to prepare accordingly",
        department: "Academic Office",
        color: const Color(0xFF2196F3),
      ),
      Announcement(
        message:
            "Hostel students must return to campus before 8:00 PM during weekdays",
        department: "Academic Office",
        color: const Color(0xFF00BCD4),
      ),
      Announcement(
        message:
            "Unit Test-2 will be conducted from 22nd July. Students are advised to prepare accordingly",
        department: "Academic Office",
        color: const Color(0xFF2196F3),
      ),
      Announcement(
        message:
            "Hostel students must return to campus before 8:00 PM during weekdays",
        department: "Academic Office",
        color: const Color(0xFF00BCD4),
      ),
      Announcement(
        message:
            "Unit Test-2 will be conducted from 22nd July. Students are advised to prepare accordingly",
        department: "Academic Office",
        color: const Color(0xFF2196F3),
      ),
      Announcement(
        message:
            "Hostel students must return to campus before 8:00 PM during weekdays",
        department: "Academic Office",
        color: const Color(0xFF00BCD4),
      ),
      Announcement(
        message:
            "Unit Test-2 will be conducted from 22nd July. Students are advised to prepare accordingly",
        department: "Academic Office",
        color: const Color(0xFF2196F3),
      ),
      Announcement(
        message:
            "Hostel students must return to campus before 8:00 PM during weekdays",
        department: "Academic Office",
        color: const Color(0xFF00BCD4),
      ),
      Announcement(
        message: "Sports practice will resume from Monday evening.",
        department: "Sports Department",
        color: Colors.green,
      ),
      Announcement(
        message: "Library will remain open till 9:00 PM during exams.",
        department: "Library",
        color: Colors.blue,
      ),
      Announcement(
        message: "Bus routes revised effective immediately.",
        department: "Transport Office",
        color: Colors.teal,
      ),
      Announcement(
        message:
            "Scholarship application deadline extended till 30th of this month.",
        department: "Accounts Office",
        color: Colors.amber,
      ),
      Announcement(
        message:
            "All students must carry their ID cards starting from next week.",
        department: "Security Office",
        color: Colors.red,
      ),
      Announcement(
        message:
            "Computer lab will be closed for maintenance on Tuesday and Wednesday.",
        department: "Computer Department",
        color: Colors.cyan,
      ),
      Announcement(
        message: "Cultural fest registrations close tomorrow.",
        department: "Cultural Committee",
        color: Colors.purple,
      ),
      Announcement(
        message: "Hostel inspections scheduled this weekend.",
        department: "Hostel Office",
        color: Colors.orange,
      ),
      Announcement(
        message: "Fee payment portal will be unavailable tonight.",
        department: "Accounts Office",
        color: Colors.indigo,
      ),
      Announcement(
        message: "Alumni meet registrations are now open.",
        department: "Alumni Cell",
        color: Colors.green,
      ),
    ];
  }

  int get totalPages => (announcements.length / itemsPerPage).ceil();

  List<Announcement> get pageData {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, announcements.length);
    return announcements.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple Header
          const StudentAppHeader(title: "Announcements"),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "All Announcements(${announcements.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Announcements List
                  ...List.generate(
                    pageData.length,
                    (index) => AnnouncementCard(item: pageData[index]),
                  ),

                  const SizedBox(height: 10),

                  // Pagination Info
                  Center(
                    child: Text(
                      "Page $currentPage of $totalPages", // Static text as in image, but could be dynamic
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "Showing ${(currentPage - 1) * itemsPerPage + 1}-${((currentPage - 1) * itemsPerPage + pageData.length)} of ${announcements.length} announcements",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Pagination Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: currentPage > 1
                                ? const Color(0xFF7E3FF2)
                                : const Color(
                                    0xFFF3F1FF,
                                  ), // Light purple background
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Text(
                            "Previous",
                            style: TextStyle(
                              color: currentPage > 1
                                  ? Colors.white
                                  : Colors.white70, // Disabled look in image
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(height: 25, width: 1, color: Colors.black12),
                      const SizedBox(width: 15),
                      ...List.generate(totalPages, (index) {
                        final page = index + 1;
                        final isActive = page == currentPage;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: GestureDetector(
                            onTap: () => setState(() => currentPage = page),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF7E3FF2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "$page",
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 15),
                      Container(height: 25, width: 1, color: Colors.black12),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: currentPage < totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: currentPage < totalPages
                                ? const Color(0xFF7E3FF2)
                                : const Color(0xFFF3F1FF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                              color: currentPage < totalPages
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement item;

  const AnnouncementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.volume_up, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.department,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
