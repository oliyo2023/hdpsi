import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';

import '../widgets/member_list_item.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 加载会员列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).loadMembers(refresh: true);
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
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      if (!memberProvider.isLoading && memberProvider.hasMorePages) {
        memberProvider.loadMoreMembers(
          name:
              _searchController.text.isNotEmpty ? _searchController.text : null,
        );
      }
    }
  }

  // 搜索会员
  void _searchMembers() {
    Provider.of<MemberProvider>(context, listen: false).loadMembers(
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
            child: Consumer<MemberProvider>(
              builder: (context, memberProvider, child) {
                if (memberProvider.isLoading &&
                    memberProvider.members.isEmpty) {
                  return const LoadingIndicator(message: '加载会员中...');
                }

                if (memberProvider.error != null &&
                    memberProvider.members.isEmpty) {
                  return ErrorDisplay(
                    error: memberProvider.error!,
                    onRetry: () => memberProvider.loadMembers(refresh: true),
                  );
                }

                if (memberProvider.members.isEmpty) {
                  return EmptyData(
                    message: '暂无会员数据',
                    icon: Icons.people,
                    onAction:
                        () => Navigator.of(context).pushNamed('/members/add'),
                    actionLabel: '添加会员',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => memberProvider.loadMembers(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        memberProvider.members.length +
                        (memberProvider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == memberProvider.members.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final member = memberProvider.members[index];
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
