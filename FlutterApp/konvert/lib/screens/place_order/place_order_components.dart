import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../managers/location_manager.dart';
import 'place_order_state.dart';

class PlaceOrderComponents {
  static Widget buildLocationMapCard(PlaceOrderState state, bool isDark) {
    return Consumer<LocationManager>(
      builder: (context, locManager, child) {
        final pos = locManager.currentPosition;
        final hasLocation = pos != null;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1437) : const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E2D68) : const Color(0xFFB8D5FF),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF003087).withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13235A) : const Color(0xFFD6E6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF1E56E2),
                  size: 20,
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
                          'User Location',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
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
                  color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                  size: 18,
                ),
                tooltip: 'Refresh Location',
              ),
            ],
          ),
        );
      }
    );
  }

  static InputDecoration buildSearchDecoration(String hint, bool isDark, VoidCallback onClear) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
        fontSize: 12,
      ),
      prefixIcon: Icon(
        Icons.search_rounded,
        size: 16,
        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          Icons.clear_rounded,
          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          size: 14,
        ),
        onPressed: onClear,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF121318) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  static Widget buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 36,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildDialogInput(String label, String initialValue, Function(String) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: initialValue)
          ..selection = TextSelection.collapsed(offset: initialValue.length),
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
            fontSize: 11,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
