import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../managers/theme_manager.dart';
import '../../../models/tour_plan.dart';
import '../tour_plan_view_model.dart';
import 'edit_daily_tour_plan_screen.dart';

class TourPlanPreview extends StatefulWidget {
  const TourPlanPreview({super.key});

  @override
  State<TourPlanPreview> createState() => _TourPlanPreviewState();
}

class _TourPlanPreviewState extends State<TourPlanPreview> {
  int _selectedWeekFilter =
      0; // 0 = All Weeks, 1 = Week 1, 2 = Week 2, 3 = Week 3, 4 = Week 4

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();
    final plan = viewModel.currentPlan;
    final theme = ThemeManager.instance;

    if (plan == null) {
      return Center(
        child: CircularProgressIndicator(color: theme.getAccentBlue()),
      );
    }

    return Column(
      children: [
        // Status Header Banner
        _buildStatusHeader(plan.status, theme),

        // Week Filter Pill Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWeekFilterChip('All 4 Weeks', 0, theme),
                const SizedBox(width: 8),
                _buildWeekFilterChip('Week 1', 1, theme),
                const SizedBox(width: 8),
                _buildWeekFilterChip('Week 2', 2, theme),
                const SizedBox(width: 8),
                _buildWeekFilterChip('Week 3', 3, theme),
                const SizedBox(width: 8),
                _buildWeekFilterChip('Week 4', 4, theme),
              ],
            ),
          ),
        ),

        // List of Weeks
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _selectedWeekFilter == 0 ? plan.weeks.length : 1,
            itemBuilder: (context, index) {
              final actualWeekIndex = _selectedWeekFilter == 0
                  ? index
                  : (_selectedWeekFilter - 1);
              final week = plan.weeks[actualWeekIndex];
              return _buildWeekCard(
                context,
                viewModel,
                week,
                actualWeekIndex + 1,
                theme,
              );
            },
          ),
        ),

        // Submit Footer Button
        if (plan.status == TourPlanStatus.draft)
          _buildSubmitFooter(context, viewModel, theme),
      ],
    );
  }

  Widget _buildWeekFilterChip(String label, int index, ThemeManager theme) {
    final isSelected = _selectedWeekFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWeekFilter = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.getAccentBlue() : theme.getSurfaceColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.getAccentBlue() : theme.getBorderColor(),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.getTextSecondary(),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(TourPlanStatus status, ThemeManager theme) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case TourPlanStatus.draft:
        bgColor = const Color(
          0xFFEAB308,
        ).withOpacity(theme.isLightMode ? 0.12 : 0.2);
        textColor = theme.isLightMode
            ? const Color(0xFFD97706)
            : const Color(0xFFFACC15);
        text = 'Draft Plan (Ready for Submission)';
        icon = Icons.edit_note_rounded;
        break;
      case TourPlanStatus.pending:
        bgColor = theme.getAccentBlue().withOpacity(
          theme.isLightMode ? 0.12 : 0.2,
        );
        textColor = theme.getAccentBlue();
        text = 'Pending Manager Approval';
        icon = Icons.hourglass_top_rounded;
        break;
      case TourPlanStatus.approved:
        bgColor = const Color(
          0xFF16A34A,
        ).withOpacity(theme.isLightMode ? 0.12 : 0.2);
        textColor = const Color(0xFF16A34A);
        text = 'Approved Monthly Plan';
        icon = Icons.verified_rounded;
        break;
      case TourPlanStatus.rejected:
        bgColor = const Color(
          0xFFEF4444,
        ).withOpacity(theme.isLightMode ? 0.12 : 0.2);
        textColor = const Color(0xFFEF4444);
        text = 'Rejected - Revision Required';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(
    BuildContext context,
    TourPlanViewModel viewModel,
    WeeklyTourPlan week,
    int weekNumber,
    ThemeManager theme,
  ) {
    final startDateStr = DateFormat('MMM d').format(week.days.first.date);
    final endDateStr = DateFormat('MMM d').format(week.days.last.date);

    int fieldDays = 0;
    int totalVisits = 0;
    for (var d in week.days) {
      if (d.type == DailyTourPlanType.field) {
        fieldDays++;
        totalVisits += d.customerIds.length;
      } else if (d.type == DailyTourPlanType.remote) {
        totalVisits += d.customerIds.length;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.getListItemColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.getBorderColor()),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: weekNumber == 1,
          iconColor: theme.getAccentBlue(),
          collapsedIconColor: theme.getTextSecondary(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              Text(
                'Week $weekNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.getTextPrimary(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.getSurfaceColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$startDateStr - $endDateStr',
                  style: TextStyle(
                    color: theme.getTextSecondary(),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 12,
                  color: theme.getTextSecondary(),
                ),
                const SizedBox(width: 4),
                Text(
                  '$fieldDays Field Days',
                  style: TextStyle(
                    color: theme.getTextSecondary(),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.people_alt_outlined,
                  size: 12,
                  color: theme.getTextSecondary(),
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalVisits Doctor Visits',
                  style: TextStyle(
                    color: theme.getTextSecondary(),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          children: week.days.asMap().entries.map((entry) {
            final dIdx = entry.key;
            final day = entry.value;
            final globalDayIndex = (weekNumber - 1) * 7 + dIdx;
            return _buildDayRow(day, globalDayIndex, viewModel, theme, context);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDayRow(
    DailyTourPlan day,
    int globalDayIndex,
    TourPlanViewModel viewModel,
    ThemeManager theme,
    BuildContext context,
  ) {
    final dayName = DateFormat('EEE, MMM d').format(day.date);
    IconData typeIcon;
    Color iconColor;
    Color iconBg;
    String typeLabel;

    switch (day.type) {
      case DailyTourPlanType.off:
        typeIcon = Icons.bedtime_outlined;
        iconColor = theme.getTextTertiary();
        iconBg = theme.getSurfaceColor();
        typeLabel = 'Off';
        break;
      case DailyTourPlanType.remote:
        typeIcon = Icons.laptop_chromebook;
        iconColor = theme.getAccentBlue();
        iconBg = theme.getAccentBlue().withOpacity(
          theme.isLightMode ? 0.1 : 0.2,
        );
        typeLabel = 'Remote Field Work';
        break;
      case DailyTourPlanType.field:
        typeIcon = Icons.map_rounded;
        iconColor = const Color(0xFF16A34A);
        iconBg = const Color(
          0xFF16A34A,
        ).withOpacity(theme.isLightMode ? 0.1 : 0.2);
        typeLabel = 'Field Work';
        break;
    }

    // Find brick name if available
    String? brickName;
    if (day.type == DailyTourPlanType.field && day.brickId != null) {
      final b = viewModel.allBricks.firstWhere(
        (x) => x['brick_id'].toString() == day.brickId,
        orElse: () => {},
      );
      brickName = b['brick_name'];
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: viewModel.currentPlan?.status == TourPlanStatus.draft
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider.value(
                      value: viewModel,
                      child: EditDailyTourPlanScreen(dayIndex: globalDayIndex),
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.getBorderColor())),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.getTextPrimary(),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              typeLabel,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (viewModel.currentPlan?.status ==
                                TourPlanStatus.draft) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: theme.getTextTertiary(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.type == DailyTourPlanType.field
                          ? (brickName != null
                                ? '$brickName • ${day.customerIds.length} Doctors'
                                : 'Unassigned Area')
                          : (day.type == DailyTourPlanType.remote
                                ? '${day.customerIds.length} Remote Doctor Calls'
                                : 'Rest Day'),
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitFooter(
    BuildContext context,
    TourPlanViewModel viewModel,
    ThemeManager theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        border: Border(top: BorderSide(color: theme.getBorderColor())),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.getAccentBlue(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Submit Plan to Manager',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _showSubmitConfirmationDialog(context, viewModel, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitConfirmationDialog(
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
          'Submit Monthly Tour Plan?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.getTextPrimary(),
          ),
        ),
        content: Text(
          'Your 4-week tour plan will be sent to your sales manager for review and approval.',
          style: TextStyle(color: theme.getTextSecondary(), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.getTextSecondary()),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.getAccentBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              viewModel.submitToManager();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tour Plan submitted to manager successfully!'),
                  backgroundColor: Color(0xFF16A34A),
                ),
              );
            },
            child: const Text('Confirm & Submit'),
          ),
        ],
      ),
    );
  }
}

class BorderDecoration {
  static BoxDecoration bottomBorder(Color color) {
    return BoxDecoration(
      border: Border(bottom: BorderSide(color: color, width: 0.8)),
    );
  }
}
