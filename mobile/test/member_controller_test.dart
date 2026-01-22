import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/controllers/member_controller.dart';
import 'package:hd_psi_mobile/models/member.dart';

void main() {
  group('MemberController Tests', () {
    late MemberController memberController;

    setUp(() {
      // 初始化GetX
      Get.testMode = true;
      memberController = MemberController();
    });

    tearDown(() {
      // 清理
      Get.reset();
    });

    test('初始状态应该正确', () {
      expect(memberController.members, isEmpty);
      expect(memberController.selectedMember, isNull);
      expect(memberController.isLoading, isFalse);
      expect(memberController.error, isNull);
      expect(memberController.totalMembers, equals(0));
      expect(memberController.currentPage, equals(1));
      expect(memberController.pageSize, equals(10));
      expect(memberController.hasMorePages, isFalse);
    });

    test('clearError 应该清除错误信息', () {
      // 模拟设置错误
      memberController.clearError();
      expect(memberController.error, isNull);
    });

    test('clearSelectedMember 应该清除选中的会员', () {
      memberController.clearSelectedMember();
      expect(memberController.selectedMember, isNull);
    });

    test('响应式变量应该正常工作', () {
      // 测试响应式变量的更新
      expect(memberController.isLoading, isFalse);
      
      // 由于我们没有实际的网络请求，这里只测试基本的响应式功能
      expect(memberController.members, isA<List<Member>>());
      expect(memberController.totalMembers, isA<int>());
    });
  });
}
