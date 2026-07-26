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
        // Must provide the same viewModel to the bottom sheet if we don't pass it directly
        // Because modal bottom sheets are on a different route.
        // Easiest is to pass it via provider.value
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

    if (viewModel.currentPlan == null || viewModel.currentPlan!.weeks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final week1 = viewModel.currentPlan!.weeks[0];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Set up Week 1 of your monthly tour plan. The configuration will be copied to the remaining 3 weeks.',
            style: TextStyle(
              color: ThemeManager.instance.getTextSecondary(),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = week1.days[index];
              return _buildDayCard(context, viewModel, day, index);
            },
          ),
        ),
        _buildFooter(context, viewModel),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, TourPlanViewModel viewModel, DailyTourPlan day, int index) {
    final dayName = DateFormat('EEEE, MMM d').format(day.date);
    final theme = ThemeManager.instance;
    final isDark = theme.isLightMode == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.getTextPrimary(),
                  ),
                ),
                DropdownButton<DailyTourPlanType>(
                  value: day.type,
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down, color: theme.getTextSecondary()),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: const [
                    DropdownMenuItem(value: DailyTourPlanType.off, child: Text('Off')),
                    DropdownMenuItem(value: DailyTourPlanType.remote, child: Text('Remote Field Work')),
                    DropdownMenuItem(value: DailyTourPlanType.field, child: Text('Field Work')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      viewModel.updateDayType(index, val);
                    }
                  },
                ),
              ],
            ),
          ),
          if (day.type == DailyTourPlanType.field) ...[
            const Divider(height: 1),
            InkWell(
              onTap: () => _showBrickPicker(context, index),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      day.brickId == null ? Icons.add_circle_outline : Icons.check_circle,
                      color: day.brickId == null ? theme.getTextSecondary() : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.brickId == null ? 'Select Area & Doctors' : 'Area Selected',
                            style: TextStyle(
                              color: theme.getTextPrimary(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (day.brickId != null)
                            Text(
                              '${day.customerIds.length} doctors selected',
                              style: TextStyle(
                                color: theme.getTextSecondary(),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.getTextSecondary()),
                  ],
                ),
              ),
            ),
          ] else if (day.type == DailyTourPlanType.remote) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.laptop_chromebook, color: Color(0xFF1E56E2)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${day.customerIds.length} preset doctors assigned',
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, TourPlanViewModel viewModel) {
    final isComplete = viewModel.isWeek1Complete();
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
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isComplete
                ? () {
                    viewModel.confirmAndCopyWeek();
                  }
                : null,
            child: const Text(
              'Confirm & Copy to all 4 Weeks',
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
