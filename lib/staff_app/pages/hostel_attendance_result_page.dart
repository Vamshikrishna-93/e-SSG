import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hostel_controller.dart';
import '../widgets/skeleton.dart';
import 'hostel_attendance_mark_page.dart';
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
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.grey, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Search floor / hostel',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
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
                          hostelCtrl: hostelCtrl,
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

class _AttendanceCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final int sno;
  final HostelController hostelCtrl;

  const _AttendanceCard({
    required this.row,
    required this.sno,
    required this.hostelCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final roomName = row['room']?.toString() ?? '-';
    final roomId = row['room_id']?.toString() ?? row['room']?.toString() ?? '';
    final floorName = row['floor']?.toString() ?? '-';
    final incharge = row['incharge']?.toString() ?? 'N/A';
    final total = int.tryParse(row['total']?.toString() ?? '0') ?? 0;
    final present = int.tryParse(row['present']?.toString() ?? '0') ?? 0;
    final absent =
        int.tryParse(
          row['absent']?.toString() ?? row['total']?.toString() ?? '0',
        ) ??
        (total - present);

    final date = hostelCtrl.activeDate.value.isNotEmpty
        ? hostelCtrl.activeDate.value
        : DateTime.now().toIso8601String().split('T').first;

    return GestureDetector(
      onTap: () => Get.to(
        () => const HostelAttendanceMarkPage(),
        arguments: {
          'room_name': roomName,
          'room_id': roomId,
          'floor_name': floorName,
          'date': date,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S.NO: $sno',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    roomName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 15),
            _buildRichInfo('Floor : ', floorName),
            const SizedBox(height: 8),
            _buildRichInfo('Incharge : ', incharge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Badge(
                  icon: Icons.group,
                  label: 'Total: $total',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(width: 8),
                _Badge(
                  icon: Icons.check_circle_rounded,
                  label: 'Present: $present',
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                _Badge(
                  icon: Icons.cancel_rounded,
                  label: 'Absent: $absent',
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichInfo(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 15),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
