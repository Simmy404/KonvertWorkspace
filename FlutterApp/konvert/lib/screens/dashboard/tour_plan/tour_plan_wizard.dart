import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../managers/theme_manager.dart';
import '../../../models/tour_plan.dart';
import '../tour_plan_view_model.dart';
import 'brick_doctor_picker.dart';
import 'package:intl/intl.dart';

class TourPlanWizard extends StatelessWidget {
  const TourPlanWizard({super.key});

  void _showBrickPicker(BuildContext context, int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<TourPlanViewModel>(),
          child: BrickDoctorPicker(dayIndex: dayIndex),
        );
      },
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

    // Calculate configured days
    int configuredCount = 0;
    for (var day in week1.days) {
      if (day.type == DailyTourPlanType.off || day.type == DailyTourPlanType.remote) {
        configuredCount++;
      } else if (day.type == DailyTourPlanType.field && day.brickId != null && day.customerIds.isNotEmpty) {
        configuredCount++;
      }
    }
    final progress = configuredCount / 7.0;

    return Column(
      children: [
        // Header Instruction & Progress Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.getListItemColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.getBorderColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Setup Week 1 Template',
                    style: TextStyle(
                      color: theme.getTextPrimary(),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progress == 1.0
                          ? const Color(0xFF16A34A).withOpacity(0.12)
                          : theme.getAccentBlue().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$configuredCount / 7 Days Ready',
                      style: TextStyle(
                        color: progress == 1.0 ? const Color(0xFF16A34A) : theme.getAccentBlue(),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Configure your 7-day pattern below. It will automatically replicate across all 4 weeks of the month.',
                style: TextStyle(
                  color: theme.getTextSecondary(),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.getSurfaceColor(),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? const Color(0xFF16A34A) : theme.getAccentBlue(),
                  ),
                ),
              ),
            ],
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

        // Footer Action Button
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
    final dayName = DateFormat('EEEE, MMM d').format(day.date);
    final isWeekend = day.date.weekday == DateTime.saturday || day.date.weekday == DateTime.sunday;

    // Find selected brick name if field
    String? selectedBrickName;
    if (day.type == DailyTourPlanType.field && day.brickId != null) {
      final brick = viewModel.allBricks.firstWhere(
        (b) => b['brick_id'].toString() == day.brickId,
        orElse: () => {},
      );
      selectedBrickName = brick['brick_name'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.getListItemColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: day.type == DailyTourPlanType.field && day.brickId == null
              ? const Color(0xFFEAB308).withOpacity(0.5) // Warning amber if incomplete field work
              : theme.getBorderColor(),
          width: day.type == DailyTourPlanType.field && day.brickId == null ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Date & Weekend Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.getTextPrimary(),
                      ),
                    ),
                    if (isWeekend) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.getSurfaceColor(),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Weekend',
                          style: TextStyle(
                            color: theme.getTextTertiary(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Mode Selector Chips (Off / Remote / Field)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildModeChip(
                  label: 'Off',
                  icon: Icons.bedtime_outlined,
                  isSelected: day.type == DailyTourPlanType.off,
                  activeColor: theme.getTextSecondary(),
                  onTap: () => viewModel.updateDayType(index, DailyTourPlanType.off),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildModeChip(
                  label: 'Remote',
                  icon: Icons.laptop_chromebook,
                  isSelected: day.type == DailyTourPlanType.remote,
                  activeColor: theme.getAccentBlue(),
                  onTap: () => viewModel.updateDayType(index, DailyTourPlanType.remote),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildModeChip(
                  label: 'Field Work',
                  icon: Icons.map_rounded,
                  isSelected: day.type == DailyTourPlanType.field,
                  activeColor: const Color(0xFF16A34A),
                  onTap: () => viewModel.updateDayType(index, DailyTourPlanType.field),
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Details Section depending on Mode
          if (day.type == DailyTourPlanType.field) ...[
            Divider(height: 1, color: theme.getBorderColor()),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showBrickPicker(context, index),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: day.brickId != null
                              ? const Color(0xFF16A34A).withOpacity(0.12)
                              : const Color(0xFFEAB308).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          day.brickId != null ? Icons.check_rounded : Icons.add_rounded,
                          color: day.brickId != null ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.brickId == null
                                  ? 'Select Area & Doctors'
                                  : selectedBrickName ?? 'Territory Selected',
                              style: TextStyle(
                                color: theme.getTextPrimary(),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              day.brickId == null
                                  ? 'Tap to assign territory and doctors'
                                  : '${day.customerIds.length} ${day.customerIds.length == 1 ? 'Doctor' : 'Doctors'} targeted for visit',
                              style: TextStyle(
                                color: day.brickId == null ? const Color(0xFFD97706) : theme.getTextSecondary(),
                                fontSize: 11,
                                fontWeight: day.brickId == null ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: theme.getTextSecondary(), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (day.type == DailyTourPlanType.remote) ...[
            Divider(height: 1, color: theme.getBorderColor()),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.getAccentBlue().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.laptop_chromebook, color: theme.getAccentBlue(), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${day.customerIds.length} preset doctors assigned for phone calls/followups',
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required ThemeManager theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(theme.isLightMode ? 0.12 : 0.25)
                : theme.getSurfaceColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : theme.getBorderColor(),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeColor : theme.getTextTertiary(),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : theme.getTextSecondary(),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        border: Border(
          top: BorderSide(
            color: theme.getBorderColor(),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.getAccentBlue(),
              disabledBackgroundColor: theme.isLightMode
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: isComplete
                ? () {
                    viewModel.confirmAndCopyWeek();
                  }
                : null,
            child: Text(
              isComplete
                  ? 'Confirm & Copy to all 4 Weeks'
                  : 'Complete All Field Work Assignments',
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
