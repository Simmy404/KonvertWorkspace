import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/location_manager.dart';
import 'place_order_state.dart';
import '../../managers/theme_manager.dart';

class PlaceOrderComponents {
  static Widget buildLocationMapCard(PlaceOrderState state) {
    return Consumer<LocationManager>(
      builder: (context, locManager, child) {
        final pos = locManager.currentPosition;
        final hasLocation = pos != null;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeManager.instance.getContainerColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeManager.instance.getBorderColor(),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeManager.instance.isLightMode ? const Color(0xFF003087).withOpacity(0.06) : Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ThemeManager.instance.getSurfaceColor(),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF1E56E2),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'User GPS Location',
                          style: TextStyle(
                            color: ThemeManager.instance.getTextPrimary(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: hasLocation ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasLocation ? 'Active GPS' : 'Locating...',
                          style: TextStyle(
                            color: hasLocation ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLocation
                          ? 'Lat: ${pos.latitude.toStringAsFixed(5)}°, Long: ${pos.longitude.toStringAsFixed(5)}°'
                          : 'Fetching GPS coordinates...',
                      style: TextStyle(
                        color: ThemeManager.instance.getTextSecondary(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  LocationManager.instance.fetchCurrentLocation(forceUpdate: true);
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ThemeManager.instance.getAccentBlue(),
                  size: 18,
                ),
                tooltip: 'Refresh Location',
              ),
            ],
          ),
        );
      },
    );
  }

  static InputDecoration buildSearchDecoration(String hint, VoidCallback onClear) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: ThemeManager.instance.getTextTertiary(),
        fontSize: 12,
      ),
      prefixIcon: Icon(
        Icons.search_rounded,
        size: 16,
        color: ThemeManager.instance.getTextTertiary(),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          Icons.clear_rounded,
          color: ThemeManager.instance.getTextTertiary(),
          size: 14,
        ),
        onPressed: onClear,
      ),
      filled: true,
      fillColor: ThemeManager.instance.getContainerColor(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ThemeManager.instance.getBorderColor(),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ThemeManager.instance.getBorderColor(),
        ),
      ),
    );
  }

  static Widget buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeManager.instance.getAccentBlue()
              : ThemeManager.instance.getContainerColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ThemeManager.instance.getAccentBlue()
                : ThemeManager.instance.getBorderColor(),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E56E2).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: isSelected
                    ? Colors.white
                    : ThemeManager.instance.getTextSecondary(),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : ThemeManager.instance.getTextSecondary(),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: ThemeManager.instance.getDividerColor(),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: ThemeManager.instance.getTextSecondary(),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildDialogInput(
    String label,
    String initialValue,
    Function(String) onChanged, {
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        autofocus: autofocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: initialValue)
          ..selection = TextSelection(baseOffset: 0, extentOffset: initialValue.length),
        onChanged: onChanged,
        style: TextStyle(
          color: ThemeManager.instance.getTextPrimary(),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: ThemeManager.instance.getTextSecondary(),
            fontSize: 11,
          ),
          filled: true,
          fillColor: ThemeManager.instance.getSurfaceColor(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemeManager.instance.getBorderColor(),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemeManager.instance.getBorderColor(),
            ),
          ),
        ),
      ),
    );
  }

}
