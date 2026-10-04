import 'package:flutter/foundation.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

class BranchProvider extends ChangeNotifier {
  final BranchService _service = BranchService();

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _isLoading = false;
  String? _errorMessage;

  List<BranchModel> get branches => _branches;
  BranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBranches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _branches = await _service.fetchBranches();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectBranch(BranchModel? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> createBranch({
    required String name,
    required String location,
    required String code,
  }) async {
    try {
      await _service.createBranch(
        name: name,
        location: location,
        code: code,
      );
      await loadBranches();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}