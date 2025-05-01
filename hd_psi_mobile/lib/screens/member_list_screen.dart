import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_data.dart';
import '../utils/formatters.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({Key? key}) : super(key: key);

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
      Provider.of<MemberProvider>(context, listen: false).loadMembers(refresh: true);
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      if (!memberProvider.isLoading && memberProvider.hasMorePages) {
        memberProvider.loadMoreMembers(
          name: _searchController.text.isNotEmpty ? _searchController.text : null,
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
                if (memberProvider.isLoading && memberProvider.members.isEmpty) {
                  return const LoadingIndicator(message: '加载会员中...');
                }
                
                if (memberProvider.error != null && memberProvider.members.isEmpty) {
                  return ErrorDisplay(
                    error: memberProvider.error!,
                    onRetry: () => memberProvider.loadMembers(refresh: true),
                  );
                }
                
                if (memberProvider.members.isEmpty) {
                  return EmptyData(
                    message: '暂无会员数据',
                    icon: Icons.people,
                    onAction: () => Navigator.of(context).pushNamed('/members/add'),
                    actionLabel: '添加会员',
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () => memberProvider.loadMembers(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: memberProvider.members.length + (memberProvider.hasMorePages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == memberProvider.members.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      final member = memberProvider.members[index];
                      return _buildMemberItem(context, member);
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
  
  Widget _buildMemberItem(BuildContext context, Member member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/members/detail', arguments: member.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 会员头像
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                child: Text(
                  member.name.isNotEmpty ? member.name[0] : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              
              // 会员信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '手机: ${member.phone}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(member.level).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            Formatters.formatMemberLevel(member.level),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: _getLevelColor(member.level),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '积分: ${member.points}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 右侧箭头
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getLevelColor(String level) {
    switch (level) {
      case 'regular':
        return Colors.blue;
      case 'silver':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.teal;
      case 'diamond':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
