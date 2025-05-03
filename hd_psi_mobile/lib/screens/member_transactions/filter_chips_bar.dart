import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterChipsBar extends StatelessWidget {
  final String? selectedType;
  final DateTimeRange? dateRange;
  final String Function(String) formatTransactionType;
  final Function() onClearFilters;
  final Function() onClearType;
  final Function() onClearDateRange;

  const FilterChipsBar({
    super.key,
    required this.selectedType,
    required this.dateRange,
    required this.formatTransactionType,
    required this.onClearFilters,
    required this.onClearType,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedType == null && dateRange == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              children: [
                if (selectedType != null)
                  Chip(
                    label: Text(formatTransactionType(selectedType!)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: onClearType,
                  ),
                if (dateRange != null)
                  Chip(
                    label: Text(
                      '${DateFormat('yyyy-MM-dd').format(dateRange!.start)} 至 ${DateFormat('yyyy-MM-dd').format(dateRange!.end)}',
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: onClearDateRange,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClearFilters,
            child: const Text('清除全部'),
          ),
        ],
      ),
    );
  }
}
