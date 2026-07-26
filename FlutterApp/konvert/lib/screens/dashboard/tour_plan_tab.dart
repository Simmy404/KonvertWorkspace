import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/theme_manager.dart';
import 'tour_plan_view_model.dart';
import 'tour_plan/tour_plan_wizard.dart';
import 'tour_plan/tour_plan_preview.dart';
import '../../models/tour_plan.dart';

class TourPlanTab extends StatelessWidget {
  const TourPlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.instance.isLightMode == false;

    return Consumer<TourPlanViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final plan = viewModel.currentPlan;
        
        // If there's no plan, or it's draft/rejected BUT we haven't generated all 4 weeks yet,
        // show the wizard to configure week 1.
        bool showWizard = false;
        if (plan != null) {
          if (plan.status == TourPlanStatus.draft || plan.status == TourPlanStatus.rejected) {
            // We only show wizard if there's only 1 week (Week 1 setup phase)
            // Once they "Confirm & Copy", weeks length becomes 4, and we show the preview.
            if (plan.weeks.length == 1) {
              showWizard = true;
            }
          }
        }

        return Container(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          // Reset button for testing/reverting to draft
                          if (plan != null && plan.weeks.length == 4 && plan.status == TourPlanStatus.draft)
                            TextButton.icon(
                              onPressed: () {
                                context.read<TourPlanViewModel>().resetToDraft();
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit Plan'),
                            )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        showWizard ? 'Setup Week 1' : 'Monthly Preview',
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: showWizard ? const TourPlanWizard() : const TourPlanPreview(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
