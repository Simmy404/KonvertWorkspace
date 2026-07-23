import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_view_model.dart';

class TourPlanTab extends StatelessWidget {
  const TourPlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          color: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tour Plan',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Assigned bricks and daily route plan',
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Tour Plan (${viewModel.bricksCount} Bricks Synced)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
