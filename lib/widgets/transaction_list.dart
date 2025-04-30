import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double? maxHeight;

  const TransactionList({
    Key? key,
    required this.transactions,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      child: ListView.builder(
        shrinkWrap: true,
        physics: maxHeight != null
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          
          // Determine icon and color based on transaction type and category
          IconData icon;
          Color color;
          
          if (transaction.type == 'income') {
            icon = Icons.arrow_downward;
            color = Colors.green;
          } else if (transaction.type == 'expense') {
            icon = Icons.arrow_upward;
            color = Colors.red;
          } else if (transaction.type == 'transfer') {
            icon = Icons.swap_horiz;
            color = Colors.blue;
          } else if (transaction.type == 'investment') {
            icon = Icons.trending_up;
            color = Colors.purple;
          } else if (transaction.type == 'plan') {
            icon = Icons.savings;
            color = Colors.amber;
          } else {
            icon = Icons.receipt_long;
            color = Colors.grey;
          }
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              title: Text(
                transaction.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${transaction.category} • ${dateFormat.format(transaction.date)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Text(
                transaction.type == 'income'
                    ? '+ ${currencyFormat.format(transaction.amount)}'
                    : '- ${currencyFormat.format(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.type == 'income' ? Colors.green : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}