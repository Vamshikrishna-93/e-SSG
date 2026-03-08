import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'assign_incharge_page.dart';
import 'add_room_page.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  String _query = '';

  // ================= UI Constants =================
  static const Color primaryPurple = Color(0xFF7E49FF);
  static const Color lavenderBg = Color(0xFFF1F4FF);
  static const Color cardPurple = Color(0xFF8A5CF5);
  static const Color badgeBlue = Color(0xFFD7E5FF);

  // ROOM DATA
  final List<Map<String, String>> _rooms = [
    {
      'room': 'G3',
      'category': 'Girls Hostel',
      'phone': '91776162696',
      'floor': 'Ground Floor',
      'hostel': 'SSG EAMCET CAMPUS',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
    },
    {
      'room': 'G3',
      'category': 'Girls Hostel',
      'phone': '91776162696',
      'floor': 'Ground Floor',
      'hostel': 'SSG EAMCET CAMPUS',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
    },
    {
      'room': 'G3',
      'category': 'Girls Hostel',
      'phone': '91776162696',
      'floor': 'Ground Floor',
      'hostel': 'SSG EAMCET CAMPUS',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
    },
    {
      'room': 'G3',
      'category': 'Girls Hostel',
      'phone': '91776162696',
      'floor': 'Ground Floor',
      'hostel': 'SSG EAMCET CAMPUS',
      'branch': 'SSJC-SSG EAMCET CAMPUS',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _rooms.where((r) {
      final searchLower = _query.toLowerCase();
      return r['room']!.toLowerCase().contains(searchLower) ||
          r['floor']!.toLowerCase().contains(searchLower) ||
          r['hostel']!.toLowerCase().contains(searchLower);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= CUSTOM HEADER =================
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Rooms List",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ================= SEARCH BAR =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryPurple.withOpacity(0.5)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  hintText: "Search room / floor / hostel",
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lavenderBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, i) => _roomCard(context, filtered[i]),
              ),
            ),
          ),

          // ================= BOTTOM BUTTONS =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _gradientButton(
                    onTap: () => Get.to(() => const AssignInchargePage()),
                    colors: [const Color(0xFFA590FF), const Color(0xFFD3A4FF)],
                    icon: Icons.check_circle_outline,
                    label: "Assign Incharge",
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _gradientButton(
                    onTap: () => Get.to(() => const AddRoomPage()),
                    colors: [const Color(0xFF46B7B9), const Color(0xFF9BD471)],
                    icon: Icons.add,
                    label: "Add New Room",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent
            Container(
              width: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF818CF8), // Specific purple from image
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cardPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data['room']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['category']!,
                            style: const TextStyle(
                              color: Color(0xFF5A7DC6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color(0xFF5A7DC6),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data['phone']!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    _infoRow("Floor", data['floor']!),
                    const SizedBox(height: 6),
                    _infoRow("Hostel", data['hostel']!),
                    const SizedBox(height: 6),
                    _infoRow("Branch", data['branch']!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(
            text: "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required VoidCallback onTap,
    required List<Color> colors,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
