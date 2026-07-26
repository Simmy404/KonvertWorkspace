import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../managers/theme_manager.dart';
import '../../../models/tour_plan.dart';
import '../tour_plan_view_model.dart';

class TourPlanPreview extends StatelessWidget {
  const TourPlanPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();
    final plan = viewModel.currentPlan;

    if (plan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildStatusHeader(plan.status),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plan.weeks.length,
            itemBuilder: (context, weekIndex) {
              final week = plan.weeks[weekIndex];
              return _buildWeekCard(context, week, weekIndex + 1);
            },
          ),
        ),
        if (plan.status == TourPlanStatus.draft) _buildSubmitFooter(context, viewModel),
      ],
    );
  }

  Widget _buildStatusHeader(TourPlanStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case TourPlanStatus.draft:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade800;
        text = 'Draft (Ready for Submission)';
        icon = Icons.edit_note;
        break;
      case TourPlanStatus.pending:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade800;
        text = 'Pending Manager Approval';
        icon = Icons.hourglass_empty;
        break;
      case TourPlanStatus.approved:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade800;
        text = 'Approved Monthly Plan';
        icon = Icons.check_circle;
        break;
      case TourPlanStatus.rejected:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade800;
        text = 'Rejected - Needs Revision';
        icon = Icons.cancel;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(BuildContext context, WeeklyTourPlan week, int weekNumber) {
    final theme = ThemeManager.instance;
    final isDark = theme.isLightMode == false;
    
    final startDateStr = DateFormat('MMM d').format(week.days.first.date);
    final endDateStr = DateFormat('MMM d').format(week.days.last.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: weekNumber == 1,
          title: Text(
            'Week $weekNumber',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.getTextPrimary(),
            ),
          ),
          subtitle: Text(
            '$startDateStr - $endDateStr',
            style: TextStyle(color: theme.getTextSecondary()),
          ),
          children: week.days.map((day) => _buildDayRow(day, theme)).toList(),
        ),
      ),
    );
  }

  Widget _buildDayRow(DailyTourPlan day, ThemeManager theme) {
    final dayName = DateFormat('EEE').format(day.date);
    IconData typeIcon;
    Color iconColor;
    String desc;

    switch (day.type) {
      case DailyTourPlanType.off:
        typeIcon = Icons.bedtime_outlined;
        iconColor = Colors.grey;
        desc = 'Off';
        break;
      case DailyTourPlanType.remote:
        typeIcon = Icons.laptop_chromebook;
        iconColor = const Color(0xFF1E56E2);
        desc = 'Remote Field Work (${day.customerIds.length} doctors)';
        break;
      case DailyTourPlanType.field:
        typeIcon = Icons.map_outlined;
        iconColor = Colors.green;
        desc = 'Field Work (${day.customerIds.length} doctors)';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              dayName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.getTextPrimary(),
              ),
            ),
          ),
          Icon(typeIcon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                color: theme.getTextSecondary(),
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubmitFooter(BuildContext context, TourPlanViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeManager.instance.getAppBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E56E2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: null, // Disabled for now until API is ready
            child: const Text(
              'Submit to Manager (Coming Soon)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
