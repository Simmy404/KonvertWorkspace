import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../managers/theme_manager.dart';
import 'report_view_model.dart';
import '../../models/report_data.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance;
    final isDark = theme.isLightMode == false;

    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => viewModel.refresh(),
              color: const Color(0xFF1E56E2),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Report',
                                style: TextStyle(
                                  color: theme.isLightMode ? const Color(0xFF0022FF) : Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              _buildFilterDropdown(viewModel, theme, isDark),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Professional grade analytics',
                            style: TextStyle(
                              color: theme.getTextSecondary(),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Segmented Control
                          _buildSegmentedControl(viewModel, theme, isDark),
                          const SizedBox(height: 24),

                          if (viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (viewModel.reportData == null)
                            _buildReportsUnavailableFallback(context, theme, isDark, viewModel)
                          else
                            _buildSegmentContent(
                              context,
                              viewModel.reportData!,
                              viewModel.selectedSegment,
                              theme,
                              isDark,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentedControl(ReportViewModel viewModel, ThemeManager theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.getSurfaceColor(),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildSegmentButton('Overview', 0, viewModel, theme, isDark),
          _buildSegmentButton('Sales', 1, viewModel, theme, isDark),
          _buildSegmentButton('Financials', 2, viewModel, theme, isDark),
          _buildSegmentButton('Alerts', 3, viewModel, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index, ReportViewModel viewModel, ThemeManager theme, bool isDark) {
    final isSelected = viewModel.selectedSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setSegment(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
              ? (isDark ? theme.getListItemColor() : Colors.white)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? theme.getTextPrimary() : theme.getTextSecondary(),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    ReportViewModel viewModel,
    ThemeManager theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.getListItemColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.getBorderColor(),
        ),
      ),
      child: DropdownButton<String>(
        value: viewModel.selectedFilter,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: theme.getTextSecondary()),
        dropdownColor: theme.getListItemColor(),
        style: TextStyle(
          color: theme.getTextPrimary(),
          fontWeight: FontWeight.w500,
        ),
        items: const [
          DropdownMenuItem(value: 'today', child: Text('Today')),
          DropdownMenuItem(value: 'week', child: Text('This Week')),
          DropdownMenuItem(value: 'month', child: Text('This Month')),
          DropdownMenuItem(value: 'year', child: Text('This Year')),
          DropdownMenuItem(value: 'all', child: Text('All Time')),
        ],
        onChanged: (val) {
          if (val != null) {
            viewModel.setFilter(val);
          }
        },
      ),
    );
  }

  Widget _buildSegmentContent(BuildContext context, ReportData data, int segment, ThemeManager theme, bool isDark) {
    switch (segment) {
      case 0:
        return _buildOverviewSegment(data, theme, isDark);
      case 1:
        return _buildSalesSegment(data, theme, isDark);
      case 2:
        return _buildFinancialsSegment(data, theme, isDark);
      case 3:
        return _buildAlertsSegment(data, theme, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewSegment(ReportData data, ThemeManager theme, bool isDark) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildKPICard(
                'Net Sales',
                currencyFormat.format(data.metrics.netSales),
                Icons.account_balance_wallet,
                const Color(0xFF1E56E2),
                theme,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildKPICard(
                'Fulfillment Rate',
                '${data.metrics.fulfillmentRate.toStringAsFixed(1)}%',
                Icons.check_circle_outline,
                data.metrics.fulfillmentRate >= 90 ? Colors.green : Colors.orange,
                theme,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildKPICard(
                'Profit Margin',
                '${data.metrics.profitMargin.toStringAsFixed(1)}%',
                Icons.trending_up,
                const Color(0xFF10B981), // Emerald green
                theme,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildKPICard(
                'Active Customers',
                '${data.metrics.activeCustomers}',
                Icons.people_alt_outlined,
                Colors.purple,
                theme,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildWeeklyPerformanceChart(data.weeklyPerformance, theme, isDark),
        const SizedBox(height: 32),
        Text(
          'Gross vs Net Sales Trend',
          style: TextStyle(
            color: theme.getTextPrimary(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTrendChart(data.trend, theme, isDark),
      ],
    );
  }

  Widget _buildWeeklyPerformanceChart(
    WeeklyPerformanceData weekly,
    ThemeManager theme,
    bool isDark,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final threshold = weekly.threshold;

    if (weekly.days.isEmpty) {
      return const SizedBox();
    }

    final maxSales = weekly.days.fold<double>(
      0,
      (m, e) => max(m, e.sales),
    );
    final maxY = max(maxSales, threshold * 1.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Performance vs Company Benchmark',
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Daily performance benchmarked against company average',
              style: TextStyle(
                color: theme.getTextSecondary(),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 260,
          padding: const EdgeInsets.only(right: 20, top: 24, bottom: 12, left: 12),
          decoration: BoxDecoration(
            color: theme.getListItemColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.getBorderColor(),
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY > 0 ? maxY : 1000,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.getBorderColor(),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  if (threshold > 0)
                    HorizontalLine(
                      y: threshold,
                      color: theme.getAccentBlue(),
                      strokeWidth: 2,
                      dashArray: [6, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, bottom: 4),
                        style: TextStyle(
                          color: theme.getAccentBlue(),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) =>
                            'Company Avg: ${currencyFormat.format(line.y)}',
                      ),
                    ),
                ],
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < weekly.days.length) {
                        final day = weekly.days[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            day.day,
                            style: TextStyle(
                              color: theme.getTextSecondary(),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY > 0 ? (maxY / 4) : 1,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        NumberFormat.compact().format(value),
                        style: TextStyle(
                          color: theme.getTextSecondary(),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: weekly.days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;

                Color barColor;
                if (day.status == 'excellent') {
                  barColor = const Color(0xFF86EFAC); // Pastel light green
                } else if (day.status == 'poor') {
                  barColor = const Color(0xFFFCA5A5); // Pastel light red
                } else {
                  barColor = const Color(0xFFCBD5E1); // Light gray
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: day.sales,
                      color: barColor,
                      width: 18,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend Badges Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.getListItemColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.getBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendPill('Poor (< Avg)', const Color(0xFFFCA5A5), theme),
              _buildLegendPill('Good (Near Avg)', const Color(0xFFCBD5E1), theme),
              _buildLegendPill('Excellent (> Avg)', const Color(0xFF86EFAC), theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendPill(String label, Color color, ThemeManager theme) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: theme.getTextSecondary(),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesSegment(ReportData data, ThemeManager theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.topProducts.isNotEmpty) ...[
          Text(
            'Top Products',
            style: TextStyle(
              color: theme.getTextPrimary(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopList(data.topProducts, theme, isDark, isProduct: true),
          const SizedBox(height: 32),
        ],
        if (data.topCustomers.isNotEmpty) ...[
          Text(
            'Top Customers',
            style: TextStyle(
              color: theme.getTextPrimary(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopList(data.topCustomers, theme, isDark, isProduct: false),
          const SizedBox(height: 32),
        ],
        if (data.areaPerformance.isNotEmpty) ...[
          Text(
            'Area Performance',
            style: TextStyle(
              color: theme.getTextPrimary(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopList(data.areaPerformance, theme, isDark, isProduct: false),
          const SizedBox(height: 32),
        ]
      ],
    );
  }

  Widget _buildFinancialsSegment(ReportData data, ThemeManager theme, bool isDark) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFinancialCard(
          'Total Recoveries (Cash)',
          currencyFormat.format(data.financials.totalCollections),
          'Real cash collected and receipted via Journal Vouchers.',
          Icons.payments_outlined,
          const Color(0xFF10B981),
          theme,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFinancialCard(
          'Outstanding Balances (A/R)',
          currencyFormat.format(data.financials.totalOutstanding),
          'Total credit amount pending recovery from assigned customers.',
          Icons.account_balance,
          Colors.orange,
          theme,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFinancialCard(
          'Total Discounts Given',
          currencyFormat.format(data.financials.totalDiscounts),
          'Sum of all discounts provided across all invoices.',
          Icons.money_off,
          Colors.redAccent,
          theme,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFinancialCard(
          'Returned Sales',
          currencyFormat.format(data.metrics.returnedSales),
          'Value of products returned or refunded.',
          Icons.keyboard_return,
          Colors.purpleAccent,
          theme,
          isDark,
        ),
      ],
    );
  }

  Widget _buildAlertsSegment(ReportData data, ThemeManager theme, bool isDark) {
    if (data.expiryAlerts.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No near-expiry stock alerts! 🎉',
          style: TextStyle(
            color: theme.getTextSecondary(),
            fontSize: 16,
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              'Near-Expiry Stock at Risk',
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.getListItemColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.getBorderColor(),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.expiryAlerts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.getBorderColor(),
            ),
            itemBuilder: (context, index) {
              final alert = data.expiryAlerts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  alert.productName,
                  style: TextStyle(
                    color: theme.getTextPrimary(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      'Batch: ${alert.batchNo}',
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Exp: ${alert.expiryDate}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Qty: ${alert.qty}',
                      style: TextStyle(
                        color: theme.getTextPrimary(),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      currencyFormat.format(alert.value),
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildFinancialCard(String title, String value, String description, IconData icon, Color iconColor, ThemeManager theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),

      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.getTextSecondary(),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: theme.getTextPrimary(),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.getTextSecondary(),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeManager theme,
    bool isDark,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.getTextSecondary(),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(
    List<ChartDataPoint> trend,
    ThemeManager theme,
    bool isDark,
  ) {
    if (trend.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.getListItemColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.getBorderColor(),
          ),
        ),
        child: Center(
          child: Text(
            'No sales data for this period',
            style: TextStyle(color: theme.getTextSecondary()),
          ),
        ),
      );
    }

    final maxGross = trend.map((e) => e.grossSales).fold<double>(0, (m, e) => max(m, e));
    final maxNet = trend.map((e) => e.netSales).fold<double>(0, (m, e) => max(m, e));
    final maxY = max(maxGross, maxNet);

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 24, top: 24, bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),

      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.getBorderColor(),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= trend.length) {
                    return const SizedBox();
                  }
                  final label = trend[value.toInt()].label;
                  String displayLabel = label;
                  if (label.length >= 10) {
                    displayLabel = label.substring(8, 10);
                  }

                  if (trend.length > 7 &&
                      value.toInt() % (trend.length ~/ 5) != 0) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 0 ? (maxY / 4) : 1,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
                    style: TextStyle(
                      color: theme.getTextSecondary(),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (trend.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.grossSales);
              }).toList(),
              isCurved: true,
              color: const Color(0xFF94A3B8), // Gray for gross
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.netSales);
              }).toList(),
              isCurved: true,
              color: const Color(0xFF1E56E2), // Blue for net
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF1E56E2).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsUnavailableFallback(
    BuildContext context,
    ThemeManager theme,
    bool isDark,
    ReportViewModel viewModel,
  ) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon badge
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9))
                      .withOpacity(isDark ? 1.0 : 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.bar_chart_outlined,
                  size: 40,
                  color: theme.getTextTertiary(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reports not available',
                style: TextStyle(
                  color: theme.getTextPrimary(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We couldn\'t reach the reports server.\nThis may be a network issue or the server is temporarily unavailable.',
                style: TextStyle(
                  color: theme.getTextSecondary(),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => viewModel.refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E56E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopList(
    List<TopEntity> items,
    ThemeManager theme,
    bool isDark, {
    required bool isProduct,
  }) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),

      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.getBorderColor(),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final hasReturns = item.returnedTotal > 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E56E2).withOpacity(0.1),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF1E56E2),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                color: theme.getTextPrimary(),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isProduct && item.qty != null)
                  Text(
                    'Qty: ${item.qty}',
                    style: TextStyle(
                      color: theme.getTextSecondary(),
                      fontSize: 12,
                    ),
                  ),
                if (isProduct && item.qty != null && hasReturns)
                  const SizedBox(width: 8),
                if (hasReturns)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Returns: ${currencyFormat.format(item.returnedTotal)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(item.netTotal),
                  style: TextStyle(
                    color: theme.getTextPrimary(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (hasReturns)
                  Text(
                    currencyFormat.format(item.grossTotal),
                    style: TextStyle(
                      color: theme.getTextSecondary(),
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
