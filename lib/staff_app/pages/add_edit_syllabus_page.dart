import 'package:flutter/material.dart';
import '../widgets/staff_header.dart';

class AddEditSyllabusPage extends StatefulWidget {
  const AddEditSyllabusPage({super.key});

  @override
  State<AddEditSyllabusPage> createState() => _AddEditSyllabusPageState();
}

class _AddEditSyllabusPageState extends State<AddEditSyllabusPage> {
  final TextEditingController _syllabusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          /// STAFF HEADER
          const StaffHeader(title: "Add/Edit Syllabus - PHY"),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LABEL
                  const Text(
                    "Syllabus Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),

                  const SizedBox(height: 10),

                  /// TEXT AREA
                  Container(
                    height: 160,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: TextField(
                      controller: _syllabusController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: "Enter syllabus details here.....",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// SAVE BUTTON
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B5CFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save Syllabus",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
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
}
