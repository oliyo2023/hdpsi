import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

class TransactionUtils {
  static String formatTransactionType(String type) {
    return Formatters.formatMemberTransactionType(type);
  }

  static Color getTypeColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.green;
      case 'refund':
        return Colors.orange;
      case 'points_adjustment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static bool isPositiveTransaction(String type, int pointsEarned) {
    return type == 'purchase' ||
        (type == 'points_adjustment' && pointsEarned > 0);
  }
}
