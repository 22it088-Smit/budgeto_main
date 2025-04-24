import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class AddExpenseDialog extends StatefulWidget {
  final String category;

  const AddExpenseDialog({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      
      final success = await budgetService.addExpense(
        amount,
        description,
        widget.category,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    
    return AlertDialog(
      title: Text('Add ${widget.category} Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Groceries, Rent, Utilities',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: 'Add Expense',
          isLoading: budgetService.isLoading,
          onPressed: _addExpense,
        ),
      ],
    );
  }
}