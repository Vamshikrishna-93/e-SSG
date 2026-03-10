import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/get_storage.dart';
import '../widgets/staff_bottom_nav_bar.dart';
import 'package:student_app/staff_app/pages/profile_page.dart';
import '../api/api_service.dart';
import './student_details_page.dart';
import './add_hostel_members_page.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../utils/iconify_icons.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  late ProfileController profileCtrl;
  String selectedYear = "2025-2026";

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchingInAppBar = false;

  @override
  void initState() {
    super.initState();
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    Get.put(StaffMainController(), permanent: true).changeIndex(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await ApiService.searchStudentByAdmNo(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  final List<String> years = [
    "2023-2024",
    "2024-2025",
    "2025-2026",
    "2026-2027",
  ];

  final List<Map<String, dynamic>> colleges = const [
    {"name": "Pelluru", "present": 75, "absent": 25},
    {"name": "VRB", "present": 65, "absent": 35},
    {"name": "PVB", "present": 75, "absent": 25},
    {"name": "Vidya Bhavan", "present": 75, "absent": 25},
    {"name": "Padmavathi", "present": 65, "absent": 35},
    {"name": "MM Road", "present": 75, "absent": 25},
    {"name": "AVP", "present": 65, "absent": 35},
    {"name": "Tallur", "present": 75, "absent": 25},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6), // Primary Purple
              Color(0xFFC084FC), // Lighter Purple
              Colors.white, // Bottom White
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: _buildDashboardBody(),
      ),
      bottomNavigationBar: const StaffBottomNavBar(),
    );
  }

  // ================= APP BAR =================

  AppBar _buildAppBar(BuildContext context) {
    if (_isSearchingInAppBar) {
      return AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearchingInAppBar = false;
              _searchController.clear();
              _searchResults = [];
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: "Search Admission No...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _handleSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _handleSearch,
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.short_text_rounded, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearchingInAppBar = true;
            });
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          onSelected: (v) async {
            switch (v) {
              case 'profile':
                Get.to(() => const ProfilePage());
                break;
              case 'logout':
                Get.find<AuthController>().logout();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Color(0xFF8B5CF6),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Profile",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(() {
              final p = profileCtrl.profile.value;
              final avatar = p?.avatar ?? "";
              final bool hasValidAvatar =
                  avatar.isNotEmpty && avatar != "avatar.png";

              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white30,
                backgroundImage: hasValidAvatar
                    ? NetworkImage(
                        "https://dev.srisaraswathigroups.in/uploads/$avatar",
                      )
                    : null,
                child: !hasValidAvatar
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }

  // Dashboard Body

  Widget _buildDashboardBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E7FF)],
                  ).createShader(bounds),
                  child: const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => selectedYear = v),
                  itemBuilder: (context) => years
                      .map((y) => PopupMenuItem(value: y, child: Text(y)))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedYear,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            if (_searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      "Found ${_searchResults.length} students",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length > 5
                        ? 5
                        : _searchResults.length,
                    itemBuilder: (context, index) {
                      final student = _searchResults[index];
                      final adm =
                          (student['admno'] ?? student['adm_no'])?.toString() ??
                          '';
                      final name =
                          (student['student_name'] ?? student['name'])
                              ?.toString() ??
                          '';
                      final branch = student['branch_name']?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            Get.to(() => StudentDetailsPage(admissionNo: adm));
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF7C3AED),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            name.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          subtitle: Text(
                            "Adm: $adm | $branch",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            const SizedBox(height: 5),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.9, // Slightly taller to prevent overflow
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                _buildStatCard(
                  "Total Students",
                  "6902",
                  IconifyIcons.humbleIconsUsers,
                  [const Color(0xFF28CDC0), const Color(0xFF2EC0CD)],
                ),
                _buildStatCard(
                  "Day Scholars",
                  "2,047",
                  IconifyIcons.hugeIconsBus,
                  [const Color(0xFFF26FA3), const Color(0xFFCB365B)],
                ),
                _buildStatCard(
                  "Hostel",
                  "4,854",
                  IconifyIcons.clarityBuildingLine,
                  [const Color(0xFFF6AE39), const Color(0xFFF58F36)],
                ),
                _buildStatCard(
                  "Today's Outing",
                  "14",
                  IconifyIcons.tablerUserMinus,
                  [const Color(0xFF29A7ED), const Color(0xFF2986E9)],
                ),
                _buildStatCard(
                  "Today Present",
                  "4,130",
                  IconifyIcons.tablerUserCheck,
                  [const Color(0xFF24BF7A), const Color(0xFF2BB78B)],
                ),
                _buildStatCard(
                  "Today Absent",
                  "772",
                  IconifyIcons.tablerUserX,
                  [const Color(0xFFE23555), const Color(0xFFDD357B)],
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 173 / 105,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildQuickAction(
                  "Class Attendance",
                  IconifyIcons.tablerUserCheck,
                  const Color(0xFF43A089), // Exact teal from mockup
                  () => Get.toNamed('/classAttendance'),
                ),
                _buildQuickAction(
                  "Hostel Attendance",
                  IconifyIcons.tablerCalendarCheck,
                  const Color(0xFFF39C12), // Exact orange from mockup
                  () => Get.toNamed('/hostelAttendanceFilter'),
                ),
                _buildQuickAction(
                  "Issue Outing",
                  IconifyIcons.tablerBackpack,
                  const Color(0xFF26C6DA), // Exact cyan from mockup
                  () => Get.toNamed('/outingList'),
                ),
                _buildQuickAction(
                  "Verify Outing",
                  IconifyIcons.tablerShieldCheck,
                  const Color(0xFFF06292), // Exact pink from mockup
                  () => Get.toNamed('/outingPending'),
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text(
              "Students Attendance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: colleges
                    .map(
                      (c) => _buildAttendanceBar(
                        c["name"],
                        c["present"],
                        c["present"] >= 70
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String iconData,
    List<Color> colors,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12), // Exact 12px radius
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Bubble
          Positioned(
            top: -15,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12), // Exact 12px padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Adjusted for consistency
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Reduced from 24 to prevent overflow
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Icon Container
                Container(
                  width: 44, // Exact 44px width
                  height: 44, // Exact 44px height
                  padding: const EdgeInsets.all(6), // Exact 6px padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Matching icon radius
                  ),
                  child: Iconify(
                    iconData,
                    color: Colors.white,
                    size: 32, // Consistent with quick actions
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String iconData,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25)),
            BoxShadow(color: Colors.white, spreadRadius: 0.0, blurRadius: 8.0),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(iconData, color: iconColor, size: 38),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceBar(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$percentage%",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white,
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER =================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: const Color(0xFFF5F3FF),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                children: [
                  _buildExpandableDrawerItem(
                    icon: IconifyIcons
                        .clarityFormLine, // Form/Exams Icon from Image 1
                    title: "Exams",
                    children: [
                      _buildDrawerSubItem(
                        "Exam Category List",
                        () => Get.toNamed('/examCategoryList'),
                      ),
                      _buildDrawerSubItem(
                        "Exams List",
                        () => Get.toNamed('/examsList'),
                      ),
                      _buildDrawerSubItem(
                        "Student Marks Upload",
                        () => Get.toNamed('/subjectMarksUploadPage'),
                      ),
                    ],
                  ),
                  _buildDrawerPillItem(
                    icon:
                        IconifyIcons.phStudent, // Student Cap Icon from Image 3
                    title: "Pro Admission",
                    onTap: () => Get.toNamed('/proAdmission'),
                  ),
                  _buildExpandableDrawerItem(
                    icon: IconifyIcons
                        .clarityBuildingLine, // Building Icon from Image 2
                    title: "Hostels",
                    children: [
                      _buildDrawerSubItem(
                        "Hostel List",
                        () => Get.toNamed('/hostelList'),
                      ),
                      _buildDrawerSubItem("Rooms", () => Get.toNamed('/rooms')),
                      _buildDrawerSubItem(
                        "Floors",
                        () => Get.toNamed('/floors'),
                      ),
                      _buildDrawerSubItem(
                        "Members",
                        () => Get.toNamed('/hostelMembers'),
                      ),
                      _buildDrawerSubItem(
                        "Add Hostel Members",
                        () => Get.to(() => const AddHostelMembersPage()),
                      ),
                      _buildDrawerSubItem(
                        "Add Hostel",
                        () => Get.toNamed('/addHostel'),
                      ),
                      _buildDrawerSubItem(
                        "Non-Hostel Students",
                        () => Get.toNamed('/nonHostel'),
                      ),
                    ],
                  ),
                  _buildExpandableDrawerItem(
                    icon: IconifyIcons
                        .fluentPeopleSettings20Regular, // HR Gear Icon from Image 4
                    title: "Hr Management",
                    children: [
                      _buildDrawerSubItem(
                        "Staff List",
                        () => Get.toNamed('/staff'),
                      ),
                      _buildDrawerSubItem(
                        "Staff Attendance",
                        () => Get.toNamed('/staffAttendance'),
                      ),
                    ],
                  ),
                  _buildDrawerPillItem(
                    icon:
                        IconifyIcons.phChatDots, // Chat Dots Icon from Image 5
                    title: "Chat",
                    onTap: () => Get.toNamed('/chat'),
                  ),
                  _buildDrawerPillItem(
                    icon: IconifyIcons
                        .phChatDots, // Using chat bubble for communication
                    title: "Communication",
                    onTap: () => Get.toNamed('/communication'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7D74FC), Color(0xFFD08EF7)],
        ),
      ),
      child: Obx(() {
        final p = profileCtrl.profile.value;
        final name = p?.name ?? "";
        final avatar = p?.avatar ?? "";
        final bool hasValidAvatar = avatar.isNotEmpty && avatar != "avatar.png";
        final userId = AppStorage.getUserId();
        final userLogin = p?.userLogin ?? "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar / Logo Circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasValidAvatar
                    ? Image.network(
                        "https://dev.srisaraswathigroups.in/uploads/$avatar",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _avatarFallback(name),
                      )
                    : _avatarFallback(name),
              ),
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              name.isNotEmpty ? name : "Loading...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // User ID — show userLogin if set, else fall back to numeric userId
            Text(
              "User ID :  ${userLogin.isNotEmpty ? userLogin : (userId?.toString() ?? '-')}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _avatarFallback(String name) {
    return Center(
      child: name.isNotEmpty
          ? Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            )
          : const Icon(Icons.person, color: Color(0xFF8B5CF6), size: 32),
    );
  }

  Widget _buildDrawerPillItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Iconify(icon, color: Colors.black, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDrawerItem({
    required String icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Iconify(icon, color: Colors.black, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 22,
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 60, right: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
