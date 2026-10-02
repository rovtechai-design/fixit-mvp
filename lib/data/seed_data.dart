import '../models/customer.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../models/service_provider.dart';
import '../models/trade.dart';

class SeedResult {
  final List<Customer> customers;
  final List<ServiceProvider> providers;
  final List<JobRequest> jobs;
  final int jobSeq;

  SeedResult({
    required this.customers,
    required this.providers,
    required this.jobs,
    required this.jobSeq,
  });
}

SeedResult buildSeedData() {
  final now = DateTime.now();

  final customers = [
    Customer(
      id: 'seed-cust-1',
      name: 'Priya Sharma',
      phone: '9820011223',
      flat: 'Flat 302',
      building: 'Sunrise Apartments',
      area: 'Andheri West',
      createdAt: now.subtract(const Duration(days: 20)),
    ),
    Customer(
      id: 'seed-cust-2',
      name: 'Rahul Mehta',
      phone: '9833044556',
      flat: 'B-12',
      building: 'Green Valley',
      area: 'Powai',
      createdAt: now.subtract(const Duration(days: 14)),
    ),
  ];

  final providers = [
    ServiceProvider(
      id: 'seed-prov-1',
      name: 'Suresh Kumar',
      phone: '9900011122',
      trade: Trade.plumber,
      createdAt: now.subtract(const Duration(days: 40)),
    ),
    ServiceProvider(
      id: 'seed-prov-2',
      name: 'Anita Rao',
      phone: '9900022233',
      trade: Trade.electrician,
      createdAt: now.subtract(const Duration(days: 35)),
    ),
    ServiceProvider(
      id: 'seed-prov-3',
      name: 'Vikram Singh',
      phone: '9900033344',
      trade: Trade.acTechnician,
      createdAt: now.subtract(const Duration(days: 30)),
    ),
    ServiceProvider(
      id: 'seed-prov-4',
      name: 'Lakshmi Nair',
      phone: '9900044455',
      trade: Trade.cleaner,
      createdAt: now.subtract(const Duration(days: 25)),
    ),
  ];

  final jobs = [
    JobRequest(
      id: 'seed-job-1',
      code: 'FX-1031',
      category: ServiceCategory.plumbing,
      description: 'Kitchen tap leaking continuously, water pooling under the sink.',
      customerId: customers[0].id,
      customerName: customers[0].name,
      customerPhone: customers[0].phone,
      address: customers[0].address,
      area: customers[0].area,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.morning,
      createdAt: now.subtract(const Duration(days: 3)),
      status: JobStatus.completed,
      assignedProviderId: providers[0].id,
      assignedProviderName: providers[0].name,
      assignedProviderPhone: providers[0].phone,
      assignedAt: now.subtract(const Duration(days: 3, hours: -1)),
      onTheWayAt: now.subtract(const Duration(days: 3, hours: -2)),
      completedAt: now.subtract(const Duration(days: 3, hours: -3)),
    ),
    JobRequest(
      id: 'seed-job-2',
      code: 'FX-1032',
      category: ServiceCategory.electrical,
      description: 'Power socket sparking in the living room when the AC is plugged in.',
      customerId: customers[1].id,
      customerName: customers[1].name,
      customerPhone: customers[1].phone,
      address: customers[1].address,
      area: customers[1].area,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.afternoon,
      createdAt: now.subtract(const Duration(hours: 5)),
      status: JobStatus.onTheWay,
      assignedProviderId: providers[1].id,
      assignedProviderName: providers[1].name,
      assignedProviderPhone: providers[1].phone,
      assignedAt: now.subtract(const Duration(hours: 4)),
      onTheWayAt: now.subtract(const Duration(hours: 1)),
    ),
    JobRequest(
      id: 'seed-job-3',
      code: 'FX-1033',
      category: ServiceCategory.acService,
      description: 'AC not cooling properly, might need a gas refill check.',
      customerId: customers[0].id,
      customerName: customers[0].name,
      customerPhone: customers[0].phone,
      address: customers[0].address,
      area: customers[0].area,
      preferredDay: PreferredDay.tomorrow,
      preferredSlot: PreferredSlot.morning,
      createdAt: now.subtract(const Duration(hours: 2)),
      status: JobStatus.assigned,
      assignedProviderId: providers[2].id,
      assignedProviderName: providers[2].name,
      assignedProviderPhone: providers[2].phone,
      assignedAt: now.subtract(const Duration(hours: 1)),
    ),
    JobRequest(
      id: 'seed-job-4',
      code: 'FX-1034',
      category: ServiceCategory.homeCleaning,
      description: 'Deep cleaning needed for a 2BHK before guests arrive this weekend.',
      customerId: customers[1].id,
      customerName: customers[1].name,
      customerPhone: customers[1].phone,
      address: customers[1].address,
      area: customers[1].area,
      preferredDay: PreferredDay.tomorrow,
      preferredSlot: PreferredSlot.evening,
      createdAt: now.subtract(const Duration(minutes: 40)),
    ),
    JobRequest(
      id: 'seed-job-5',
      code: 'FX-1035',
      category: ServiceCategory.notSure,
      description: 'Strange rattling noise from the bathroom wall, not sure what trade this needs.',
      customerId: customers[0].id,
      customerName: customers[0].name,
      customerPhone: customers[0].phone,
      address: customers[0].address,
      area: customers[0].area,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.evening,
      createdAt: now.subtract(const Duration(minutes: 10)),
    ),
  ];

  return SeedResult(customers: customers, providers: providers, jobs: jobs, jobSeq: 1035);
}
