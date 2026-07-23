// lib/screens/explore_features_sheet.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';

class FeatureItem {
  final String title;
  final List<Color> gradientColors;

  const FeatureItem({
    required this.title,
    required this.gradientColors,
  });
}

class ExploreFeaturesSheet extends StatefulWidget {
  const ExploreFeaturesSheet({super.key});

  @override
  State<ExploreFeaturesSheet> createState() => _ExploreFeaturesSheetState();
}

class _ExploreFeaturesSheetState extends State<ExploreFeaturesSheet> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<FeatureItem> _features = const [
    FeatureItem(
      title: 'Better reports\nusing AI',
      gradientColors: [
        Color(0xFFF3E9DF),
        Color(0xFF8C7B74),
        Color(0xFF1F1A18),
        Color(0xFF0A0908),
      ],
    ),
    FeatureItem(
      title: 'Real-time\nSales Tracking',
      gradientColors: [
        Color(0xFFF0E6FE),
        Color(0xFF7E52A0),
        Color(0xFF241038),
        Color(0xFF0D0418),
      ],
    ),
    FeatureItem(
      title: 'Automated\nTeam Management',
      gradientColors: [
        Color(0xFFFDE8EB),
        Color(0xFFB54C64),
        Color(0xFF381019),
        Color(0xFF140307),
      ],
    ),
    FeatureItem(
      title: 'Instant\nOffline Syncing',
      gradientColors: [
        Color(0xFFE3F7EB),
        Color(0xFF4A916B),
        Color(0xFF113624),
        Color(0xFF04140D),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onNextPage() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;

    // Theme adaptive colors matching design mockup
    final sheetGradient = isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD7EEFC),
              Color(0xFFECF6FD),
              Color(0xFFF8FCFF),
            ],
            stops: [0.0, 0.55, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF080D26),
              Color(0xFF040614),
              Color(0xFF010206),
            ],
            stops: [0.0, 0.55, 1.0],
          );

    final handleColor = isLight ? const Color(0xFF7A8B99) : const Color(0xFFE2E8F0);
    final titleColor = isLight ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final subtitleColor = isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final buttonBg = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1F2937);
    final buttonIconColor = isLight ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        gradient: sheetGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag handle bar
              Center(
                child: Container(
                  width: 54,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Features',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'State of the art features designed to\nmaximize your sales.',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Carousel Section
              SizedBox(
                height: 350,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _features.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _features[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: item.gradientColors,
                            stops: const [0.0, 0.45, 0.8, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. Navigation Buttons (Left & Right arrows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button
                  GestureDetector(
                    onTap: _onPreviousPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: buttonBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        color: buttonIconColor,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Next Button
                  GestureDetector(
                    onTap: _onNextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: buttonBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: buttonIconColor,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
