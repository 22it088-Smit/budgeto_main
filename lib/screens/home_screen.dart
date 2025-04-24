import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/auth_service.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/services/theme_service.dart';
import 'package:budgeto/screens/category/need_screen.dart';
import 'package:budgeto/screens/category/expenses_screen.dart';
import 'package:budgeto/screens/category/savings_screen.dart';
import 'package:budgeto/screens/planning/planning_screen.dart';
import 'package:budgeto/screens/settings_screen.dart';
import 'package:budgeto/widgets/budget_card.dart';
import 'package:budgeto/widgets/transaction_list.dart';
import 'package:budgeto/widgets/add_income_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      await budgetService.initializeUserData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddIncomeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final budgetService = Provider.of<BudgetService>(context);
    final themeService = Provider.of<ThemeService>(context);
    
    // Calculate budget amounts and percentages
    final totalBudget = budgetService.budget?.totalAmount ?? 0.0;
    final needAmount = budgetService.budget?.needAmount ?? 0.0;
    final expensesAmount = budgetService.budget?.expensesAmount ?? 0.0;
    final savingsAmount = budgetService.budget?.savingsAmount ?? 0.0;
    
    final needPercentage = totalBudget > 0 ? ((needAmount / totalBudget) * 100).round() : 50;
    final expensesPercentage = totalBudget > 0 ? ((expensesAmount / totalBudget) * 100).round() : 30;
    final savingsPercentage = totalBudget > 0 ? ((savingsAmount / totalBudget) * 100).round() : 20;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgeto'),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              themeService.toggleThemeMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Error message
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  
                  // User greeting
                  Text(
                    'Hello, ${authService.displayName ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    'Here\'s your financial summary',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Budget cards
                  Row(
                    children: [
                      Expanded(
                        child: BudgetCard(
                          title: 'Need',
                          amount: needAmount,
                          percentage: needPercentage,
                          color: Theme.of(context).primaryColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NeedScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: BudgetCard(
                          title: 'Expenses',
                          amount: expensesAmount,
                          percentage: expensesPercentage,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: BudgetCard(
                          title: 'Savings',
                          amount: savingsAmount,
                          percentage: savingsPercentage,
                          color: Colors.amber,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SavingsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Planning button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PlanningScreen()),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Planning Tools'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all transactions
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (budgetService.transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
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
                          ],
                        ),
                      ),
                    )
                  else
                    TransactionList(
                      transactions: budgetService.transactions.take(5).toList(),
                      maxHeight: 300,
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddIncomeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}