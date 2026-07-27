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
        final theme = ThemeManager.instance;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.getListItemColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.getBorderColor(),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.getSurfaceColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: theme.getAccentBlue(),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'GPS Location',
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: hasLocation ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasLocation ? 'Active' : 'Locating...',
                          style: TextStyle(
                            color: hasLocation ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            fontSize: 11,
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
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () {
                  LocationManager.instance.fetchCurrentLocation(forceUpdate: true);
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.getAccentBlue(),
                  size: 20,
                ),
                tooltip: 'Refresh Location',
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a pill-rounded search bar matching BookingsScreen & NotificationsScreen.
  static Widget buildSearchBar({
    required TextEditingController controller,
    required Function(String) onChanged,
    required String hint,
    required VoidCallback onClear,
    bool enabled = true,
  }) {
    final theme = ThemeManager.instance;
    final isLight = theme.isLightMode;

    final searchBgColor = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF0E1426);
    final searchBorderColor = isLight ? const Color(0xFFD4E2FE) : const Color(0xFF252C40);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: searchBgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: searchBorderColor,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.getTextSecondary(),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enabled: enabled,
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: theme.getTextSecondary().withOpacity(0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onClear();
              },
              child: Icon(
                Icons.close_rounded,
                color: theme.getTextTertiary(),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  /// Legacy search decoration for backward compat
  static InputDecoration buildSearchDecoration(String hint, VoidCallback onClear) {
    final theme = ThemeManager.instance;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.getTextSecondary(),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        Icons.search_rounded,
        size: 22,
        color: theme.getTextTertiary(),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          Icons.clear_rounded,
          color: theme.getTextTertiary(),
          size: 20,
        ),
        onPressed: onClear,
      ),
      filled: true,
      fillColor: theme.getSurfaceColor(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: theme.getBorderColor(),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: theme.getBorderColor(),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: theme.getAccentBlue(),
          width: 1.5,
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
    final theme = ThemeManager.instance;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.getAccentBlue()
              : theme.getContainerColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.getAccentBlue()
                : theme.getBorderColor(),
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
                size: 14,
                color: isSelected
                    ? Colors.white
                    : theme.getTextSecondary(),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.getTextSecondary(),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState(String message) {
    final theme = ThemeManager.instance;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: theme.getTextTertiary(),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: theme.getTextSecondary(),
              fontSize: 16,
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
    final theme = ThemeManager.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        autofocus: autofocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: initialValue)
          ..selection = TextSelection(baseOffset: 0, extentOffset: initialValue.length),
        onChanged: onChanged,
        style: TextStyle(
          color: theme.getTextPrimary(),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.getTextSecondary(),
            fontSize: 13,
          ),
          filled: true,
          fillColor: theme.getSurfaceColor(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.getBorderColor(),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.getBorderColor(),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.getAccentBlue(),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
