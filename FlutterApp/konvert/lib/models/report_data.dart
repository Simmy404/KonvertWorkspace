class ReportMetrics {
  final double grossSales;
  final double netSales;
  final double returnedSales;
  final int totalOrders;
  final int activeCustomers;
  final double fulfillmentRate;
  final double profitMargin;
  final double target;

  ReportMetrics({
    required this.grossSales,
    required this.netSales,
    required this.returnedSales,
    required this.totalOrders,
    required this.activeCustomers,
    required this.fulfillmentRate,
    required this.profitMargin,
    required this.target,
  });

  factory ReportMetrics.fromJson(Map<String, dynamic> json) {
    return ReportMetrics(
      grossSales: (json['gross_sales'] as num?)?.toDouble() ?? 0.0,
      netSales: (json['net_sales'] as num?)?.toDouble() ?? 0.0,
      returnedSales: (json['returned_sales'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      activeCustomers: (json['active_customers'] as num?)?.toInt() ?? 0,
      fulfillmentRate: (json['fulfillment_rate'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0.0,
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Financials {
  final double totalOutstanding;
  final double totalDiscounts;
  final double totalCollections;

  Financials({
    required this.totalOutstanding, 
    required this.totalDiscounts,
    required this.totalCollections,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble() ?? 0.0,
      totalDiscounts: (json['total_discounts'] as num?)?.toDouble() ?? 0.0,
      totalCollections: (json['total_collections'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChartDataPoint {
  final String label;
  final double grossSales;
  final double netSales;
  final int orders;

  ChartDataPoint({
    required this.label,
    required this.grossSales,
    required this.netSales,
    required this.orders,
  });

  factory ChartDataPoint.fromTrendJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['date'] ?? '',
      grossSales: (json['gross_sales'] as num?)?.toDouble() ?? 0.0,
      netSales: (json['net_sales'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopEntity {
  final String id;
  final String name;
  final double grossTotal;
  final double netTotal;
  final double returnedTotal;
  final int? qty;

  TopEntity({
    required this.id,
    required this.name,
    required this.grossTotal,
    required this.netTotal,
    required this.returnedTotal,
    this.qty,
  });

  factory TopEntity.fromJson(Map<String, dynamic> json) {
    return TopEntity(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      grossTotal:
          (json['gross_total'] as num?)?.toDouble() ??
          ((json['total'] as num?)?.toDouble() ?? 0.0),
      netTotal: (json['total'] as num?)?.toDouble() ?? 0.0,
      returnedTotal: (json['returned_total'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toInt(),
    );
  }
}

class ExpiryAlert {
  final String productName;
  final String batchNo;
  final String expiryDate;
  final int qty;
  final double value;
  final String customerName;

  ExpiryAlert({
    required this.productName,
    required this.batchNo,
    required this.expiryDate,
    required this.qty,
    required this.value,
    required this.customerName,
  });

  factory ExpiryAlert.fromJson(Map<String, dynamic> json) {
    return ExpiryAlert(
      productName: json['product_name'] ?? 'Unknown',
      batchNo: json['batch_no'] ?? 'N/A',
      expiryDate: json['expiry_date'] ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customer_name'] ?? 'Unknown',
    );
  }
}

class WeeklyPerformanceDay {
  final String day;
  final String date;
  final double sales;
  final String status; // 'poor', 'good', 'excellent'

  WeeklyPerformanceDay({
    required this.day,
    required this.date,
    required this.sales,
    required this.status,
  });

  factory WeeklyPerformanceDay.fromJson(Map<String, dynamic> json) {
    return WeeklyPerformanceDay(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'good',
    );
  }
}

class WeeklyPerformanceData {
  final double threshold;
  final List<WeeklyPerformanceDay> days;

  WeeklyPerformanceData({
    required this.threshold,
    required this.days,
  });

  factory WeeklyPerformanceData.fromJson(Map<String, dynamic> json) {
    final daysList = (json['days'] as List<dynamic>?) ?? [];
    return WeeklyPerformanceData(
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      days: daysList.map((e) => WeeklyPerformanceDay.fromJson(e)).toList(),
    );
  }
}

class ReportData {
  final ReportMetrics metrics;
  final Financials financials;
  final List<ChartDataPoint> trend;
  final List<TopEntity> topProducts;
  final List<TopEntity> topCustomers;
  final List<TopEntity> areaPerformance;
  final List<ExpiryAlert> expiryAlerts;
  final WeeklyPerformanceData weeklyPerformance;

  ReportData({
    required this.metrics,
    required this.financials,
    required this.trend,
    required this.topProducts,
    required this.topCustomers,
    required this.areaPerformance,
    required this.expiryAlerts,
    required this.weeklyPerformance,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    final metricsJson = json['metrics'] as Map<String, dynamic>? ?? {};
    final financialsJson = json['financials'] as Map<String, dynamic>? ?? {};

    final trendList = (json['trend'] as List<dynamic>?) ?? [];
    final trend = trendList
        .map((e) => ChartDataPoint.fromTrendJson(e))
        .toList();

    final productsList = (json['top_products'] as List<dynamic>?) ?? [];
    final topProducts = productsList.map((e) => TopEntity.fromJson(e)).toList();

    final customersList = (json['top_customers'] as List<dynamic>?) ?? [];
    final topCustomers = customersList
        .map((e) => TopEntity.fromJson(e))
        .toList();

    final areaList = (json['area_performance'] as List<dynamic>?) ?? [];
    final areaPerformance = areaList.map((e) => TopEntity.fromJson(e)).toList();

    final alertsList = (json['expiry_alerts'] as List<dynamic>?) ?? [];
    final expiryAlerts = alertsList.map((e) => ExpiryAlert.fromJson(e)).toList();

    final weeklyJson = json['weekly_performance'] as Map<String, dynamic>? ?? {};
    final weeklyPerformance = WeeklyPerformanceData.fromJson(weeklyJson);

    return ReportData(
      metrics: ReportMetrics.fromJson(metricsJson),
      financials: Financials.fromJson(financialsJson),
      trend: trend,
      topProducts: topProducts,
      topCustomers: topCustomers,
      areaPerformance: areaPerformance,
      expiryAlerts: expiryAlerts,
      weeklyPerformance: weeklyPerformance,
    );
  }
}
