import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentAttendanceViewPage extends StatelessWidget {
  const StudentAttendanceViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFF), // Light background for dialog
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: Colors.black, size: 20),
              ),
            ),
            const SizedBox(height: 10),

            // Header Row S M T W T F S
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _HeaderText("S"),
                _HeaderText("M"),
                _HeaderText("T"),
                _HeaderText("W"),
                _HeaderText("T"),
                _HeaderText("F"),
                _HeaderText("S"),
              ],
            ),
            const SizedBox(height: 15),

            // Calendar Grid inside a container with borders
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildCalendarGrid(),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem("Present", const Color(0xFF6DCB9F)),
                  _buildLegendItem("Absent", const Color(0xFFFA7476)),
                  _buildLegendItem("Holiday", const Color(0xFF7B8BBA)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final List<TableRow> rows = [];
    int currentDay = -1; // -1 -> 30, 0 -> 31

    for (int i = 0; i < 5; i++) {
      List<Widget> rowCells = [];
      for (int j = 0; j < 7; j++) {
        String dayStr = "";
        bool isCurrentMonth = false;
        String? status;

        if (currentDay == -1) {
          dayStr = "30";
        } else if (currentDay == 0) {
          dayStr = "31";
        } else if (currentDay <= 31) {
          dayStr = currentDay.toString();
          isCurrentMonth = true;
          status = "P";
          if (currentDay == 18 || currentDay == 23) {
            status = "A";
          } else if (currentDay == 21) {
            status = "H";
          }
        } else {
          dayStr = (currentDay - 31).toString();
        }

        rowCells.add(
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _DayCell(
                day: dayStr,
                isCurrentMonth: isCurrentMonth,
                status: status,
              ),
            ),
          ),
        );
        currentDay++;
      }
      rows.add(TableRow(children: rowCells));
    }

    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
        verticalInside: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      children: rows,
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String day;
  final bool isCurrentMonth;
  final String? status;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCurrentMonth) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: Colors.grey.shade300, // Light grey for next/prev month
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24), // Maintain height matching active days
        ],
      );
    }

    Color bgColor = Colors.transparent;
    if (status == "P") bgColor = const Color(0xFF6DCB9F);
    if (status == "A") bgColor = const Color(0xFFFA7476);
    if (status == "H") bgColor = const Color(0xFF7B8BBA);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          day,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (status != null)
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                status!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
}
