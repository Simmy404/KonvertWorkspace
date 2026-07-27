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
    final theme = ThemeManager.instance;

    return Consumer<TourPlanViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.getAccentBlue(),
              strokeWidth: 2.5,
            ),
          );
        }

        final plan = viewModel.currentPlan;

        // If there's no plan, or it's draft/rejected BUT we haven't generated all 4 weeks yet,
        // show the wizard to configure week 1.
        bool showWizard = false;
        if (plan != null) {
          if (plan.status == TourPlanStatus.draft || plan.status == TourPlanStatus.rejected) {
            if (plan.weeks.length == 1) {
              showWizard = true;
            }
          }
        }

        // Calculate KPI summary numbers across the plan
        int totalFieldDays = 0;
        int totalRemoteDays = 0;
        int totalTargetVisits = 0;

        if (plan != null && plan.weeks.isNotEmpty) {
          for (var w in plan.weeks) {
            for (var d in w.days) {
              if (d.type == DailyTourPlanType.field) {
                totalFieldDays++;
                totalTargetVisits += d.customerIds.length;
              } else if (d.type == DailyTourPlanType.remote) {
                totalRemoteDays++;
                totalTargetVisits += d.customerIds.length;
              }
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
                // Top Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Brand Logo & Share Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            theme.getLogoMark(),
                            height: 28,
                            errorBuilder: (ctx, err, stack) => Icon(
                              Icons.auto_awesome,
                              color: theme.getAccentBlue(),
                              size: 28,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tour plan export feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.ios_share_rounded,
                              color: theme.isLightMode ? Colors.black87 : Colors.white70,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title & Subtitle Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tour Plan',
                                style: TextStyle(
                                  color: theme.isLightMode ? const Color(0xFF0022FF) : Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                showWizard
                                    ? 'Configure Week 1 tour plan'
                                    : 'Monthly Schedule & Territory Coverage',
                                style: TextStyle(
                                  color: theme.getTextSecondary(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (plan != null && plan.weeks.length == 4 && plan.status == TourPlanStatus.draft)
                            TextButton.icon(
                              onPressed: () {
                                _showResetConfirmationDialog(context, viewModel, theme);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.getAccentBlue(),
                                backgroundColor: theme.getSurfaceColor(),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: theme.getBorderColor()),
                                ),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 14),
                              label: const Text('Edit Pattern', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metric Summary Cards (Only shown in Monthly Preview)
                      if (!showWizard && plan != null && plan.weeks.length == 4)
                        Row(
                          children: [
                            _buildSummaryCard(
                              label: 'Field Days',
                              value: '$totalFieldDays',
                              icon: Icons.map_rounded,
                              color: const Color(0xFF16A34A),
                              theme: theme,
                            ),
                            const SizedBox(width: 10),
                            _buildSummaryCard(
                              label: 'Remote Days',
                              value: '$totalRemoteDays',
                              icon: Icons.laptop_chromebook,
                              color: theme.getAccentBlue(),
                              theme: theme,
                            ),
                            const SizedBox(width: 10),
                            _buildSummaryCard(
                              label: 'Target Visits',
                              value: '$totalTargetVisits',
                              icon: Icons.groups_rounded,
                              color: const Color(0xFFA855F7),
                              theme: theme,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Main Content (Wizard or Preview Timeline)
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

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeManager theme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.getListItemColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.getBorderColor()),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(theme.isLightMode ? 0.1 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: theme.getTextPrimary(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.getTextSecondary(),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    TourPlanViewModel viewModel,
    ThemeManager theme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.getSurfaceColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Re-edit Week 1 Pattern?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.getTextPrimary(),
          ),
        ),
        content: Text(
          'This will return to the Week 1 Setup Wizard so you can adjust your pattern and re-replicate it across all 4 weeks.',
          style: TextStyle(color: theme.getTextSecondary(), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.getTextSecondary())),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.getAccentBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              viewModel.resetToDraft();
              Navigator.pop(ctx);
            },
            child: const Text('Edit Pattern'),
          ),
        ],
      ),
    );
  }
}
