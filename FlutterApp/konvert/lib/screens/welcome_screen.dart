// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'terms_of_service_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image covering the entire screen
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/welcomeBG.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // UI Content Layers
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top-left branded logomark
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Image.asset(
                          'assets/branding/Logomark_White.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Left-aligned Headings
                    const Text(
                      'Keep Your\nSales Moving',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Plan, Track and Analyze your sales\nNow powered by AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Call to Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServiceScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Pill shape matching the image
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          _showFeaturesDialog(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Explore Features',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeaturesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.srcOver,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212).withOpacity(0.9), // Match dark theme
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle decoration
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header text
                const Text(
                  'Core Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everything you need to plan, track, and analyze your ecosystem.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Premium layout list of features
                const _FeatureItem(
                  icon: Icons.layers_outlined,
                  title: 'Multi-domain support',
                  subtitle: 'Manage independent domain models out of the box.',
                ),
                const _FeatureItem(
                  icon: Icons.shield_outlined,
                  title: 'Secure authentication',
                  subtitle: 'Enterprise-grade security guarding your architecture.',
                ),
                const _FeatureItem(
                  icon: Icons.account_tree_outlined,
                  title: 'Business hierarchy management',
                  subtitle: 'Organize teams, permissions, and groups globally.',
                ),
                const _FeatureItem(
                  icon: Icons.supervised_user_circle_outlined,
                  title: 'User role management',
                  subtitle: 'Granular control over user roles and global rules.',
                ),
                const _FeatureItem(
                  icon: Icons.space_dashboard_outlined,
                  title: 'Real-time dashboard',
                  subtitle: 'Instantly view events and metrics dynamically.',
                ),
                const _FeatureItem(
                  icon: Icons.analytics_outlined,
                  title: 'Advanced analytics',
                  subtitle: 'Deep data collection paired with predictive modeling.',
                ),
                
                const SizedBox(height: 24),
                
                // Sleek, full-width close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled modern circle icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and description block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



