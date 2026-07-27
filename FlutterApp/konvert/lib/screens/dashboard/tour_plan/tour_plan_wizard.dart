import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../managers/theme_manager.dart';
import '../../../models/tour_plan.dart';
import '../tour_plan_view_model.dart';
import 'dashed_border_painter.dart';
import 'edit_daily_tour_plan_screen.dart';

class TourPlanWizard extends StatelessWidget {
  const TourPlanWizard({super.key});

  void _navigateToEditDay(BuildContext context, int dayIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider.value(
          value: context.read<TourPlanViewModel>(),
          child: EditDailyTourPlanScreen(dayIndex: dayIndex),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();
    final theme = ThemeManager.instance;

    if (viewModel.currentPlan == null || viewModel.currentPlan!.weeks.isEmpty) {
      return Center(child: CircularProgressIndicator(color: theme.getAccentBlue()));
    }

    final week1 = viewModel.currentPlan!.weeks[0];

    // Count configured days
    int configuredCount = 0;
    for (var day in week1.days) {
      if (day.isConfigured) {
        configuredCount++;
      }
    }
    final progress = configuredCount / 7.0;

    return Column(
      children: [
        // Progress Summary Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.getListItemColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.getBorderColor()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      progress == 1.0 ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      color: progress == 1.0 ? const Color(0xFF16A34A) : theme.getAccentBlue(),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week 1 Template Progress',
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$configuredCount of 7 days configured',
                          style: TextStyle(
                            color: theme.getTextSecondary(),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: progress == 1.0
                        ? const Color(0xFF16A34A).withOpacity(0.15)
                        : theme.getAccentBlue().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: progress == 1.0 ? const Color(0xFF16A34A) : theme.getAccentBlue(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List of 7 Days
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = week1.days[index];
              return _buildDayCard(context, viewModel, day, index, theme);
            },
          ),
        ),

        // Footer Action Button with Glowing Gradient Backdrop
        _buildFooter(context, viewModel, theme),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    TourPlanViewModel viewModel,
    DailyTourPlan day,
    int index,
    ThemeManager theme,
  ) {
    final dateStr = DateFormat('EEE, MMM d').format(day.date);
    final isLight = theme.isLightMode;

    // Card Colors according to light / dark theme mockup
    final cardBgColor = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
    final pillBgColor = isLight ? const Color(0xFFD6E4FF) : const Color(0xFF1D263B);
    final pillTextColor = isLight ? const Color(0xFF1E3A8A) : const Color(0xFF90B3FB);
    final btnBgColor = isLight ? const Color(0xFFD8E5FF) : const Color(0xFF1C253C);

    // Get brick name if field work
    String? brickName;
    if (day.type == DailyTourPlanType.field && day.brickId != null) {
      final b = viewModel.allBricks.firstWhere(
        (x) => x['brick_id'].toString() == day.brickId,
        orElse: () => {},
      );
      brickName = b['brick_name'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditDay(context, index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Pill Badge on Left
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      color: pillTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Right Content: Configured vs Unconfigured State
                Expanded(
                  child: day.isConfigured
                      ? _buildConfiguredContent(context, viewModel, day, index, theme, btnBgColor)
                      : _buildUnconfiguredContent(context, index, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfiguredContent(
    BuildContext context,
    TourPlanViewModel viewModel,
    DailyTourPlan day,
    int dayIndex,
    ThemeManager theme,
    Color btnBgColor,
  ) {
    String title;
    String subtitle = '';

    switch (day.type) {
      case DailyTourPlanType.field:
        title = 'Field Work';
        final bName = viewModel.allBricks.firstWhere(
          (x) => x['brick_id'].toString() == day.brickId,
          orElse: () => {},
        )['brick_name'] ?? 'Territory';
        subtitle = '$bName | ${day.customerIds.length} Customers';
        break;
      case DailyTourPlanType.remote:
        title = 'Remote Work';
        subtitle = '${day.customerIds.length} Customers';
        break;
      case DailyTourPlanType.off:
        title = 'Off';
        subtitle = '';
        break;
    }

    final hasActionButtons = day.type == DailyTourPlanType.field || day.type == DailyTourPlanType.remote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title & Subtitle
        Text(
          title,
          style: TextStyle(
            color: theme.getTextPrimary(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.getTextSecondary(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // Action Row (Edit & Delete buttons)
        if (hasActionButtons) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              // Edit Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToEditDay(context, dayIndex),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: btnBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Color(0xFF1E56E2), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF1E56E2),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Delete Button
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.clearDayConfig(dayIndex),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: btnBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUnconfiguredContent(
    BuildContext context,
    int dayIndex,
    ThemeManager theme,
  ) {
    return GestureDetector(
      onTap: () => _navigateToEditDay(context, dayIndex),
      child: DashedBorderContainer(
        color: const Color(0xFF1E56E2),
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: const Center(
          child: Text(
            'Select Work',
            style: TextStyle(
              color: Color(0xFF1E56E2),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    TourPlanViewModel viewModel,
    ThemeManager theme,
  ) {
    final isComplete = viewModel.isWeek1Complete();
    final isLight = theme.isLightMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: theme.getAppBackgroundColor(),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isLight
                  ? [const Color(0xFF5CE1E6), const Color(0xFF0022FF)]
                  : [const Color(0xFF0038FF), const Color(0xFF000A64)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: (isLight ? const Color(0xFF0022FF) : const Color(0xFF0038FF)).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: isComplete
                ? () {
                    viewModel.confirmAndCopyWeek();
                  }
                : () {
                    // Prompt user to finish unconfigured days
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select work for all 7 days before continuing.'),
                        backgroundColor: Color(0xFFFF7A59),
                      ),
                    );
                  },
            child: Text(
              isComplete
                  ? 'Confirm & Copy to all 4 Weeks'
                  : 'Select Work for Remaining Days',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
