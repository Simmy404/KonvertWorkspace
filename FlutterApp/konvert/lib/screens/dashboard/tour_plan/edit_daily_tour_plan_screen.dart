import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../managers/theme_manager.dart';
import '../../../models/tour_plan.dart';
import '../tour_plan_view_model.dart';

class EditDailyTourPlanScreen extends StatefulWidget {
  final int dayIndex;

  const EditDailyTourPlanScreen({
    super.key,
    required this.dayIndex,
  });

  @override
  State<EditDailyTourPlanScreen> createState() => _EditDailyTourPlanScreenState();
}

class _EditDailyTourPlanScreenState extends State<EditDailyTourPlanScreen> {
  late DailyTourPlanType _selectedType;
  String? _selectedBrickId;
  late Set<String> _selectedCustomerIds;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TourPlanViewModel>();
    final plan = viewModel.currentPlan;
    if (plan != null && plan.weeks.isNotEmpty && widget.dayIndex < plan.weeks[0].days.length) {
      final day = plan.weeks[0].days[widget.dayIndex];
      _selectedType = day.type;
      _selectedBrickId = day.brickId;
      _selectedCustomerIds = Set<String>.from(day.customerIds);
    } else {
      _selectedType = DailyTourPlanType.off;
      _selectedBrickId = null;
      _selectedCustomerIds = {};
    }

    // Default brick if none selected and field work
    if (_selectedType == DailyTourPlanType.field && _selectedBrickId == null && viewModel.allBricks.isNotEmpty) {
      _selectedBrickId = viewModel.allBricks.first['brick_id']?.toString();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();
    final theme = ThemeManager.instance;

    if (viewModel.currentPlan == null || viewModel.currentPlan!.weeks.isEmpty) {
      return Scaffold(
        backgroundColor: theme.getAppBackgroundColor(),
        appBar: AppBar(title: const Text('Edit Tour Plan')),
        body: Center(child: CircularProgressIndicator(color: theme.getAccentBlue())),
      );
    }

    final day = viewModel.currentPlan!.weeks[0].days[widget.dayIndex];
    final dateString = DateFormat('EEEE, MMM d, yyyy').format(day.date);

    // Available doctors based on selected brick or all
    List<Map<String, dynamic>> availableDoctors = [];
    if (_selectedType == DailyTourPlanType.field && _selectedBrickId != null) {
      availableDoctors = viewModel.customersByBrick[_selectedBrickId] ?? [];
    } else if (_selectedType == DailyTourPlanType.remote) {
      // Flatten all doctors across bricks for remote work
      viewModel.customersByBrick.values.forEach((list) {
        availableDoctors.addAll(list);
      });
    }

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      availableDoctors = availableDoctors.where((doc) {
        final name = (doc['customer_name'] ?? '').toString().toLowerCase();
        final code = (doc['customer_code'] ?? '').toString().toLowerCase();
        return name.contains(q) || code.contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: theme.getAppBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.getTextPrimary(), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Tour Plan',
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateString,
              style: TextStyle(
                color: theme.getTextSecondary(),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, color: theme.getBorderColor()),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Work Type Selection
                    Text(
                      'Work Type',
                      style: TextStyle(
                        color: theme.getTextPrimary(),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTypeCard(
                          type: DailyTourPlanType.field,
                          label: 'Field Work',
                          subtitle: 'Territory Visit',
                          icon: Icons.map_rounded,
                          accentColor: const Color(0xFF16A34A),
                          theme: theme,
                        ),
                        const SizedBox(width: 10),
                        _buildTypeCard(
                          type: DailyTourPlanType.remote,
                          label: 'Remote',
                          subtitle: 'Calls / Admin',
                          icon: Icons.laptop_chromebook,
                          accentColor: theme.getAccentBlue(),
                          theme: theme,
                        ),
                        const SizedBox(width: 10),
                        _buildTypeCard(
                          type: DailyTourPlanType.off,
                          label: 'Off',
                          subtitle: 'Rest Day',
                          icon: Icons.bedtime_outlined,
                          accentColor: theme.getTextSecondary(),
                          theme: theme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Brick / Territory Selection (Field Work only)
                    if (_selectedType == DailyTourPlanType.field) ...[
                      Text(
                        'Select Territory (Brick)',
                        style: TextStyle(
                          color: theme.getTextPrimary(),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.getListItemColor(),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.getBorderColor()),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBrickId,
                            isExpanded: true,
                            dropdownColor: theme.getSurfaceColor(),
                            hint: Text('Choose a Brick', style: TextStyle(color: theme.getTextSecondary())),
                            items: viewModel.allBricks.map((b) {
                              final id = b['brick_id'].toString();
                              final name = b['brick_name'] ?? id;
                              final count = (viewModel.customersByBrick[id] ?? []).length;
                              return DropdownMenuItem<String>(
                                value: id,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: theme.getTextPrimary(),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '$count Doctors',
                                      style: TextStyle(
                                        color: theme.getTextTertiary(),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedBrickId = val;
                                _selectedCustomerIds.clear(); // reset customers on brick change
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section 3: Target Doctors List
                    if (_selectedType != DailyTourPlanType.off) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Doctors (${_selectedCustomerIds.length} Selected)',
                            style: TextStyle(
                              color: theme.getTextPrimary(),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (availableDoctors.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedCustomerIds.length == availableDoctors.length) {
                                    _selectedCustomerIds.clear();
                                  } else {
                                    _selectedCustomerIds = availableDoctors
                                        .map((d) => d['customer_id'].toString())
                                        .toSet();
                                  }
                                });
                              },
                              child: Text(
                                _selectedCustomerIds.length == availableDoctors.length
                                    ? 'Deselect All'
                                    : 'Select All',
                                style: TextStyle(
                                  color: theme.getAccentBlue(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Doctor Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.getListItemColor(),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.getBorderColor()),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: theme.getTextPrimary(), fontSize: 13),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search_rounded, color: theme.getTextTertiary(), size: 20),
                            hintText: 'Search doctor name or code...',
                            hintStyle: TextStyle(color: theme.getTextTertiary(), fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (availableDoctors.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.getListItemColor(),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.getBorderColor()),
                          ),
                          child: Center(
                            child: Text(
                              _selectedType == DailyTourPlanType.field && _selectedBrickId == null
                                  ? 'Please select a territory above'
                                  : 'No doctors found',
                              style: TextStyle(color: theme.getTextSecondary(), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: availableDoctors.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final doc = availableDoctors[index];
                            final docId = doc['customer_id'].toString();
                            final docName = doc['customer_name'] ?? 'Doctor #$docId';
                            final isChecked = _selectedCustomerIds.contains(docId);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isChecked) {
                                    _selectedCustomerIds.remove(docId);
                                  } else {
                                    _selectedCustomerIds.add(docId);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? theme.getAccentBlue().withOpacity(theme.isLightMode ? 0.08 : 0.2)
                                      : theme.getListItemColor(),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isChecked
                                        ? theme.getAccentBlue()
                                        : theme.getBorderColor(),
                                    width: isChecked ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: isChecked ? theme.getAccentBlue() : theme.getTextTertiary(),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            docName,
                                            style: TextStyle(
                                              color: theme.getTextPrimary(),
                                              fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (doc['customer_code'] != null)
                                            Text(
                                              'Code: ${doc['customer_code']}',
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
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.getSurfaceColor(),
                border: Border(top: BorderSide(color: theme.getBorderColor())),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.getAccentBlue(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    viewModel.updateDailyPlan(
                      widget.dayIndex,
                      _selectedType,
                      _selectedBrickId,
                      _selectedCustomerIds.toList(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Tour Plan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required DailyTourPlanType type,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required ThemeManager theme,
  }) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(theme.isLightMode ? 0.12 : 0.25)
                : theme.getListItemColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : theme.getBorderColor(),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? accentColor : theme.getTextTertiary(),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? accentColor : theme.getTextPrimary(),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? accentColor.withOpacity(0.8) : theme.getTextTertiary(),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
