import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'syllabus_details_page.dart';
import 'add_edit_syllabus_page.dart';
import '../widgets/staff_header.dart';

class ManageSyllabusPage extends StatefulWidget {
  const ManageSyllabusPage({super.key});

  @override
  State<ManageSyllabusPage> createState() => _ManageSyllabusPageState();
}

class _ManageSyllabusPageState extends State<ManageSyllabusPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          StaffHeader(
            title: "Manage Syllabus",
            onBack: () {
              Get.back();
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SUMMARY TITLE
                  const Text(
                    "Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// SUMMARY CARD
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _summaryRow("Exam", "INC SR MAINS-02"),
                        _summaryRow("Branch", "SSJC-SSG EAMCET CAMPUS"),
                        _summaryRow("Batch", "SS-SR-SM1"),
                        _summaryRow("Course", "MAINS"),
                        _summaryRow("Group", "SR MPC"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PURPLE CONTAINER
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        /// SEARCH BAR
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF7B5CFF)),
                            color: Colors.white,
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                              hintText: "Type a Keyword.....",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// SUBJECT CARD
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "S.NO: 1",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const Divider(),

                              _subjectRow("Subject", "Maths"),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Text(
                                    "Status : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF2DE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Not Added",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Text(
                                    "Actions : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  InkWell(
                                    onTap: () {
                                      Get.to(() => const AddEditSyllabusPage());
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  InkWell(
                                    onTap: () {
                                      Get.to(() => const SyllabusDetailsPage());
                                    },
                                    child: const Icon(
                                      Icons.menu_book,
                                      color: Colors.indigo,
                                      size: 20,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "$title :",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _subjectRow(String title, String value) {
    return Row(
      children: [
        Text("$title : ", style: const TextStyle(fontWeight: FontWeight.bold)),

        Text(value),
      ],
    );
  }
}
