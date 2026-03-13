import 'package:get/get.dart';

import 'package:student_app/staff_app/api/api_collection.dart';
import 'package:student_app/staff_app/api/api_service.dart';
import 'package:student_app/staff_app/model/branch_model.dart';

class BranchController extends GetxController {
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<BranchModel> selectedBranch = Rxn<BranchModel>();

  Future<void> loadBranches({String? branchName}) async {
    try {
      isLoading.value = true;
      branches.clear();

      String url = ApiCollection.branchList;

      // Optional filter
      if (branchName != null && branchName.isNotEmpty) {
        final encoded = Uri.encodeQueryComponent(branchName);
        url = "$url?branch_name=$encoded";
      }

      final res = await ApiService.getRequest(url);

      final success = res["success"] == true || res["success"] == "true";

      if (success && res["indexdata"] != null) {
        branches.value = (res["indexdata"] as List)
            .map((e) => BranchModel.fromJson(e))
            .toList();
      } else {
        branches.clear();
        Get.snackbar("Info", "No branches found");
      }
    } catch (e) {
      branches.clear();
      Get.snackbar("Error", "Failed to load branches");
    } finally {
      isLoading.value = false;
    }
  }
}
