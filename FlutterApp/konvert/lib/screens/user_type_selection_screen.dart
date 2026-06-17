// lib/screens/user_type_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/app_manager.dart';
import '../models/enums.dart';
import 'business_hierarchy_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Go back to domain selection
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
                          // 1. Fixed Top Branding Logo Grouping (Aligned exactly like domain screen)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Image.asset(
                              'assets/branding/Logomark_White.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          // Dynamic Spacer pushing elements right above the lower baseline
                          const Spacer(),

                          // 2. Heading Section
                          const Text(
                            'Who are you?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select your user type to continue',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 3. User Type Selection Grouping
                          _buildUserTypeButton(
                            context,
                            icon: Icons.person_rounded,
                            title: 'Customer',
                            description: 'Access your account and services',
                            onTap: () {
                              appManager.selectedUserType = UserType.customer;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Coming soon!'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          
                          _buildUserTypeButton(
                            context,
                            icon: Icons.business_rounded,
                            title: 'Business',
                            description: 'Manage your business operations',
                            onTap: () {
                              appManager.selectedUserType = UserType.business;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BusinessHierarchyScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
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

  Widget _buildUserTypeButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withOpacity(0.05),
        highlightColor: Colors.white.withOpacity(0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              // Premium Circular Icon Backdrop Component
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 18),
              
              // Text Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Clean Minimalist Trailing Caret
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Colors.white.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}