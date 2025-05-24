import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/controllers/member_controller.dart';
import 'package:hd_psi_mobile/widgets/loading_indicator.dart';
import 'package:hd_psi_mobile/widgets/error_display.dart';
import 'package:hd_psi_mobile/widgets/empty_data.dart';

import 'package:hd_psi_mobile/widgets/member_list_item.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  // 使用GetX获取控制器
  final MemberController _memberController = Get.find<MemberController>(
    tag: 'member_controller',
  );

  @override
  void initState() {
    super.initState();

    // 加载会员列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memberController.loadMembers(refresh: true);
    });

    // 添加滚动监听器，用于加载更多
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部时加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_memberController.isLoading && _memberController.hasMorePages) {
        _memberController.loadMoreMembers(
          name:
              _searchController.text.isNotEmpty ? _searchController.text : null,
        );
      }
    }
  }

  // 搜索会员
  void _searchMembers() {
    _memberController.loadMembers(
      refresh: true,
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/members/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索会员姓名或手机号',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchMembers();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchMembers(),
            ),
          ),

          // 会员列表
          Expanded(
            child: Obx(() {
              if (_memberController.isLoading &&
                  _memberController.members.isEmpty) {
                return const LoadingIndicator(message: '加载会员中...');
              }

              if (_memberController.error != null &&
                  _memberController.members.isEmpty) {
                return ErrorDisplay(
                  error: _memberController.error!,
                  onRetry: () => _memberController.loadMembers(refresh: true),
                );
              }

              if (_memberController.members.isEmpty) {
                return EmptyData(
                  message: '暂无会员数据',
                  icon: Icons.people,
                  onAction:
                      () => Navigator.of(context).pushNamed('/members/add'),
                  actionLabel: '添加会员',
                );
              }

              return RefreshIndicator(
                onRefresh: () => _memberController.loadMembers(refresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _memberController.members.length +
                      (_memberController.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _memberController.members.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final member = _memberController.members[index];
                    return MemberListItem(
                      member: member,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/members/detail', arguments: member.id);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
