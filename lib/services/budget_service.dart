import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:budgeto/models/transaction_model.dart';
import 'package:budgeto/models/budget_model.dart';
import 'package:budgeto/models/plan_model.dart';
import 'package:budgeto/models/payee_model.dart';
import 'package:budgeto/models/stock_model.dart';

class BudgetService with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  Budget? _budget;
  List<TransactionModel> _transactions = [];
  List<PlanModel> _plans = [];
  List<PayeeModel> _payees = [];
  List<StockModel> _stocks = [];
  
  bool _isLoading = false;
  String? _error;

  Budget? get budget => _budget;
  List<TransactionModel> get transactions => _transactions;
  List<PlanModel> get plans => _plans;
  List<PayeeModel> get payees => _payees;
  List<StockModel> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic> _budgetSettings = {
    'need': 50,
    'expenses': 30,
    'savings': 20,
  };

  Map<String, dynamic> get budgetSettings => _budgetSettings;

  BudgetService() {
    _loadData();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    final settingsJson = prefs.getString('budgetSettings');
    final plansJson = prefs.getString('plans');
    final payeesJson = prefs.getString('payees');

    if (transactionsJson != null) {
      final List<dynamic> decoded = json.decode(transactionsJson);
      _transactions = decoded.map((item) => TransactionModel.fromMap(item, 'demo_user')).toList();
    }

    if (settingsJson != null) {
      _budgetSettings = Map<String, dynamic>.from(json.decode(settingsJson));
    }

    if (plansJson != null) {
      final List<dynamic> decoded = json.decode(plansJson);
      _plans = decoded.map((item) => PlanModel.fromMap(item, 'demo_user')).toList();
    }

    if (payeesJson != null) {
      final List<dynamic> decoded = json.decode(payeesJson);
      _payees = decoded.map((item) => PayeeModel.fromMap(item, 'demo_user')).toList();
    }

    // Initialize budget
    _budget = Budget(
      needPercentage: _budgetSettings['need'] ?? 50,
      expensesPercentage: _budgetSettings['expenses'] ?? 30,
      savingsPercentage: _budgetSettings['savings'] ?? 20,
      needAmount: 0,
      expensesAmount: 0,
      savingsAmount: 0,
    );

    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateBudgetSettings(Map<String, dynamic> settings) async {
    _budgetSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('budgetSettings', json.encode(settings));
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', json.encode(
      _transactions.map((t) => t.toMap()).toList()
    ));
  }

  Future<void> deleteTransaction(int index) async {
    _transactions.removeAt(index);
    await _saveTransactions();
    notifyListeners();
  }

  // Initialize and load user data
  Future<void> initializeUserData() async {
    try {
      setLoading(true);
      setError(null);
      
      await _loadData();
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }

  // Add income
  Future<bool> addIncome(double amount, String description) async {
    try {
      setLoading(true);
      setError(null);
      
      // Calculate amounts based on percentages
      final needAmount = (amount * _budget!.needPercentage / 100);
      final expensesAmount = (amount * _budget!.expensesPercentage / 100);
      final savingsAmount = (amount * _budget!.savingsPercentage / 100);
      
      // Update budget amounts
      _budget!.needAmount += needAmount;
      _budget!.expensesAmount += expensesAmount;
      _budget!.savingsAmount += savingsAmount;
      
      // Create income transaction
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: 'demo_user',
        amount: amount,
        description: description,
        category: 'Income',
        date: DateTime.now(),
        type: 'income',
      );
      
      _transactions.insert(0, transaction);
      await _saveTransactions();
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Add expense
  Future<bool> addExpense(double amount, String description, String category) async {
    try {
      setLoading(true);
      setError(null);
      
      // Determine which budget category to deduct from
      if (category == 'Need') {
        if (_budget!.needAmount < amount) {
          setError('Insufficient funds in Need category');
          setLoading(false);
          return false;
        }
        _budget!.needAmount -= amount;
      } else if (category == 'Expenses') {
        if (_budget!.expensesAmount < amount) {
          setError('Insufficient funds in Expenses category');
          setLoading(false);
          return false;
        }
        _budget!.expensesAmount -= amount;
      } else if (category == 'Savings') {
        if (_budget!.savingsAmount < amount) {
          setError('Insufficient funds in Savings category');
          setLoading(false);
          return false;
        }
        _budget!.savingsAmount -= amount;
      } else {
        setError('Invalid category');
        setLoading(false);
        return false;
      }
      
      // Create expense transaction
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: 'demo_user',
        amount: amount,
        description: description,
        category: category,
        date: DateTime.now(),
        type: 'expense',
      );
      
      _transactions.insert(0, transaction);
      await _saveTransactions();
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Add payee
  Future<bool> addPayee(String name, String accountNumber, String category) async {
    try {
      setLoading(true);
      setError(null);
      
      final payee = PayeeModel(
        id: _uuid.v4(),
        userId: 'demo_user',
        name: name,
        accountNumber: accountNumber,
        category: category,
      );
      
      _payees.add(payee);
      
      // Save payees to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('payees', json.encode(
        _payees.map((p) => p.toMap()).toList()
      ));
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Schedule autopay
  Future<bool> scheduleAutopay(String payeeId, double amount, DateTime date) async {
    try {
      setLoading(true);
      setError(null);
      
      final payee = _payees.firstWhere((p) => p.id == payeeId);
      
      final autopay = {
        'id': _uuid.v4(),
        'userId': 'demo_user',
        'payeeId': payeeId,
        'payeeName': payee.name,
        'amount': amount,
        'scheduledDate': date.toIso8601String(),
        'status': 'scheduled',
        'category': payee.category,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Save autopay to local storage
      final prefs = await SharedPreferences.getInstance();
      final autopaysJson = prefs.getString('autopays') ?? '[]';
      final List<dynamic> autopays = json.decode(autopaysJson);
      autopays.add(autopay);
      await prefs.setString('autopays', json.encode(autopays));
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Create emergency fund plan
  Future<bool> createEmergencyFund(double targetAmount, double monthlyAmount) async {
    try {
      setLoading(true);
      setError(null);
      
      // Check if emergency fund plan already exists
      final existingPlan = _plans.where((p) => p.type == 'emergency').toList();
      if (existingPlan.isNotEmpty) {
        // Update existing plan
        final index = _plans.indexWhere((p) => p.id == existingPlan.first.id);
        _plans[index] = PlanModel(
          id: existingPlan.first.id,
          userId: 'demo_user',
          type: 'emergency',
          name: 'Emergency Fund',
          targetAmount: targetAmount,
          currentAmount: existingPlan.first.currentAmount,
          monthlyAmount: monthlyAmount,
          createdAt: existingPlan.first.createdAt,
        );
      } else {
        // Create new plan
        final plan = PlanModel(
          id: _uuid.v4(),
          userId: 'demo_user',
          type: 'emergency',
          name: 'Emergency Fund',
          targetAmount: targetAmount,
          currentAmount: 0,
          monthlyAmount: monthlyAmount,
          createdAt: DateTime.now(),
        );
        
        _plans.add(plan);
      }
      
      // Save plans to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('plans', json.encode(
        _plans.map((p) => p.toMap()).toList()
      ));
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Create car plan
  Future<bool> createCarPlan(double carCost, double monthlyAmount) async {
    try {
      setLoading(true);
      setError(null);
      
      // Check if car plan already exists
      final existingPlan = _plans.where((p) => p.type == 'car').toList();
      if (existingPlan.isNotEmpty) {
        // Update existing plan
        final index = _plans.indexWhere((p) => p.id == existingPlan.first.id);
        _plans[index] = PlanModel(
          id: existingPlan.first.id,
          userId: 'demo_user',
          type: 'car',
          name: 'Car Purchase Plan',
          targetAmount: carCost,
          currentAmount: existingPlan.first.currentAmount,
          monthlyAmount: monthlyAmount,
          createdAt: existingPlan.first.createdAt,
        );
      } else {
        // Create new plan
        final plan = PlanModel(
          id: _uuid.v4(),
          userId: 'demo_user',
          type: 'car',
          name: 'Car Purchase Plan',
          targetAmount: carCost,
          currentAmount: 0,
          monthlyAmount: monthlyAmount,
          createdAt: DateTime.now(),
        );
        
        _plans.add(plan);
      }
      
      // Save plans to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('plans', json.encode(
        _plans.map((p) => p.toMap()).toList()
      ));
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Invest in stock
  Future<bool> investInStock(String stockId, double amount) async {
    try {
      setLoading(true);
      setError(null);
      
      final stock = _stocks.firstWhere((s) => s.id == stockId);
      
      // Check if user has enough in savings
      if (_budget!.savingsAmount < amount) {
        setError('Insufficient funds in Savings category');
        setLoading(false);
        return false;
      }
      
      // Update budget amount
      _budget!.savingsAmount -= amount;
      
      // Create investment transaction
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: 'demo_user',
        amount: amount,
        description: 'Investment in ${stock.name} (${stock.symbol})',
        category: 'Savings',
        date: DateTime.now(),
        type: 'investment',
      );
      
      _transactions.insert(0, transaction);
      await _saveTransactions();
      
      // Create investment record
      final investment = {
        'id': _uuid.v4(),
        'userId': 'demo_user',
        'stockId': stockId,
        'stockSymbol': stock.symbol,
        'stockName': stock.name,
        'amount': amount,
        'shares': amount / stock.price,
        'purchasePrice': stock.price,
        'date': DateTime.now().toIso8601String(),
      };
      
      // Save investment to local storage
      final prefs = await SharedPreferences.getInstance();
      final investmentsJson = prefs.getString('investments') ?? '[]';
      final List<dynamic> investments = json.decode(investmentsJson);
      investments.add(investment);
      await prefs.setString('investments', json.encode(investments));
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Process monthly transfers (from need/expenses to savings)
  Future<bool> processMonthlyTransfers() async {
    try {
      setLoading(true);
      setError(null);
      
      // Get current amounts
      final needAmount = _budget!.needAmount;
      final expensesAmount = _budget!.expensesAmount;
      
      // Update budget amounts
      _budget!.savingsAmount += (needAmount + expensesAmount);
      _budget!.needAmount = 0;
      _budget!.expensesAmount = 0;
      
      // Create transfer transactions
      if (needAmount > 0) {
        final needTransaction = TransactionModel(
          id: _uuid.v4(),
          userId: 'demo_user',
          amount: needAmount,
          description: 'Monthly transfer from Need to Savings',
          category: 'Need',
          date: DateTime.now(),
          type: 'transfer',
        );
        
        _transactions.insert(0, needTransaction);
      }
      
      if (expensesAmount > 0) {
        final expensesTransaction = TransactionModel(
          id: _uuid.v4(),
          userId: 'demo_user',
          amount: expensesAmount,
          description: 'Monthly transfer from Expenses to Savings',
          category: 'Expenses',
          date: DateTime.now(),
          type: 'transfer',
        );
        
        _transactions.insert(0, expensesTransaction);
      }
      
      await _saveTransactions();
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Process monthly plan deductions
  Future<bool> processMonthlyPlanDeductions() async {
    try {
      setLoading(true);
      setError(null);
      
      for (final plan in _plans) {
        if (plan.monthlyAmount <= 0) continue;
        
        // Check if need category has enough funds
        if (_budget!.needAmount < plan.monthlyAmount) {
          setError('Insufficient funds in Need category for ${plan.name}');
          setLoading(false);
          return false;
        }
        
        // Update budget amount
        _budget!.needAmount -= plan.monthlyAmount;
        
        // Update plan amount
        final index = _plans.indexWhere((p) => p.id == plan.id);
        _plans[index] = PlanModel(
          id: plan.id,
          userId: plan.userId,
          type: plan.type,
          name: plan.name,
          targetAmount: plan.targetAmount,
          currentAmount: plan.currentAmount + plan.monthlyAmount,
          monthlyAmount: plan.monthlyAmount,
          createdAt: plan.createdAt,
        );
        
        // Create plan transaction
        final transaction = TransactionModel(
          id: _uuid.v4(),
          userId: 'demo_user',
          amount: plan.monthlyAmount,
          description: 'Monthly contribution to ${plan.name}',
          category: 'Need',
          date: DateTime.now(),
          type: 'plan',
        );
        
        _transactions.insert(0, transaction);
      }
      
      // Save plans and transactions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('plans', json.encode(
        _plans.map((p) => p.toMap()).toList()
      ));
      await _saveTransactions();
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}