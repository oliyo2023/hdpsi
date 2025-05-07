import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
  final String? selectedType;
  final DateTimeRange? dateRange;
  final Function(String?) onTypeSelected;
  final Function(DateTimeRange?) onDateRangeSelected;
  final Function() onApplyFilter;
  final Function() onSelectDateRange;

  const FilterDialog({
    super.key,
    required this.selectedType,
    required this.dateRange,
    required this.onTypeSelected,
    required this.onDateRangeSelected,
    required this.onApplyFilter,
    required this.onSelectDateRange,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('筛选交易记录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易类型筛选
          const Text('交易类型'),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            children: [
              _buildFilterChip(
                label: '全部',
                selected: _selectedType == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = null;
                  });
                },
              ),
              _buildFilterChip(
                label: '购买',
                selected: _selectedType == 'purchase',
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? 'purchase' : null;
                  });
                },
              ),
              _buildFilterChip(
                label: '退款',
                selected: _selectedType == 'refund',
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? 'refund' : null;
                  });
                },
              ),
              _buildFilterChip(
                label: '积分调整',
                selected: _selectedType == 'points_adjustment',
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? 'points_adjustment' : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 日期范围筛选
          const Text('日期范围'),
          const SizedBox(height: 8.0),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              widget.dateRange != null
                  ? '${DateFormat('yyyy-MM-dd').format(widget.dateRange!.start)} 至 ${DateFormat('yyyy-MM-dd').format(widget.dateRange!.end)}'
                  : '选择日期范围',
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              widget.onSelectDateRange();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onTypeSelected(_selectedType);
            Navigator.of(context).pop();
            widget.onApplyFilter();
          },
          child: const Text('应用'),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withAlpha(51),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
