// lib/screens/business_hierarchy_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/app_manager.dart';
import '../models/enums.dart';
import 'sales_rep_login_screen.dart';

class BusinessHierarchyScreen extends StatelessWidget {
  const BusinessHierarchyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Go back to user type selection
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Canvas Layer
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/domainBG.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            
            // Structural Content Layer
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Fixed Top Branding Logo Grouping
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Image.asset(
                              'assets/branding/Logomark_White.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          // Flexible spacing to balance the layout architecture cleanly
                          const SizedBox(height: 40),

                          // 2. Heading Section
                          const Text(
                            'Choose Your Role',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select your position in the company hierarchy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 3. Vertical Hierarchy List Grouping
                          // Sales Rep
                          _buildHierarchyButton(
                            context,
                            icon: Icons.person_outline_rounded,
                            title: 'Sales Rep',
                            description: 'Manage your sales activities',
                            isSelected: appManager.selectedCompanyHierarchy == CompanyHierarchy.salesRep,
                            onTap: () {
                              appManager.selectedCompanyHierarchy = CompanyHierarchy.salesRep;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SalesRepLoginScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Manager
                          _buildHierarchyButton(
                            context,
                            icon: Icons.people_outline_rounded,
                            title: 'Manager',
                            description: 'Oversee team performance',
                            isSelected: appManager.selectedCompanyHierarchy == CompanyHierarchy.manager,
                            onTap: () {
                              appManager.selectedCompanyHierarchy = CompanyHierarchy.manager;
                              _showComingSoon(context);
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Regional Manager
                          _buildHierarchyButton(
                            context,
                            icon: Icons.location_city_rounded,
                            title: 'Regional Manager',
                            description: 'Manage regional operations',
                            isSelected: appManager.selectedCompanyHierarchy == CompanyHierarchy.regionalManager,
                            onTap: () {
                              appManager.selectedCompanyHierarchy = CompanyHierarchy.regionalManager;
                              _showComingSoon(context);
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Business Unit Head
                          _buildHierarchyButton(
                            context,
                            icon: Icons.business_center_rounded,
                            title: 'Business Unit Head',
                            description: 'Lead business unit strategy',
                            isSelected: appManager.selectedCompanyHierarchy == CompanyHierarchy.businessUnitHead,
                            onTap: () {
                              appManager.selectedCompanyHierarchy = CompanyHierarchy.businessUnitHead;
                              _showComingSoon(context);
                            },
                          ),
                          
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        // High-end graphite tone helps items stand out subtly against pure blacks
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white.withOpacity(0.35) : Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.04),
          highlightColor: Colors.white.withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Modern Squircle Icon Frame Component
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text Content Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Dynamic Contextual Trailing Indicator
                isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.25),
                        size: 22,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}