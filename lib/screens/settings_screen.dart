import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeto/services/auth_service.dart';
import 'package:budgeto/services/budget_service.dart';
import 'package:budgeto/services/theme_service.dart';
import 'package:budgeto/widgets/budget_split_dialog.dart';
import 'package:budgeto/widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final budgetService = Provider.of<BudgetService>(context);
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User profile section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      authService.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authService.displayName ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authService.email ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // Edit profile
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Budget settings
          Text(
            'Budget Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Budget Split'),
                  subtitle: Text(
                    'Need: ${budgetService.budget?.needPercentage ?? 50}%, Expenses: ${budgetService.budget?.expensesPercentage ?? 30}%, Savings: ${budgetService.budget?.savingsPercentage ?? 20}%',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BudgetSplitDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Process Monthly Transfers'),
                  subtitle: const Text('Transfer remaining amounts to savings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Process Monthly Transfers'),
                        content: const Text(
                          'This will transfer all remaining amounts from Need and Expenses categories to Savings. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await budgetService.processMonthlyTransfers();
                            },
                            child: const Text('Process'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Process Plan Deductions'),
                  subtitle: const Text('Deduct monthly amounts for plans'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Process Plan Deductions'),
                        content: const Text(
                          'This will deduct the monthly amounts for all your plans from the Need category. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await budgetService.processMonthlyPlanDeductions();
                            },
                            child: const Text('Process'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // App settings
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage app notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to notifications settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Security'),
                  subtitle: const Text('Manage security settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // About section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('About Budgeto'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: 'Budgeto',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      children: [
                        const Text(
                          'Budgeto is a comprehensive money management app designed to help users take control of their finances.',
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Logout button
          CustomButton(
            text: 'Logout',
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}    
