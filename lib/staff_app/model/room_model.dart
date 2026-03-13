class RoomModel {
  final int id;
  final String roomName;
  final int capacity;
  final int floorId;
  final int hostelId;
  final int branchId;
  final int incharge;
  final int status;

  RoomModel({
    required this.id,
    required this.roomName,
    required this.capacity,
    required this.floorId,
    required this.hostelId,
    required this.branchId,
    required this.incharge,
    required this.status,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      roomName: json['roomname'] ?? '',
      capacity: json['capacity'] is int
          ? json['capacity']
          : int.parse(json['capacity'].toString()),
      floorId: json['floorid'] is int
          ? json['floorid']
          : int.parse(json['floorid'].toString()),
      hostelId: json['hostelid'] is int
          ? json['hostelid']
          : int.parse(json['hostelid'].toString()),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.parse(json['branch_id'].toString()),
      incharge: json['incharge'] is int
          ? json['incharge']
          : int.parse(json['incharge'].toString()),
      status: json['status'] is int
          ? json['status']
          : int.parse(json['status'].toString()),
    );
  }
}
