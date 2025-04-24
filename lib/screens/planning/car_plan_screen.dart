import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class CarPlanScreen extends StatefulWidget {
  const CarPlanScreen({Key? key}) : super(key: key);

  @override
  State<CarPlanScreen> createState() => _CarPlanScreenState();
}

class _CarPlanScreenState extends State<CarPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carCostController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  @override
  void dispose() {
    _carCostController.dispose();
    _monthlyAmountController.dispose();
    super.dispose();
  }
  
  void _initializeControllers() {
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    
    // Get car plan if it exists
    final carPlan = budgetService.plans
        .where((p) => p.type == 'car')
        .toList()
        .firstOrNull;
    
    if (carPlan != null) {
      _carCostController.text = carPlan.targetAmount.toString();
      _monthlyAmountController.text = carPlan.monthlyAmount.toString();
    } else {
      // Default values
      _carCostController.text = '15000';
      
      // Suggest 5% of need category as monthly contribution
      final needAmount = budgetService.budget?.needAmount ?? 0;
      final suggestedMonthly = needAmount * 0.05;
      _monthlyAmountController.text = suggestedMonthly.toString();
    }
  }
  
  Future<void> _saveCarPlan() async {
    if (_formKey.currentState?.validate() ?? false) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      final carCost = double.parse(_carCostController.text);
      final monthlyAmount = double.parse(_monthlyAmountController.text);
      
      final success = await budgetService.createCarPlan(
        carCost,
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
    
    // Get car plan if it exists
    final carPlan = budgetService.plans
        .where((p) => p.type == 'car')
        .toList()
        .firstOrNull;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Purchase Plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Car plan info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Car Purchase Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A car purchase plan helps you save for your next vehicle without taking on debt. By setting aside money each month, you can buy your next car with cash.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Financial experts recommend buying a car that costs no more than 35% of your annual income.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Current progress (if plan exists)
          if (carPlan != null) ...[
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
                          currencyFormat.format(carPlan.currentAmount),
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
                          currencyFormat.format(carPlan.targetAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: carPlan.progress,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(carPlan.progress * 100).toStringAsFixed(1)}% Complete',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (carPlan.remainingMonths > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Estimated completion in ${carPlan.remainingMonths} months',
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
          
          // Car plan form
          Text(
            carPlan == null ? 'Set Up Car Purchase Plan' : 'Update Car Purchase Plan',
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
                      controller: _carCostController,
                      decoration: const InputDecoration(
                        labelText: 'Car Cost',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the car cost';
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
                        prefixText: '\$',
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
                      text: carPlan == null ? 'Create Car Purchase Plan' : 'Update Car Purchase Plan',
                      isLoading: budgetService.isLoading,
                      onPressed: _saveCarPlan,
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