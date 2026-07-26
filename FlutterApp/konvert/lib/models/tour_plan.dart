import 'dart:convert';

enum TourPlanStatus { draft, pending, approved, rejected }
enum DailyTourPlanType { off, remote, field }

class DailyTourPlan {
  final DateTime date;
  final DailyTourPlanType type;
  final String? brickId; // Only for field
  final List<String> customerIds; // Only for field (or pseudo-random for remote)

  DailyTourPlan({
    required this.date,
    required this.type,
    this.brickId,
    this.customerIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'type': type.name,
      'brickId': brickId,
      'customerIds': customerIds,
    };
  }

  factory DailyTourPlan.fromMap(Map<String, dynamic> map) {
    return DailyTourPlan(
      date: DateTime.parse(map['date']),
      type: DailyTourPlanType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DailyTourPlanType.off,
      ),
      brickId: map['brickId'],
      customerIds: List<String>.from(map['customerIds'] ?? []),
    );
  }

  DailyTourPlan copyWith({
    DateTime? date,
    DailyTourPlanType? type,
    String? brickId,
    List<String>? customerIds,
  }) {
    return DailyTourPlan(
      date: date ?? this.date,
      type: type ?? this.type,
      brickId: brickId ?? this.brickId,
      customerIds: customerIds ?? this.customerIds,
    );
  }
}

class WeeklyTourPlan {
  final List<DailyTourPlan> days;

  WeeklyTourPlan({required this.days});

  Map<String, dynamic> toMap() {
    return {
      'days': days.map((x) => x.toMap()).toList(),
    };
  }

  factory WeeklyTourPlan.fromMap(Map<String, dynamic> map) {
    return WeeklyTourPlan(
      days: List<DailyTourPlan>.from(
        (map['days'] as List<dynamic>).map<DailyTourPlan>(
          (x) => DailyTourPlan.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class MonthlyTourPlan {
  final TourPlanStatus status;
  final List<WeeklyTourPlan> weeks;

  MonthlyTourPlan({
    required this.status,
    required this.weeks,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'weeks': weeks.map((x) => x.toMap()).toList(),
    };
  }

  factory MonthlyTourPlan.fromMap(Map<String, dynamic> map) {
    return MonthlyTourPlan(
      status: TourPlanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TourPlanStatus.draft,
      ),
      weeks: List<WeeklyTourPlan>.from(
        (map['weeks'] as List<dynamic>).map<WeeklyTourPlan>(
          (x) => WeeklyTourPlan.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MonthlyTourPlan.fromJson(String source) =>
      MonthlyTourPlan.fromMap(json.decode(source));
}
