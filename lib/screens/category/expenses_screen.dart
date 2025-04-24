import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/transaction_list.dart';
import 'package:budgeto/widgets/add_expense_dialog.dart';
import 'package:budgeto/widgets/add_payee_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(category: 'Expenses'),
    );
  }

  void _showAddPayeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPayeeDialog(category: 'Expenses'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final expensesAmount = budgetService.budget?.expensesAmount ?? 0;
    final expensesPercentage = budgetService.budget?.expensesPercentage ?? 30;
    
    // Filter transactions for Expenses category
    final expensesTransactions = budgetService.transactions
        .where((t) => t.category == 'Expenses')
        .toList();
    
    // Filter payees for Expenses category
    final expensesPayees = budgetService.payees
        .where((p) => p.category == 'Expenses')
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Category'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Expenses amount card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Expenses Balance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(expensesAmount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$expensesPercentage% of Income',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Expenses description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Expenses Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The Expenses category is for non-essential spending that enhances your lifestyle, such as:',
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.restaurant_menu_outlined),
                        title: Text('Dining out and takeout'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.movie_outlined),
                        title: Text('Entertainment and streaming services'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.shopping_bag_outlined),
                        title: Text('Shopping and clothing'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.sports_esports_outlined),
                        title: Text('Hobbies and recreation'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.card_giftcard_outlined),
                        title: Text('Gifts and donations'),
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddExpenseDialog,
                      icon: const Icon(Icons.payment_outlined),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddPayeeDialog,
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Add Payee'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Transactions Tab
          expensesTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddExpenseDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                      ),
                    ],
                  ),
                )
              : TransactionList(
                  transactions: expensesTransactions,
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}