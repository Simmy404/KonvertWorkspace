import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../managers/theme_manager.dart';
import '../tour_plan_view_model.dart';

class BrickDoctorPicker extends StatefulWidget {
  final int dayIndex;

  const BrickDoctorPicker({super.key, required this.dayIndex});

  @override
  State<BrickDoctorPicker> createState() => _BrickDoctorPickerState();
}

class _BrickDoctorPickerState extends State<BrickDoctorPicker> {
  String? _selectedBrickId;
  String? _selectedBrickName;
  List<String> _selectedDoctorIds = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase().trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();
    final theme = ThemeManager.instance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: theme.getBorderColor()),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.getBorderColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                if (_selectedBrickId != null) ...[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.getTextPrimary(),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedBrickId = null;
                        _selectedBrickName = null;
                        _selectedDoctorIds.clear();
                        _clearSearch();
                      });
                    },
                    tooltip: 'Back to Areas',
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBrickId == null
                            ? 'Select Area (Brick)'
                            : _selectedBrickName ?? 'Select Doctors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.getTextPrimary(),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        _selectedBrickId == null
                            ? 'Step 1 of 2: Choose target territory'
                            : 'Step 2 of 2: Pick doctors for visit',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.getTextSecondary(),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.getTextSecondary(),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.getBorderColor()),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: theme.getSurfaceColor(),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.getBorderColor()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: theme.getTextTertiary(),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: theme.getTextPrimary(),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: _selectedBrickId == null
                            ? 'Search territory name...'
                            : 'Search doctor name or address...',
                        hintStyle: TextStyle(
                          color: theme.getTextTertiary(),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.getTextTertiary(),
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _selectedBrickId == null
                ? _buildBrickList(viewModel, theme)
                : _buildDoctorList(viewModel, theme),
          ),

          // Footer (Save Button)
          if (_selectedBrickId != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.getContainerColor(),
                border: Border(top: BorderSide(color: theme.getBorderColor())),
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _selectedDoctorIds.isEmpty
                        ? null
                        : () {
                            viewModel.updateFieldWorkSelection(
                              widget.dayIndex,
                              _selectedBrickId!,
                              _selectedDoctorIds,
                            );
                            Navigator.pop(context);
                          },
                    child: Text(
                      _selectedDoctorIds.isEmpty
                          ? 'Select at least 1 Doctor'
                          : 'Confirm ${_selectedDoctorIds.length} ${_selectedDoctorIds.length == 1 ? 'Doctor' : 'Doctors'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrickList(TourPlanViewModel viewModel, ThemeManager theme) {
    var bricks = viewModel.allBricks;
    if (_searchQuery.isNotEmpty) {
      bricks = bricks.where((b) {
        final name = (b['brick_name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery);
      }).toList();
    }

    if (bricks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: theme.getTextTertiary(),
            ),
            const SizedBox(height: 8),
            Text(
              'No areas found matching "$_searchQuery"',
              style: TextStyle(color: theme.getTextSecondary(), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: bricks.length,
      itemBuilder: (context, index) {
        final brick = bricks[index];
        final brickId = brick['brick_id'].toString();
        final brickName = brick['brick_name'] ?? 'Unknown Brick';
        final doctorCount = (viewModel.customersByBrick[brickId] ?? []).length;

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.getListItemColor(),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.getBorderColor()),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedBrickId = brickId;
                  _selectedBrickName = brickName;
                  _clearSearch();
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.getSurfaceColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: theme.getAccentBlue(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brickName,
                            style: TextStyle(
                              color: theme.getTextPrimary(),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$doctorCount ${doctorCount == 1 ? 'Doctor' : 'Doctors'} available',
                            style: TextStyle(
                              color: theme.getTextSecondary(),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.getAccentBlue().withOpacity(
                          theme.isLightMode ? 0.08 : 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.getAccentBlue(),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorList(TourPlanViewModel viewModel, ThemeManager theme) {
    var doctors = viewModel.customersByBrick[_selectedBrickId] ?? [];
    if (_searchQuery.isNotEmpty) {
      doctors = doctors.where((d) {
        final name = (d['customer_name'] ?? '').toString().toLowerCase();
        final addr = (d['customer_address'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) || addr.contains(_searchQuery);
      }).toList();
    }

    final allDoctorIds = doctors
        .map((d) => d['customer_id'].toString())
        .toList();
    final areAllSelected =
        doctors.isNotEmpty &&
        allDoctorIds.every((id) => _selectedDoctorIds.contains(id));

    return Column(
      children: [
        // Quick Select Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${doctors.length} doctors found',
                style: TextStyle(color: theme.getTextSecondary(), fontSize: 12),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (areAllSelected) {
                          _selectedDoctorIds.removeWhere(
                            (id) => allDoctorIds.contains(id),
                          );
                        } else {
                          for (var id in allDoctorIds) {
                            if (!_selectedDoctorIds.contains(id)) {
                              _selectedDoctorIds.add(id);
                            }
                          }
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.getAccentBlue(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      areAllSelected ? 'Deselect All' : 'Select All',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (doctors.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 40,
                    color: theme.getTextTertiary(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No doctors found in this area.',
                    style: TextStyle(
                      color: theme.getTextSecondary(),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doc = doctors[index];
                final docId = doc['customer_id'].toString();
                final docName = doc['customer_name'] ?? 'Unknown Doctor';
                final docAddr = doc['customer_address']?.toString() ?? '';
                final isSelected = _selectedDoctorIds.contains(docId);
                final type = doc['customer_type']?.toString() ?? '';
                final isDoctor =
                    type.toLowerCase().contains('doctor') || type == '2';

                return Material(
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.getAccentBlue().withOpacity(
                              theme.isLightMode ? 0.06 : 0.15,
                            )
                          : theme.getListItemColor(),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? theme.getAccentBlue().withOpacity(0.5)
                            : theme.getBorderColor(),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDoctorIds.remove(docId);
                          } else {
                            _selectedDoctorIds.add(docId);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: theme.getAccentBlue(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedDoctorIds.add(docId);
                                  } else {
                                    _selectedDoctorIds.remove(docId);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          docName,
                                          style: TextStyle(
                                            color: theme.getTextPrimary(),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDoctor
                                              ? (theme.isLightMode
                                                    ? const Color(0xFFF3E8FF)
                                                    : const Color(0xFF38154D))
                                              : (theme.isLightMode
                                                    ? const Color(0xFFDCFCE7)
                                                    : const Color(0xFF12382B)),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          isDoctor ? 'Doctor' : 'Chemist',
                                          style: TextStyle(
                                            color: isDoctor
                                                ? const Color(0xFFA855F7)
                                                : const Color(0xFF16A34A),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (docAddr.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      docAddr,
                                      style: TextStyle(
                                        color: theme.getTextSecondary(),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
