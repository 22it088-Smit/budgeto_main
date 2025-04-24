import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/transaction_list.dart';
import 'package:budgeto/widgets/add_expense_dialog.dart';
import 'package:budgeto/widgets/stock_list.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  String _selectedRiskLevel = 'All';

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
      builder: (context) => AddExpenseDialog(category: 'Savings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final savingsAmount = budgetService.budget?.savingsAmount ?? 0;
    final savingsPercentage = budgetService.budget?.savingsPercentage ?? 20;
    
    // Filter transactions for Savings category
    final savingsTransactions = budgetService.transactions
        .where((t) => t.category == 'Savings')
        .toList();
    
    // Filter stocks based on risk level
    final filteredStocks = _selectedRiskLevel == 'All'
        ? budgetService.stocks
        : budgetService.stocks.where((s) => s.riskLevel == _selectedRiskLevel).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Category'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Investments'),
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
              // Savings amount card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Savings Balance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(savingsAmount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$savingsPercentage% of Income',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Savings description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Savings Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The Savings category is for building wealth and financial security, including:',
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.savings_outlined),
                        title: Text('Emergency fund'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.trending_up_outlined),
                        title: Text('Investments and stocks'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.directions_car_outlined),
                        title: Text('Car purchase fund'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.home_outlined),
                        title: Text('Home down payment'),
                        dense: true,
                      ),
                      const ListTile(
                        leading: Icon(Icons.school_outlined),
                        title: Text('Education and personal development'),
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
                      onPressed: () {
                        _tabController.animateTo(1); // Go to Investments tab
                      },
                      icon: const Icon(Icons.trending_up_outlined),
                      label: const Text('Invest'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddExpenseDialog,
                      icon: const Icon(Icons.payment_outlined),
                      label: const Text('Withdraw'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Investments Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Risk level filter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Risk Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'All', label: Text('All')),
                          ButtonSegment(value: 'Low', label: Text('Low')),
                          ButtonSegment(value: 'Medium', label: Text('Medium')),
                          ButtonSegment(value: 'High', label: Text('High')),
                        ],
                        selected: {_selectedRiskLevel},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _selectedRiskLevel = selection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Stocks list
              Text(
                'Available Stocks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              StockList(
                stocks: filteredStocks,
                onInvest: (stock) {
                  // Show invest dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invest in ${stock.name}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Current price: ${currencyFormat.format(stock.price)}'),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Amount to Invest',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Invest in stock
                            Navigator.of(context).pop();
                          },
                          child: const Text('Invest'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Automatic investment form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatic Investment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Investment Amount',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          hintText: 'e.g., Monthly, Weekly',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Investment Type',
                          hintText: 'e.g., Index Fund, ETF',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Submit automatic investment form
                          },
                          child: const Text('Set Up Automatic Investment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Transactions Tab
          savingsTransactions.isEmpty
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
                        label: const Text('Add Transaction'),
                      ),
                    ],
                  ),
                )
              : TransactionList(
                  transactions: savingsTransactions,
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 1) {
            // On investments tab, show invest dialog
          } else {
            _showAddExpenseDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}