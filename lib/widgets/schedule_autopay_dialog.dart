import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/widgets/custom_button.dart';

class ScheduleAutopayDialog extends StatefulWidget {
  const ScheduleAutopayDialog({Key? key}) : super(key: key);

  @override
  State<ScheduleAutopayDialog> createState() => _ScheduleAutopayDialogState();
}

class _ScheduleAutopayDialogState extends State<ScheduleAutopayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedPayeeId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scheduleAutopay() async {
    if (_formKey.currentState?.validate() ?? false && _selectedPayeeId != null) {
      final budgetService = Provider.of<BudgetService>(context, listen: false);
      
      final amount = double.parse(_amountController.text);
      
      final success = await budgetService.scheduleAutopay(
        _selectedPayeeId!,
        amount,
        _selectedDate,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetService = Provider.of<BudgetService>(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    // Filter payees for Need category
    final needPayees = budgetService.payees
        .where((p) => p.category == 'Need')
        .toList();
    
    return AlertDialog(
      title: const Text('Schedule Autopay'),
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
            
            if (needPayees.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'No payees found. Please add a payee first.',
                  style: TextStyle(color: Colors.amber[800]),
                ),
              )
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Payee',
                ),
                value: _selectedPayeeId,
                items: needPayees.map((payee) {
                  return DropdownMenuItem<String>(
                    value: payee.id,
                    child: Text(payee.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPayeeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a payee';
                  }
                  return null;
                },
              ),
            
            const SizedBox(height: 16),
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
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(dateFormat.format(_selectedDate)),
              ),
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
          text: 'Schedule Payment',
          isLoading: budgetService.isLoading,
          onPressed: needPayees.isEmpty ? null : _scheduleAutopay,
        ),
      ],
    );
  }
}