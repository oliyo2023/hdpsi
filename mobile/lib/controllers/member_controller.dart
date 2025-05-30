import 'package:get/get.dart';
import '../models/member.dart';
import '../services/member_service.dart';
import '../utils/logger.dart';

class MemberController extends GetxController {
  final MemberService _memberService = MemberService();

  // 可观察变量
  final RxList<Member> _members = <Member>[].obs;
  final Rx<Member?> _selectedMember = Rx<Member?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = RxString('');
  final RxInt _totalMembers = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _pageSize = 10.obs;

  // Getters
  List<Member> get members => _members;
  Member? get selectedMember => _selectedMember.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  int get totalMembers => _totalMembers.value;
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMorePages =>
      _totalMembers.value > _currentPage.value * _pageSize.value;

  // 加载会员列表
  Future<void> loadMembers({
    int page = 1,
    int pageSize = 10,
    String? name,
    String? phone,
    String? level,
    bool refresh = false,
  }) async {
    if (refresh) {
      _members.clear();
      _currentPage.value = 1;
    } else {
      _currentPage.value = page;
    }
    _pageSize.value = pageSize;

    _isLoading.value = true;
    _error.value = '';

    try {
      final result = await _memberService.getMembers(
        page: page,
        pageSize: pageSize,
        name: name,
        phone: phone,
        level: level,
      );

      if (refresh || page == 1) {
        _members.assignAll(result['items']);
      } else {
        _members.addAll(result['items']);
      }

      _totalMembers.value = result['total'];
    } catch (e) {
      Logger.e('MemberController', '加载会员失败: $e');
      _error.value = '加载会员失败: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // 加载更多会员
  Future<void> loadMoreMembers({
    String? name,
    String? phone,
    String? level,
  }) async {
    if (_isLoading.value || !hasMorePages) return;

    await loadMembers(
      page: _currentPage.value + 1,
      pageSize: _pageSize.value,
      name: name,
      phone: phone,
      level: level,
    );
  }

  // 获取单个会员
  Future<void> getMember(int id) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      _selectedMember.value = await _memberService.getMember(id);
    } catch (e) {
      Logger.e('MemberController', '获取会员详情失败: $e');
      _error.value = '获取会员详情失败: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // 创建会员
  Future<bool> createMember(Map<String, dynamic> memberData) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final newMember = await _memberService.createMember(memberData);
      _members.add(newMember);
      _totalMembers.value += 1;
      return true;
    } catch (e) {
      Logger.e('MemberController', '创建会员失败: $e');
      _error.value = '创建会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 更新会员
  Future<bool> updateMember(int id, Map<String, dynamic> memberData) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final updatedMember = await _memberService.updateMember(id, memberData);

      // 更新列表中的会员
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        _members[index] = updatedMember;
      }

      // 更新选中的会员
      if (_selectedMember.value?.id == id) {
        _selectedMember.value = updatedMember;
      }

      return true;
    } catch (e) {
      Logger.e('MemberController', '更新会员失败: $e');
      _error.value = '更新会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 删除会员
  Future<bool> deleteMember(int id) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      await _memberService.deleteMember(id);

      // 从列表中移除会员
      _members.removeWhere((m) => m.id == id);
      _totalMembers.value -= 1;

      // 清除选中的会员
      if (_selectedMember.value?.id == id) {
        _selectedMember.value = null;
      }

      return true;
    } catch (e) {
      Logger.e('MemberController', '删除会员失败: $e');
      _error.value = '删除会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 清除选中的会员
  void clearSelectedMember() {
    _selectedMember.value = null;
  }

  // 添加会员积分
  Future<bool> addMemberPoints(
    int id,
    int points,
    String type,
    String note,
  ) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      await _memberService.addMemberPoints(id, points, type, note);

      // 刷新会员信息以更新积分
      await getMember(id);

      return true;
    } catch (e) {
      Logger.e('MemberController', '添加会员积分失败: $e');
      _error.value = '添加会员积分失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 清除错误
  void clearError() {
    _error.value = '';
  }
}
