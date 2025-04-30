import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/screens/planning/emergency_fund_screen.dart';
import 'package:budgeto/screens/planning/car_plan_screen.dart';
import 'package:budgeto/models/plan_model.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    
    // Get emergency fund plan
    final emergencyFundPlan = budgetService.plans
        .where((p) => p.type == 'emergency')
        .toList()
        .firstOrNull;
    
    // Get car plan
    final carPlan = budgetService.plans
        .where((p) => p.type == 'car')
        .toList()
        .firstOrNull;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Planning intro
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Planning',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Plan for your future financial goals with these tools. Set targets, track progress, and automate your savings.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Emergency Fund Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.red[700],
                    ),
                  ),
                  title: const Text('Emergency Fund'),
                  subtitle: const Text('Financial safety net for unexpected expenses'),
                ),
                if (emergencyFundPlan != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: emergencyFundPlan.progress,
                          backgroundColor: Colors.grey[200],
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(emergencyFundPlan.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(emergencyFundPlan.currentAmount)} / ${currencyFormat.format(emergencyFundPlan.targetAmount)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (emergencyFundPlan != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Contribution:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                currencyFormat.format(emergencyFundPlan.monthlyAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EmergencyFundScreen(),
                              ),
                            );
                          },
                          child: Text(
                            emergencyFundPlan == null ? 'Set Up' : 'Manage',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Car Plan Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.directions_car_outlined,
                      color: Colors.blue[700],
                    ),
                  ),
                  title: const Text('Car Purchase Plan'),
                  subtitle: const Text('Save for your next vehicle'),
                ),
                
                if (carPlan != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: carPlan.progress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(carPlan.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(carPlan.currentAmount)} / ${currencyFormat.format(carPlan.targetAmount)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (carPlan != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Contribution:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                currencyFormat.format(carPlan.monthlyAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CarPlanScreen(),
                              ),
                            );
                          },
                          child: Text(
                            carPlan == null ? 'Set Up' : 'Manage',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Add new plan button
          OutlinedButton.icon(
            onPressed: () {
              // Show dialog to select plan type
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create New Plan'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home_outlined),
                        title: const Text('Home Down Payment'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // Navigate to home down payment screen
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: const Text('Education Fund'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // Navigate to education fund screen
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.celebration_outlined),
                        title: const Text('Vacation Fund'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // Navigate to vacation fund screen
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Plan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}