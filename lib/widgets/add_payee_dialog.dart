import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class AddPayeeDialog extends StatefulWidget {
  final String category;

  const AddPayeeDialog({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<AddPayeeDialog> createState() => _AddPayeeDialogState();
}

class _AddPayeeDialogState extends State<AddPayeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _addPayee() async {
    if (_formKey.currentState?.validate() ?? false) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      final name = _nameController.text.trim();
      final accountNumber = _accountNumberController.text.trim();
      
      final success = await budgetService.addPayee(
        name,
        accountNumber,
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
      title: Text('Add ${widget.category} Payee'),
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Payee Name',
                hintText: 'e.g., Electric Company, Landlord',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a payee name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                hintText: 'e.g., 123456789',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an account number';
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
          text: 'Add Payee',
          isLoading: budgetService.isLoading,
          onPressed: _addPayee,
        ),
      ],
    );
  }
}