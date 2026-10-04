import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/branch_model.dart';

class BranchServiceException implements Exception {
  final String message;
  BranchServiceException(this.message);
  @override
  String toString() => message;
}

class BranchService {
  final _client = SupabaseService.client;

  Future<List<BranchModel>> fetchBranches() async {
    try {
      final List<Map<String, dynamic>> data = await _client
          .from(AppConstants.tableBranches)
          .select()
          .eq('is_active', true)
          .order('name');
      return data.map(BranchModel.fromJson).toList();
    } catch (e) {
      throw BranchServiceException('Unable to load branches: $e');
    }
  }

  Future<void> createBranch({
    required String name,
    required String location,
    required String code,
  }) async {
    try {
      await _client.from(AppConstants.tableBranches).insert({
        'name': name,
        'location': location,
        'code': code.toUpperCase(),
        'is_active': true,
      });
    } catch (e) {
      throw BranchServiceException('Unable to create branch: $e');
    }
  }

  Future<void> assignUserToBranch({
    required String userId,
    required String branchId,
  }) async {
    try {
      await _client
          .from(AppConstants.tableProfiles)
          .update({'branch_id': branchId})
          .eq('id', userId);
    } catch (e) {
      throw BranchServiceException('Unable to assign branch: $e');
    }
  }
}