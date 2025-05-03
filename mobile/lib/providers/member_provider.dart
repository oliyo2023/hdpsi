import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/member_service.dart';

class MemberProvider extends ChangeNotifier {
  final MemberService _memberService = MemberService();
  
  List<Member> _members = [];
  Member? _selectedMember;
  bool _isLoading = false;
  String? _error;
  int _totalMembers = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  
  List<Member> get members => _members;
  Member? get selectedMember => _selectedMember;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalMembers => _totalMembers;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMorePages => _totalMembers > _currentPage * _pageSize;
  
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
      _members = [];
      _currentPage = 1;
    } else {
      _currentPage = page;
    }
    _pageSize = pageSize;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _memberService.getMembers(
        page: page,
        pageSize: pageSize,
        name: name,
        phone: phone,
        level: level,
      );
      
      if (refresh || page == 1) {
        _members = result['items'];
      } else {
        _members.addAll(result['items']);
      }
      
      _totalMembers = result['total'];
      _error = null;
    } catch (e) {
      _error = '加载会员失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载更多会员
  Future<void> loadMoreMembers({
    String? name,
    String? phone,
    String? level,
  }) async {
    if (_isLoading || !hasMorePages) return;
    
    await loadMembers(
      page: _currentPage + 1,
      pageSize: _pageSize,
      name: name,
      phone: phone,
      level: level,
    );
  }
  
  // 获取单个会员
  Future<void> getMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedMember = await _memberService.getMember(id);
      _error = null;
    } catch (e) {
      _error = '获取会员详情失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 创建会员
  Future<bool> createMember(Map<String, dynamic> memberData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newMember = await _memberService.createMember(memberData);
      _members.insert(0, newMember);
      _totalMembers += 1;
      _error = null;
      return true;
    } catch (e) {
      _error = '创建会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 更新会员
  Future<bool> updateMember(int id, Map<String, dynamic> memberData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedMember = await _memberService.updateMember(id, memberData);
      
      // 更新列表中的会员
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        _members[index] = updatedMember;
      }
      
      // 更新选中的会员
      if (_selectedMember?.id == id) {
        _selectedMember = updatedMember;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = '更新会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 删除会员
  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _memberService.deleteMember(id);
      
      // 从列表中移除会员
      _members.removeWhere((m) => m.id == id);
      _totalMembers -= 1;
      
      // 清除选中的会员
      if (_selectedMember?.id == id) {
        _selectedMember = null;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = '删除会员失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 清除选中的会员
  void clearSelectedMember() {
    _selectedMember = null;
    notifyListeners();
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
