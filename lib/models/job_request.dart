import 'service_category.dart';

enum JobStatus { submitted, assigned, onTheWay, completed, cancelled }

extension JobStatusX on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.submitted:
        return 'Submitted';
      case JobStatus.assigned:
        return 'Provider assigned';
      case JobStatus.onTheWay:
        return 'On the way';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  static JobStatus fromName(String name) =>
      JobStatus.values.firstWhere((s) => s.name == name);
}

enum PreferredDay { today, tomorrow }

extension PreferredDayX on PreferredDay {
  String get label => this == PreferredDay.today ? 'Today' : 'Tomorrow';

  static PreferredDay fromName(String name) =>
      PreferredDay.values.firstWhere((d) => d.name == name);
}

enum PreferredSlot { morning, afternoon, evening }

extension PreferredSlotX on PreferredSlot {
  String get label {
    switch (this) {
      case PreferredSlot.morning:
        return 'Morning';
      case PreferredSlot.afternoon:
        return 'Afternoon';
      case PreferredSlot.evening:
        return 'Evening';
    }
  }

  static PreferredSlot fromName(String name) =>
      PreferredSlot.values.firstWhere((s) => s.name == name);
}

/// The 4 linear tracker steps, in order. [JobStatus.cancelled] is a separate
/// terminal state shown as a banner instead of a tracker position.
const List<JobStatus> trackerSteps = [
  JobStatus.submitted,
  JobStatus.assigned,
  JobStatus.onTheWay,
  JobStatus.completed,
];

class JobRequest {
  final String id;
  final String code;
  final ServiceCategory category;
  final String description;
  final String? photoPath;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String area;
  final PreferredDay preferredDay;
  final PreferredSlot preferredSlot;
  final DateTime createdAt;

  JobStatus status;
  String? assignedProviderId;
  String? assignedProviderName;
  String? assignedProviderPhone;
  DateTime? assignedAt;
  DateTime? onTheWayAt;
  DateTime? completedAt;
  DateTime? cancelledAt;

  JobRequest({
    required this.id,
    required this.code,
    required this.category,
    required this.description,
    this.photoPath,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.area,
    required this.preferredDay,
    required this.preferredSlot,
    required this.createdAt,
    this.status = JobStatus.submitted,
    this.assignedProviderId,
    this.assignedProviderName,
    this.assignedProviderPhone,
    this.assignedAt,
    this.onTheWayAt,
    this.completedAt,
    this.cancelledAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'category': category.name,
        'description': description,
        'photoPath': photoPath,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'address': address,
        'area': area,
        'preferredDay': preferredDay.name,
        'preferredSlot': preferredSlot.name,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'assignedProviderId': assignedProviderId,
        'assignedProviderName': assignedProviderName,
        'assignedProviderPhone': assignedProviderPhone,
        'assignedAt': assignedAt?.toIso8601String(),
        'onTheWayAt': onTheWayAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
      };

  factory JobRequest.fromJson(Map<String, dynamic> json) => JobRequest(
        id: json['id'] as String,
        code: json['code'] as String,
        category: ServiceCategoryX.fromName(json['category'] as String),
        description: json['description'] as String,
        photoPath: json['photoPath'] as String?,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        customerPhone: json['customerPhone'] as String,
        address: json['address'] as String,
        area: json['area'] as String,
        preferredDay: PreferredDayX.fromName(json['preferredDay'] as String),
        preferredSlot: PreferredSlotX.fromName(json['preferredSlot'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: JobStatusX.fromName(json['status'] as String),
        assignedProviderId: json['assignedProviderId'] as String?,
        assignedProviderName: json['assignedProviderName'] as String?,
        assignedProviderPhone: json['assignedProviderPhone'] as String?,
        assignedAt: json['assignedAt'] == null ? null : DateTime.parse(json['assignedAt'] as String),
        onTheWayAt: json['onTheWayAt'] == null ? null : DateTime.parse(json['onTheWayAt'] as String),
        completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
        cancelledAt: json['cancelledAt'] == null ? null : DateTime.parse(json['cancelledAt'] as String),
      );
}
