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
    final day = viewModel.getDayByIndex(widget.dayIndex);
    if (day != null) {
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
    final isLight = theme.isLightMode;
    final titleColor = isLight ? const Color(0xFF0022FF) : Colors.white;
    final cardBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
    final cardBorder = isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A);
    final searchBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF0E1426);
    final searchBorder = isLight ? const Color(0xFFD6E4FF) : const Color(0xFF1E253A);

    final day = viewModel.getDayByIndex(widget.dayIndex);
    if (day == null) {
      return Scaffold(
        backgroundColor: theme.getContrastColor(),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Edit Tour Plan',
                      style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'No tour plan day found for index ${widget.dayIndex}.',
                    style: TextStyle(color: theme.getTextSecondary()),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateString = DateFormat('EEE, MMM d').format(day.date);

    // Filter unique bricks to prevent DropdownButton duplicate value assertion crash
    final Set<String> seenBrickIds = {};
    final List<Map<String, dynamic>> uniqueBricks = [];
    for (var b in viewModel.allBricks) {
      final id = b['brick_id']?.toString() ?? '';
      if (id.isNotEmpty && !seenBrickIds.contains(id)) {
        seenBrickIds.add(id);
        uniqueBricks.add(b);
      }
    }

    if (_selectedBrickId != null && !seenBrickIds.contains(_selectedBrickId)) {
      _selectedBrickId = uniqueBricks.isNotEmpty ? uniqueBricks.first['brick_id']?.toString() : null;
    }

    // Available doctors based on selected brick or all
    List<Map<String, dynamic>> availableDoctors = [];
    if (_selectedType == DailyTourPlanType.field && _selectedBrickId != null) {
      availableDoctors = viewModel.customersByBrick[_selectedBrickId] ?? [];
    } else if (_selectedType == DailyTourPlanType.remote) {
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
      backgroundColor: theme.getContrastColor(),
      body: Stack(
        children: [
          // Dynamic Background Image Layer (mainBG)
          Positioned.fill(
            child: Image.asset(
              theme.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Colors.black),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Modern Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFEFF4FD) : const Color(0xFF161B29),
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorder),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: titleColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Tour Plan',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Configure daily schedule & targets',
                              style: TextStyle(
                                color: theme.getTextSecondary(),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date Chip Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFD6E4FF) : const Color(0xFF1D263B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dateString,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF1E3A8A) : const Color(0xFF90B3FB),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Work Type Selection
                        Text(
                          'WORK TYPE',
                          style: TextStyle(
                            color: theme.getTextSecondary(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
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
                              accentColor: const Color(0xFF10B981),
                              theme: theme,
                            ),
                            const SizedBox(width: 10),
                            _buildTypeCard(
                              type: DailyTourPlanType.remote,
                              label: 'Remote',
                              subtitle: 'Calls / Admin',
                              icon: Icons.laptop_chromebook_rounded,
                              accentColor: const Color(0xFF3B82F6),
                              theme: theme,
                            ),
                            const SizedBox(width: 10),
                            _buildTypeCard(
                              type: DailyTourPlanType.off,
                              label: 'Off',
                              subtitle: 'Rest Day',
                              icon: Icons.bedtime_rounded,
                              accentColor: const Color(0xFF6B7280),
                              theme: theme,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 2: Territory Selection (Field Work only)
                        if (_selectedType == DailyTourPlanType.field) ...[
                          Text(
                            'SELECT TERRITORY (BRICK)',
                            style: TextStyle(
                              color: theme.getTextSecondary(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cardBorder, width: 1.0),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E56E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.explore_rounded,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedBrickId,
                                      isExpanded: true,
                                      dropdownColor: isLight ? Colors.white : const Color(0xFF161B29),
                                      hint: Text(
                                        'Choose a Territory',
                                        style: TextStyle(color: theme.getTextSecondary()),
                                      ),
                                      items: uniqueBricks.map((b) {
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isLight ? const Color(0xFFEFF4FD) : const Color(0xFF22293A),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$count Doctors',
                                                  style: TextStyle(
                                                    color: theme.getTextSecondary(),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedBrickId = val;
                                          _selectedCustomerIds.clear();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
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
                                'TARGET DOCTORS (${_selectedCustomerIds.length})',
                                style: TextStyle(
                                  color: theme.getTextSecondary(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              if (availableDoctors.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLight ? const Color(0xFFEFF4FD) : const Color(0xFF1E253A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _selectedCustomerIds.length == availableDoctors.length
                                          ? 'Deselect All'
                                          : 'Select All',
                                      style: const TextStyle(
                                        color: Color(0xFF1E56E2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Styled Pill Search Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: searchBg,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: searchBorder, width: 1.0),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: theme.getTextPrimary(), fontSize: 14),
                              decoration: InputDecoration(
                                icon: const Icon(Icons.search_rounded, color: Color(0xFF1E56E2), size: 20),
                                hintText: 'Search doctor by name or code...',
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
                          const SizedBox(height: 14),

                          if (availableDoctors.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(28),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_search_rounded,
                                    size: 36,
                                    color: theme.getTextTertiary(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedType == DailyTourPlanType.field && _selectedBrickId == null
                                        ? 'Please select a territory above'
                                        : 'No doctors found',
                                    style: TextStyle(
                                      color: theme.getTextSecondary(),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isChecked) {
                                          _selectedCustomerIds.remove(docId);
                                        } else {
                                          _selectedCustomerIds.add(docId);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? const Color(0xFF1E56E2).withOpacity(isLight ? 0.08 : 0.2)
                                            : cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isChecked ? const Color(0xFF1E56E2) : cardBorder,
                                          width: isChecked ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Solid Blue Circle Badge
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: isChecked ? const Color(0xFF1E56E2) : Colors.grey.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.medical_services_outlined,
                                              color: Colors.white,
                                              size: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Doctor Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  docName,
                                                  style: TextStyle(
                                                    color: theme.getTextPrimary(),
                                                    fontWeight: isChecked ? FontWeight.bold : FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (doc['customer_code'] != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Code: ${doc['customer_code']}',
                                                    style: TextStyle(
                                                      color: theme.getTextSecondary(),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          // Checkmark Icon
                                          Icon(
                                            isChecked
                                                ? Icons.check_circle_rounded
                                                : Icons.radio_button_unchecked_rounded,
                                            color: isChecked ? const Color(0xFF1E56E2) : theme.getTextTertiary(),
                                            size: 22,
                                          ),
                                        ],
                                      ),
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

                // Sticky Footer Save Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E56E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: const Color(0xFF1E56E2).withOpacity(0.4),
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
                        'Save Daily Tour Plan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final isLight = theme.isLightMode;

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
                ? accentColor.withOpacity(isLight ? 0.12 : 0.25)
                : (isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : (isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A)),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.2) : theme.getContrastColor().withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? accentColor : theme.getTextTertiary(),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
