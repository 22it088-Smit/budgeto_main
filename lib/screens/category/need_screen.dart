import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/transaction_list.dart';
import 'package:budgeto/widgets/add_expense_dialog.dart';
import 'package:budgeto/widgets/add_payee_dialog.dart';
import 'package:budgeto/widgets/schedule_autopay_dialog.dart';

class NeedScreen extends StatefulWidget {
  const NeedScreen({Key? key}) : super(key: key);

  @override
  State<NeedScreen> createState() => _NeedScreenState();
}

class _NeedScreenState extends State<NeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(category: 'Need'),
    );
  }

  void _showAddPayeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPayeeDialog(category: 'Need'),
    );
  }

  void _showScheduleAutopayDialog() {
    showDialog(
      context: context,
      builder: (context) => const ScheduleAutopayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final needAmount = budgetService.budget?.needAmount ?? 0;
    final needPercentage = budgetService.budget?.needPercentage ?? 50;
    
    // Filter transactions for Need category
    final needTransactions = budgetService.transactions
        .where((t) => t.category == 'Need')
        .toList();
    
    // Filter payees for Need category
    final needPayees = budgetService.payees
        .where((p) => p.category == 'Need')
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Category'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Autopay'),
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
              // Need amount card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Need Balance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(needAmount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$needPercentage% of Income',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Need description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Need Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The Need category is for essential expenses that you must pay, such as:',
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.home_outlined),
                        title: Text('Housing (rent or mortgage)'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.restaurant_outlined),
                        title: Text('Groceries and essential food'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.local_hospital_outlined),
                        title: Text('Healthcare expenses'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.directions_car_outlined),
                        title: Text('Transportation costs'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.power_outlined),
                        title: Text('Utilities (electricity, water, etc.)'),
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
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showScheduleAutopayDialog,
                icon: const Icon(Icons.schedule_outlined),
                label: const Text('Schedule Autopay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          
          // Transactions Tab
          needTransactions.isEmpty
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
                  transactions: needTransactions,
                ),
          
          // Autopay Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Payees section
              Text(
                'Your Payees',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (needPayees.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payees added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddPayeeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Payee'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: needPayees.length,
                  itemBuilder: (context, index) {
                    final payee = needPayees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(payee.name),
                        subtitle: Text('Account: ${payee.accountNumber}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.schedule_outlined),
                          onPressed: () {
                            // Schedule autopay for this payee
                          },
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Scheduled payments section
              Text(
                'Scheduled Payments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scheduled payments',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showScheduleAutopayDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Schedule Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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