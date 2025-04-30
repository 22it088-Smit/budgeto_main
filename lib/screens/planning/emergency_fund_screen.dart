import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class EmergencyFundScreen extends StatefulWidget {
  const EmergencyFundScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyFundScreen> createState() => _EmergencyFundScreenState();
}

class _EmergencyFundScreenState extends State<EmergencyFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetAmountController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  @override
  void dispose() {
    _targetAmountController.dispose();
    _monthlyAmountController.dispose();
    super.dispose();
  }
  
  void _initializeControllers() {
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    
    // Get emergency fund plan if it exists
    final emergencyFundPlan = budgetService.plans
        .where((p) => p.type == 'emergency')
        .toList()
        .firstOrNull;
    
    if (emergencyFundPlan != null) {
      _targetAmountController.text = emergencyFundPlan.targetAmount.toString();
      _monthlyAmountController.text = emergencyFundPlan.monthlyAmount.toString();
    } else {
      // Calculate recommended emergency fund amount (6x expenses)
      final expensesAmount = budgetService.budget?.expensesAmount ?? 0;
      final recommendedAmount = expensesAmount * 6;
      _targetAmountController.text = recommendedAmount.toString();
      
      // Suggest 10% of need category as monthly contribution
      final needAmount = budgetService.budget?.needAmount ?? 0;
      final suggestedMonthly = needAmount * 0.1;
      _monthlyAmountController.text = suggestedMonthly.toString();
    }
  }
  
  Future<void> _saveEmergencyFund() async {
    if (_formKey.currentState?.validate() ?? false) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      final targetAmount = double.parse(_targetAmountController.text);
      final monthlyAmount = double.parse(_monthlyAmountController.text);
      
      final success = await budgetService.createEmergencyFund(
        targetAmount,
        monthlyAmount,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    
    // Get emergency fund plan if it exists
    final emergencyFundPlan = budgetService.plans
        .where((p) => p.type == 'emergency')
        .toList()
        .firstOrNull;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Fund'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency fund info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Emergency Fund',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'An emergency fund is a financial safety net that everyone should have. It covers unexpected expenses like medical emergencies, car repairs, or job loss.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Financial experts recommend having 3-6 months of expenses saved in your emergency fund.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Current progress (if plan exists)
          if (emergencyFundPlan != null) ...[
            Text(
              'Current Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Amount:',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          currencyFormat.format(emergencyFundPlan.currentAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target Amount:',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          currencyFormat.format(emergencyFundPlan.targetAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: emergencyFundPlan.progress,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(emergencyFundPlan.progress * 100).toStringAsFixed(1)}% Complete',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (emergencyFundPlan.remainingMonths > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Estimated completion in ${emergencyFundPlan.remainingMonths} months',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Emergency fund form
          Text(
            emergencyFundPlan == null ? 'Set Up Emergency Fund' : 'Update Emergency Fund',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Target Amount',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a target amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _monthlyAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Contribution',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a monthly amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: emergencyFundPlan == null ? 'Create Emergency Fund' : 'Update Emergency Fund',
                      isLoading: budgetService.isLoading,
                      onPressed: _saveEmergencyFund,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}