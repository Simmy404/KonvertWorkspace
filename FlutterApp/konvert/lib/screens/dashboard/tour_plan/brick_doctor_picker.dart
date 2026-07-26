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
  List<String> _selectedDoctorIds = [];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TourPlanViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: ThemeManager.instance.getAppBackgroundColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBrickId == null ? 'Select Area (Brick)' : 'Select Doctors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.instance.getTextPrimary(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: ThemeManager.instance.getTextSecondary()),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _selectedBrickId == null
                ? _buildBrickList(viewModel)
                : _buildDoctorList(viewModel),
          ),

          // Footer (Save Button)
          if (_selectedBrickId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E56E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  child: Text('Confirm Selection (${_selectedDoctorIds.length})'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrickList(TourPlanViewModel viewModel) {
    if (viewModel.allBricks.isEmpty) {
      return Center(
        child: Text(
          'No areas available',
          style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.allBricks.length,
      itemBuilder: (context, index) {
        final brick = viewModel.allBricks[index];
        final brickId = brick['brick_id'].toString();
        final brickName = brick['brick_name'] ?? 'Unknown Brick';

        return ListTile(
          title: Text(
            brickName,
            style: TextStyle(color: ThemeManager.instance.getTextPrimary()),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            setState(() {
              _selectedBrickId = brickId;
            });
          },
        );
      },
    );
  }

  Widget _buildDoctorList(TourPlanViewModel viewModel) {
    final doctors = viewModel.customersByBrick[_selectedBrickId] ?? [];

    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No doctors available in this area.',
              style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedBrickId = null;
                });
              },
              child: const Text('Back to Areas'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedBrickId = null;
                _selectedDoctorIds.clear();
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to Areas'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final docId = doc['customer_id'].toString();
              final docName = doc['customer_name'] ?? 'Unknown Doctor';
              final isSelected = _selectedDoctorIds.contains(docId);

              return CheckboxListTile(
                value: isSelected,
                activeColor: const Color(0xFF1E56E2),
                title: Text(
                  docName,
                  style: TextStyle(color: ThemeManager.instance.getTextPrimary()),
                ),
                onChanged: (bool? val) {
                  setState(() {
                    if (val == true) {
                      _selectedDoctorIds.add(docId);
                    } else {
                      _selectedDoctorIds.remove(docId);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
