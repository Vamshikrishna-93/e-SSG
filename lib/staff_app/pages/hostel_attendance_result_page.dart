import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../widgets/skeleton.dart';

import '../widgets/staff_header.dart';

class HostelAttendanceResultPage extends StatefulWidget {
  const HostelAttendanceResultPage({super.key});

  @override
  State<HostelAttendanceResultPage> createState() =>
      _HostelAttendanceResultPageState();
}

class _HostelAttendanceResultPageState
    extends State<HostelAttendanceResultPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  late final HostelController hostelCtrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HostelController>()) {
      Get.put(HostelController(), permanent: true);
    }
    hostelCtrl = Get.find<HostelController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    final Map<String, dynamic> args =
        Get.arguments as Map<String, dynamic>? ?? {};
    await hostelCtrl.loadRoomAttendanceSummary(
      branch:
          args['branch']?.toString() ??
          hostelCtrl.activeBranch.value.toString(),
      date: args['date'] ?? hostelCtrl.activeDate.value,
      hostel:
          args['hostel']?.toString() ??
          hostelCtrl.activeHostel.value.toString(),
      floor: args['floor']?.toString() ?? 'All',
      room: args['room']?.toString() ?? 'All',
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StaffHeader(title: 'Hostel Attendance'),

          // ── BODY LAVENDER CONTAINER ──────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF), // Soft Lavender
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // ── SEARCH BAR ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF7C3AED),
                          width: 1,
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
                        controller: _searchCtrl,
                        onChanged: (val) {
                          setState(() {
                            _query = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search floor / hostel',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ── LIST ───────────────────────────────────────
                  Expanded(
                    child: Obx(() {
                      if (hostelCtrl.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: SkeletonList(itemCount: 5),
                        );
                      }

                      // Dynamic data with Fallback to Image Data if empty
                      final List<Map<String, dynamic>> data =
                          hostelCtrl.roomsSummary.isNotEmpty
                          ? List<Map<String, dynamic>>.from(
                              hostelCtrl.roomsSummary,
                            )
                          : [
                              {
                                'room': 'C-201',
                                'floor': '2nd floor C & D blocks',
                                'incharge': 'Gosu Abhishek Sagar',
                                'total': '8',
                                'present': '0',
                                'absent': '8',
                              },
                              {
                                'room': 'C-201',
                                'floor': '2nd floor C & D blocks',
                                'incharge': 'Gosu Abhishek Sagar',
                                'total': '8',
                                'present': '0',
                                'absent': '8',
                              },
                              {
                                'room': 'C-201',
                                'floor': '2nd floor C & D blocks',
                                'incharge': 'Gosu Abhishek Sagar',
                                'total': '8',
                                'present': '0',
                                'absent': '8',
                              },
                            ];

                      final q = _query.toLowerCase();
                      final filtered = data.where((row) {
                        final room =
                            row['room']?.toString().toLowerCase() ?? '';
                        final floor =
                            row['floor']?.toString().toLowerCase() ?? '';
                        final incharge =
                            row['incharge']?.toString().toLowerCase() ?? '';
                        return q.isEmpty ||
                            room.contains(q) ||
                            floor.contains(q) ||
                            incharge.contains(q);
                      }).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _AttendanceCard(
                          row: filtered[index],
                          sno: index + 1,
                        ),
                      );
                    }),
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

class _AttendanceCard extends StatefulWidget {
  final Map<String, dynamic> row;
  final int sno;

  const _AttendanceCard({
    required this.row,
    required this.sno,
    super.key,
  });

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  String morningStatus = 'P';
  String nightStatus = 'P';

  @override
  Widget build(BuildContext context) {
    final roomName = widget.row['room']?.toString() ?? '-';
    final floorName = widget.row['floor']?.toString() ?? '-';
    final incharge = widget.row['incharge']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER: Room Name ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED), // Theme Purple
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              roomName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // ── BODY ──────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                // LEFT COLUMN: Floor and Incharge
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelValue('floor:', floorName),
                        const SizedBox(height: 8),
                        _buildLabelValue('Incharge:', incharge),
                      ],
                    ),
                  ),
                ),

                // VERTICAL DIVIDER
                Container(
                  width: 1,
                  color: Colors.grey.withOpacity(0.15),
                ),

                // RIGHT COLUMN: Morning and Night Status
                Container(
                  width: 105,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'morning',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBox(
                        text: morningStatus,
                        color: morningStatus == 'P' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        onTap: () {
                          setState(() {
                            morningStatus = morningStatus == 'P' ? 'A' : 'P';
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'night',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBox(
                        text: nightStatus,
                        color: nightStatus == 'P' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        onTap: () {
                          setState(() {
                            nightStatus = nightStatus == 'P' ? 'A' : 'P';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _StatusBox({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}




