import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/models/member.dart';
import 'package:hd_psi_mobile/utils/formatters.dart';

class MemberListItem extends StatelessWidget {
  const MemberListItem({super.key, required this.member, required this.onTap});

  final Member member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
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
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
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
                            color: _getLevelColor(member.level).withAlpha(51),
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
              const Icon(Icons.chevron_right, color: Colors.grey),
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
