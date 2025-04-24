import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class BudgetSplitDialog extends StatefulWidget {
  const BudgetSplitDialog({Key? key}) : super(key: key);

  @override
  State<BudgetSplitDialog> createState() => _BudgetSplitDialogState();
}

class _BudgetSplitDialogState extends State<BudgetSplitDialog> {
  late int _needPercentage;
  late int _expensesPercentage;
  late int _savingsPercentage;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    final budgetService = Provider.of<BudgetService>(context, listen: false);
    _needPercentage = budgetService.budget?.needPercentage ?? 50;
    _expensesPercentage = budgetService.budget?.expensesPercentage ?? 30;
    _savingsPercentage = budgetService.budget?.savingsPercentage ?? 20;
  }
  
  void _updateNeedPercentage(int value) {
    setState(() {
      _needPercentage = value;
      _adjustPercentages();
    });
  }
  
  void _updateExpensesPercentage(int value) {
    setState(() {
      _expensesPercentage = value;
      _adjustPercentages();
    });
  }
  
  void _updateSavingsPercentage(int value) {
    setState(() {
      _savingsPercentage = value;
      _adjustPercentages();
    });
  }
  
  void _adjustPercentages() {
    final total = _needPercentage + _expensesPercentage + _savingsPercentage;
    
    if (total != 100) {
      // Adjust to ensure total is 100%
      if (total > 100) {
        // If over 100%, reduce the largest percentage
        if (_needPercentage >= _expensesPercentage && _needPercentage >= _savingsPercentage) {
          _needPercentage = 100 - _expensesPercentage - _savingsPercentage;
        } else if (_expensesPercentage >= _needPercentage && _expensesPercentage >= _savingsPercentage) {
          _expensesPercentage = 100 - _needPercentage - _savingsPercentage;
        } else {
          _savingsPercentage = 100 - _needPercentage - _expensesPercentage;
        }
      } else if (total < 100) {
        // If under 100%, increase the largest percentage
        if (_needPercentage >= _expensesPercentage && _needPercentage >= _savingsPercentage) {
          _needPercentage = 100 - _expensesPercentage - _savingsPercentage;
        } else if (_expensesPercentage >= _needPercentage && _expensesPercentage >= _savingsPercentage) {
          _expensesPercentage = 100 - _needPercentage - _savingsPercentage;
        } else {
          _savingsPercentage = 100 - _needPercentage - _expensesPercentage;
        }
      }
    }
  }
  
  Future<void> _saveBudgetSplit() async {
    try {
      setState(() {
        _error = null;
      });
      
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      await budgetService.updateBudgetSettings({
        'need': _needPercentage,
        'expenses': _expensesPercentage,
        'savings': _savingsPercentage,
      });
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    
    return AlertDialog(
      title: const Text('Budget Split'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          
          if (budgetService.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                budgetService.error!,
                style: TextStyle(color: Colors.red[800]),
              ),
            ),
          
          Text(
            'Adjust the percentages for each category. Total must equal 100%.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Need percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Need:'),
                  Text('$_needPercentage%'),
                ],
              ),
              Slider(
                value: _needPercentage.toDouble(),
                min: 10,
                max: 80,
                divisions: 70,
                label: '$_needPercentage%',
                onChanged: (value) => _updateNeedPercentage(value.round()),
              ),
            ],
          ),
          
          // Expenses percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expenses:'),
                  Text('$_expensesPercentage%'),
                ],
              ),
              Slider(
                value: _expensesPercentage.toDouble(),
                min: 10,
                max: 60,
                divisions: 50,
                label: '$_expensesPercentage%',
                onChanged: (value) => _updateExpensesPercentage(value.round()),
              ),
            ],
          ),
          
          // Savings percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Savings:'),
                  Text('$_savingsPercentage%'),
                ],
              ),
              Slider(
                value: _savingsPercentage.toDouble(),
                min: 10,
                max: 60,
                divisions: 50,
                label: '$_savingsPercentage%',
                onChanged: (value) => _updateSavingsPercentage(value.round()),
              ),
            ],
          ),
          
          // Total
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_needPercentage + _expensesPercentage + _savingsPercentage}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _needPercentage + _expensesPercentage + _savingsPercentage == 100
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: 'Save',
          isLoading: budgetService.isLoading,
          onPressed: _needPercentage + _expensesPercentage + _savingsPercentage == 100
              ? _saveBudgetSplit
              : null,
        ),
      ],
    );
  }
}