import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/app_manager.dart';
import '../models/enums.dart';
import '../themes/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konvert App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final appManager = Provider.of<AppManager>(context, listen: false);
              appManager.toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<AppManager>(
        builder: (context, appManager, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOS Checkbox
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: appManager.tosChecked,
                          onChanged: (value) {
                            appManager.tosChecked = value ?? false;
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I agree to the Terms of Service',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme Mode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ThemeModeVariations>(
                          value: appManager.selectedTheme,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: ThemeModeVariations.values.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(mode.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              appManager.selectedTheme = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Domain Selection (Placeholder)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Domain',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appManager.selectedDomain?.name ?? 'No domain selected',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        // Domain selection UI will go here
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Company Hierarchy Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Hierarchy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CompanyHierarchy>(
                          value: appManager.selectedCompanyHierarchy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: CompanyHierarchy.values.map((hierarchy) {
                            return DropdownMenuItem(
                              value: hierarchy,
                              child: Text(hierarchy.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              appManager.selectedCompanyHierarchy = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Type Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<UserType>(
                          value: appManager.selectedUserType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: UserType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              appManager.selectedUserType = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      appManager.resetAll();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset All Settings'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}