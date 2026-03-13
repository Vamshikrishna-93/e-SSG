import 'package:get/get.dart';
import '../api/api_service.dart';
import '../model/hostel_model.dart';
import '../model/hostel_student_model.dart';
import '../model/room_attendance_model.dart';
import '../model/hostel_grid_model.dart';
import '../model/floor_model.dart';
import '../model/room_model.dart';

class HostelController extends GetxController {
  var isLoading = false.obs;

  var hostels = <HostelModel>[].obs;
  var selectedHostel = Rxn<HostelModel>();
  var floorModels = <FloorModel>[].obs;
  var roomModels = <RoomModel>[].obs;

  // DYNAMIC FILTER DATA
  var members = <Map<String, dynamic>>[].obs;
  var floors = <String>[].obs;
  var rooms = <String>[].obs;
  var roomsList = <Map<String, dynamic>>[].obs;

  // DATA FOR RESULTS PAGE
  var roomsSummary = <Map<String, dynamic>>[].obs;
  var roomAttendanceDetails = <RoomAttendanceModel>[].obs;
  var hostelGrid = <HostelGridModel>[].obs;

  // STUDENTS FOR MARKING PAGE
  var roomStudents = <HostelStudentModel>[].obs;

  // ACTIVE FILTERS (Stored for navigation)
  var activeBranch = "".obs;
  var activeHostel = "".obs;
  var activeFloor = "".obs;
  var activeDate = "".obs;

  Future<void> loadRoomStudents({
    required String shift,
    required String date,
    required String roomId,
  }) async {
    try {
      isLoading(true);
      roomStudents.clear();
      final data = await ApiService.getRoomStudentsAttendance(
        shift: shift,
        date: date,
        param: roomId,
      );

      // ✅ FALLBACK: If API returns empty, get from `members`
      if (data.isEmpty && members.isNotEmpty) {
        final filtered = members
            .where((m) => m['room']?.toString() == roomId)
            .toList();
        final models = filtered
            .map((e) => HostelStudentModel.fromJson(e))
            .toList();
        roomStudents.assignAll(models);
      } else {
        roomStudents.assignAll(data);
      }
    } catch (e) {
      print("LOAD STUDENTS ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadHostelsByBranch(int branchId) async {
    try {
      isLoading(true);
      hostels.clear();
      selectedHostel.value = null;
      floors.clear();
      rooms.clear();

      final rawList = await ApiService.getHostelsByBranch(branchId);
      final parsed = rawList.map((e) => HostelModel.fromJson(e)).toList();

      hostels.assignAll(parsed);
    } catch (e) {
      print("HOSTEL CONTROLLER ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadFloorsByHostel(int hostelId) async {
    try {
      isLoading(true);
      floorModels.clear();
      roomModels.clear();
      final data = await ApiService.getFloorsByHostel(hostelId);
      floorModels.assignAll(data.map((e) => FloorModel.fromJson(e)).toList());
    } catch (e) {
      print("LOAD FLOORS ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadRoomsByFloor(int floorId) async {
    try {
      isLoading(true);
      roomModels.clear();
      final data = await ApiService.getRoomsByFloor(floorId);
      roomModels.assignAll(data.map((e) => RoomModel.fromJson(e)).toList());
    } catch (e) {
      print("LOAD ROOMS ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Extracts unique floors and rooms for a hostel
  Future<void> loadFloorsAndRooms(int hostelId) async {
    try {
      isLoading(true);
      floors.clear();
      rooms.clear();
      members.clear();

      // Fetch all members for this hostel to extract structure
      final data = await ApiService.getHostelMembers(
        type: 'hostel',
        param: hostelId.toString(),
      );

      members.assignAll(data);

      final Set<String> fSet = {};
      final Set<String> rSet = {};

      for (final m in data) {
        final f = m['floor_name']?.toString() ?? m['floor']?.toString();
        final r = m['room_name']?.toString() ?? m['room']?.toString();
        if (f != null) fSet.add(f);
        if (r != null) rSet.add(r);
      }

      floors.assignAll(fSet.toList()..sort());
      rooms.assignAll(rSet.toList()..sort());
    } catch (e) {
      print("LOAD STRUCTURE ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  String getFloorIdFromName(String floorName) {
    if (members.isEmpty) return floorName;
    final m = members.firstWhereOrNull(
      (e) =>
          (e['floor_name']?.toString() ?? e['floor']?.toString()) == floorName,
    );
    return m?['floor_id']?.toString() ?? m?['floor']?.toString() ?? floorName;
  }

  /// Helper to get Room ID from Name
  String getRoomIdFromName(String roomName) {
    if (members.isEmpty) return roomName;
    final m = members.firstWhereOrNull(
      (e) => (e['room_name']?.toString() ?? e['room']?.toString()) == roomName,
    );
    return m?['room_id']?.toString() ?? m?['room']?.toString() ?? roomName;
  }

  void filterRoomsByFloor(String floorName) {
    if (members.isEmpty) return;

    final Set<String> rSet = {};
    for (final m in members) {
      if (m['floor'].toString() == floorName && m['room'] != null) {
        rSet.add(m['room'].toString());
      }
    }
    rooms.assignAll(rSet.toList()..sort());
  }

  /// Load summary for result page
  Future<void> loadRoomAttendanceSummary({
    required String branch,
    required String date,
    required String hostel,
    required String floor,
    required String room,
  }) async {
    try {
      isLoading(true);
      roomsSummary.clear();

      print(
        "LOADING ROOM SUMMARY: branch=$branch, date=$date, hostel=$hostel, floor=$floor, room=$room",
      );

      final data = await ApiService.getRoomsAttendanceSummary(
        branch: branch,
        date: date,
        hostel: hostel,
        floor: floor,
        room: room,
      );

      print("ROOM SUMMARY API DATA: ${data.length} rooms found");
      if (data.isEmpty && members.isNotEmpty) {
        print("ROOM SUMMARY API RETURNED EMPTY - USING LOCAL FALLBACK");
        // Filter members based on selection
        final filteredMembers = members.where((m) {
          final mFloor = m['floor']?.toString() ?? '';
          final mRoom = m['room']?.toString() ?? '';

          final floorMatch = floor == 'All' || floor == mFloor;
          final roomMatch = room == 'All' || room == mRoom;

          return floorMatch && roomMatch;
        }).toList();

        // Group by room
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final m in filteredMembers) {
          final rName = m['room']?.toString() ?? 'Unknown';
          if (!grouped.containsKey(rName)) {
            grouped[rName] = [];
          }
          grouped[rName]!.add(m);
        }

        // Create summary list
        final List<Map<String, dynamic>> localSummary = [];
        grouped.forEach((roomName, students) {
          localSummary.add({
            'room': roomName,
            'floor': students.first['floor']?.toString() ?? '',
            'total': students.length,
            'present': 0, // Default to 0 as we don't have this data
            'absent': students.length,
            'incharge': 'N/A',
          });
        });

        // Sort by room name
        localSummary.sort(
          (a, b) => (a['room'] as String).compareTo(b['room'] as String),
        );

        roomsSummary.assignAll(localSummary);
      } else {
        roomsSummary.assignAll(data);
      }

      activeBranch.value = branch;
      activeHostel.value = hostel;
      activeFloor.value = floor;
      activeDate.value = date;
    } catch (e) {
      print("LOAD SUMMARY ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Submit marked attendance
  Future<bool> submitAttendance({
    required String branchId,
    required String hostel,
    required String floor,
    required String room,
    required String shift,
    required List<int> sidList,
    required List<String> statusList,
  }) async {
    try {
      isLoading(true);
      await ApiService.storeHostelAttendance(
        branchId: branchId,
        hostel: hostel,
        floor: floor,
        room: room,
        shift: shift,
        sidList: sidList,
        statusList: statusList,
      );
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRoomsByFloor(int floorId) async {
    // Legacy method, keeping for compatibility if used elsewhere, 
    // but the view now uses loadRoomsByFloor with models.
    try {
      isLoading(true);
      roomsList.clear();
      final data = await ApiService.getRoomsByFloor(floorId);
      roomsList.assignAll(data);
    } catch (e) {
      print("FETCH ROOMS BY FLOOR ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadRoomAttendanceDetails(String roomId) async {
    try {
      isLoading(true);
      roomAttendanceDetails.clear();
      final data = await ApiService.getRoomAttendanceDetails(roomId: roomId);
      roomAttendanceDetails.assignAll(data);
    } catch (e) {
      print("LOAD ROOM ATTENDANCE ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadHostelGrid(int sid) async {
    try {
      isLoading(true);
      hostelGrid.clear();
      final data = await ApiService.getHostelAttendanceGrid(sid);
      hostelGrid.assignAll(data);
    } catch (e) {
      print("LOAD HOSTEL GRID ERROR: $e");
    } finally {
      isLoading(false);
    }
  }
}
