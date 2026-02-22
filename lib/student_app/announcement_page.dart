import 'package:flutter/material.dart';
import 'package:student_app/theme_controllers.dart';
import 'model/anouncement.dart';

class AnnouncementsDialog extends StatefulWidget {
  const AnnouncementsDialog({super.key});

  @override
  State<AnnouncementsDialog> createState() => _AnnouncementsDialogState();
}

class _AnnouncementsDialogState extends State<AnnouncementsDialog> {
  final int itemsPerPage = 10;
  int currentPage = 1;

  late final List<Announcement> announcements;

  @override
  void initState() {
    super.initState();

    announcements = [
      Announcement(
        message:
            "Unit Test-2 will be conducted from 22nd July.\nStudents are advised to prepare accordingly.",
        department: "Academic Office",
        color: Colors.blue,
      ),
      Announcement(
        message:
            "Hostel students must return to campus before 8:00 PM during weekdays.",
        department: "Hostel Warden",
        color: Colors.cyan,
      ),
      Announcement(
        message:
            "Tomorrow is a holiday on account of local festival celebrations.",
        department: "Administration",
        color: Colors.green,
      ),
      Announcement(
        message:
            "All students should submit their assignment files by Friday without fail.",
        department: "English Department",
        color: Colors.amber,
      ),
      Announcement(
        message: "Parents–Teachers meeting scheduled on Saturday at 10:00 AM.",
        department: "Sports Department",
        color: Colors.red,
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
    return ThemeControllerWrapper(
      themeController: StudentThemeController.themeMode,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Back Button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    tooltip: "Back",
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "All Announcements (${announcements.length})",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: List.generate(
                                  pageData.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: AnnouncementCard(
                                      item: pageData[index],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Page $currentPage of $totalPages\n"
                                    "Showing ${(currentPage - 1) * itemsPerPage + 1}"
                                    "-${((currentPage - 1) * itemsPerPage + pageData.length)} "
                                    "of ${announcements.length} announcements",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: currentPage > 1
                                            ? () =>
                                                  setState(() => currentPage--)
                                            : null,
                                        icon: const Icon(
                                          Icons.chevron_left,
                                          size: 18,
                                        ),
                                        label: const Text("Previous"),
                                      ),
                                      Row(
                                        children: List.generate(totalPages, (
                                          index,
                                        ) {
                                          final page = index + 1;
                                          final isActive = page == currentPage;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => currentPage = page,
                                              ),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? const Color(0xFF2563EB)
                                                      : theme.cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF2563EB,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "$page",
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF2563EB,
                                                          ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: currentPage < totalPages
                                            ? () =>
                                                  setState(() => currentPage++)
                                            : null,
                                        label: const Text("Next"),
                                        icon: const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        top: BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement item;

  const AnnouncementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.campaign, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      size: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.department,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
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
