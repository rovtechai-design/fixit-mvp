import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../models/service_provider.dart';
import '../models/trade.dart';
import 'seed_data.dart';

enum ProfileRole { customer, provider }

class CurrentProfile {
  final ProfileRole role;
  final String id;
  CurrentProfile(this.role, this.id);
}

const _kCustomers = 'fixit_customers';
const _kProviders = 'fixit_providers';
const _kJobs = 'fixit_jobs';
const _kJobSeq = 'fixit_job_seq';
const _kCurrentRole = 'fixit_current_role';
const _kCurrentId = 'fixit_current_id';
const _kLastCustomerId = 'fixit_last_customer_id';
const _kLastProviderId = 'fixit_last_provider_id';

/// Single source of truth for all FixIt demo data. Everything is persisted
/// locally via [SharedPreferences] as JSON - there is no backend, so both
/// the customer and provider roles on this device read and write the same
/// local store (that's intentional: it's what makes the single-phone demo
/// work).
class AppRepository extends ChangeNotifier {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  List<Customer> customers = [];
  List<ServiceProvider> providers = [];
  List<JobRequest> jobs = [];
  int _jobSeq = 1000;

  CurrentProfile? currentProfile;
  String? lastCustomerId;
  String? lastProviderId;

  final _uuid = const Uuid();

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadAll();
    if (customers.isEmpty && providers.isEmpty && jobs.isEmpty) {
      _applySeed();
      await _saveAll();
    }
    _initialized = true;
  }

  /// Allows tests to force a fresh [init] against a freshly mocked
  /// [SharedPreferences] store, bypassing the singleton's usual
  /// initialize-once guard.
  @visibleForTesting
  void debugReset() {
    _initialized = false;
    customers = [];
    providers = [];
    jobs = [];
    currentProfile = null;
    lastCustomerId = null;
    lastProviderId = null;
  }

  void _applySeed() {
    final seed = buildSeedData();
    customers = seed.customers;
    providers = seed.providers;
    jobs = seed.jobs;
    _jobSeq = seed.jobSeq;
  }

  void _loadAll() {
    final customersJson = _prefs.getString(_kCustomers);
    final providersJson = _prefs.getString(_kProviders);
    final jobsJson = _prefs.getString(_kJobs);

    customers = customersJson == null
        ? []
        : (jsonDecode(customersJson) as List)
            .map((e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList();
    providers = providersJson == null
        ? []
        : (jsonDecode(providersJson) as List)
            .map((e) => ServiceProvider.fromJson(e as Map<String, dynamic>))
            .toList();
    jobs = jobsJson == null
        ? []
        : (jsonDecode(jobsJson) as List)
            .map((e) => JobRequest.fromJson(e as Map<String, dynamic>))
            .toList();
    _jobSeq = _prefs.getInt(_kJobSeq) ?? 1000;

    final role = _prefs.getString(_kCurrentRole);
    final id = _prefs.getString(_kCurrentId);
    currentProfile = (role != null && id != null)
        ? CurrentProfile(role == 'customer' ? ProfileRole.customer : ProfileRole.provider, id)
        : null;
    lastCustomerId = _prefs.getString(_kLastCustomerId);
    lastProviderId = _prefs.getString(_kLastProviderId);
  }

  Future<void> _saveAll() async {
    await _prefs.setString(_kCustomers, jsonEncode(customers.map((c) => c.toJson()).toList()));
    await _prefs.setString(_kProviders, jsonEncode(providers.map((p) => p.toJson()).toList()));
    await _prefs.setString(_kJobs, jsonEncode(jobs.map((j) => j.toJson()).toList()));
    await _prefs.setInt(_kJobSeq, _jobSeq);
    if (currentProfile == null) {
      await _prefs.remove(_kCurrentRole);
      await _prefs.remove(_kCurrentId);
    } else {
      await _prefs.setString(_kCurrentRole, currentProfile!.role == ProfileRole.customer ? 'customer' : 'provider');
      await _prefs.setString(_kCurrentId, currentProfile!.id);
    }
    if (lastCustomerId == null) {
      await _prefs.remove(_kLastCustomerId);
    } else {
      await _prefs.setString(_kLastCustomerId, lastCustomerId!);
    }
    if (lastProviderId == null) {
      await _prefs.remove(_kLastProviderId);
    } else {
      await _prefs.setString(_kLastProviderId, lastProviderId!);
    }
  }

  // ---- Profile lookups ----

  Customer? getCustomerById(String id) {
    for (final c in customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  ServiceProvider? getProviderById(String id) {
    for (final p in providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  JobRequest? getJobById(String id) {
    for (final j in jobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  Customer? get currentCustomer =>
      currentProfile?.role == ProfileRole.customer ? getCustomerById(currentProfile!.id) : null;

  ServiceProvider? get currentProvider =>
      currentProfile?.role == ProfileRole.provider ? getProviderById(currentProfile!.id) : null;

  Customer? get lastCustomer => lastCustomerId == null ? null : getCustomerById(lastCustomerId!);

  ServiceProvider? get lastProvider => lastProviderId == null ? null : getProviderById(lastProviderId!);

  // ---- Sign in / session ----

  Future<Customer> signInCustomer({
    required String name,
    required String phone,
    required String flat,
    required String building,
    required String area,
  }) async {
    final existingIndex = customers.indexWhere((c) => c.phone == phone.trim());
    Customer customer;
    if (existingIndex != -1) {
      customer = customers[existingIndex].copyWith(name: name, flat: flat, building: building, area: area);
      customers[existingIndex] = customer;
    } else {
      customer = Customer(
        id: _uuid.v4(),
        name: name.trim(),
        phone: phone.trim(),
        flat: flat.trim(),
        building: building.trim(),
        area: area.trim(),
        createdAt: DateTime.now(),
      );
      customers.add(customer);
    }
    currentProfile = CurrentProfile(ProfileRole.customer, customer.id);
    lastCustomerId = customer.id;
    await _saveAll();
    notifyListeners();
    return customer;
  }

  Future<ServiceProvider> signInProvider({
    required String name,
    required String phone,
    required Trade trade,
  }) async {
    final existingIndex = providers.indexWhere((p) => p.phone == phone.trim());
    ServiceProvider provider;
    if (existingIndex != -1) {
      provider = providers[existingIndex].copyWith(name: name, trade: trade);
      providers[existingIndex] = provider;
    } else {
      provider = ServiceProvider(
        id: _uuid.v4(),
        name: name.trim(),
        phone: phone.trim(),
        trade: trade,
        createdAt: DateTime.now(),
      );
      providers.add(provider);
    }
    currentProfile = CurrentProfile(ProfileRole.provider, provider.id);
    lastProviderId = provider.id;
    await _saveAll();
    notifyListeners();
    return provider;
  }

  Future<void> continueAsCustomer() async {
    if (lastCustomerId == null) return;
    currentProfile = CurrentProfile(ProfileRole.customer, lastCustomerId!);
    await _saveAll();
    notifyListeners();
  }

  Future<void> continueAsProvider() async {
    if (lastProviderId == null) return;
    currentProfile = CurrentProfile(ProfileRole.provider, lastProviderId!);
    await _saveAll();
    notifyListeners();
  }

  Future<void> switchRole() async {
    currentProfile = null;
    await _saveAll();
    notifyListeners();
  }

  Future<void> logOut() async {
    if (currentProfile?.role == ProfileRole.customer) {
      lastCustomerId = null;
    } else if (currentProfile?.role == ProfileRole.provider) {
      lastProviderId = null;
    }
    currentProfile = null;
    await _saveAll();
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    currentProfile = null;
    lastCustomerId = null;
    lastProviderId = null;
    _applySeed();
    await _saveAll();
    notifyListeners();
  }

  // ---- Jobs: customer side ----

  List<JobRequest> requestsForCustomer(String customerId) {
    final list = jobs.where((j) => j.customerId == customerId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<JobRequest> submitJob({
    required Customer customer,
    required ServiceCategory category,
    required String description,
    String? photoPath,
    required String address,
    required PreferredDay preferredDay,
    required PreferredSlot preferredSlot,
  }) async {
    _jobSeq += 1;
    final job = JobRequest(
      id: _uuid.v4(),
      code: 'FX-$_jobSeq',
      category: category,
      description: description.trim(),
      photoPath: photoPath,
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      address: address.trim(),
      area: customer.area,
      preferredDay: preferredDay,
      preferredSlot: preferredSlot,
      createdAt: DateTime.now(),
    );
    jobs.add(job);
    await _saveAll();
    notifyListeners();
    return job;
  }

  Future<bool> cancelJob(String jobId, String customerId) async {
    final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => throw StateError('Job not found'));
    if (job.status != JobStatus.submitted || job.customerId != customerId) return false;
    job.status = JobStatus.cancelled;
    job.cancelledAt = DateTime.now();
    await _saveAll();
    notifyListeners();
    return true;
  }

  // ---- Jobs: provider side ----

  List<JobRequest> availableJobsForProvider(Trade trade) {
    final list = jobs
        .where((j) => j.status == JobStatus.submitted && _isVisible(j.category, trade))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<JobRequest> myJobsForProvider(String providerId) {
    final list = jobs
        .where((j) => j.assignedProviderId == providerId && j.status != JobStatus.cancelled)
        .toList();
    list.sort((a, b) {
      // Active jobs (assigned/onTheWay) first, then completed; newest within each group first.
      final aActive = isJobActive(a.status);
      final bActive = isJobActive(b.status);
      if (aActive != bActive) return aActive ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  bool isJobActive(JobStatus status) => status == JobStatus.assigned || status == JobStatus.onTheWay;

  bool _isVisible(ServiceCategory category, Trade trade) {
    switch (category) {
      case ServiceCategory.plumbing:
        return trade == Trade.plumber;
      case ServiceCategory.electrical:
        return trade == Trade.electrician;
      case ServiceCategory.acService:
        return trade == Trade.acTechnician;
      case ServiceCategory.homeCleaning:
      case ServiceCategory.terraceOutdoorCleaning:
        return trade == Trade.cleaner;
      case ServiceCategory.gardening:
        return trade == Trade.gardener;
      case ServiceCategory.tailoringAlterations:
        return trade == Trade.tailor;
      case ServiceCategory.notSure:
        return true;
    }
  }

  int availableCountForProvider(Trade trade) => availableJobsForProvider(trade).length;

  int activeCountForProvider(String providerId) =>
      jobs.where((j) => j.assignedProviderId == providerId && isJobActive(j.status)).length;

  int completedCountForProvider(String providerId) =>
      jobs.where((j) => j.assignedProviderId == providerId && j.status == JobStatus.completed).length;

  /// Returns true if this provider successfully claimed the job. Returns
  /// false if another provider already claimed it first (status is no
  /// longer "submitted") - the caller should show "already taken".
  Future<bool> acceptJob(String jobId, ServiceProvider provider) async {
    final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => throw StateError('Job not found'));
    if (job.status != JobStatus.submitted) return false;
    job.status = JobStatus.assigned;
    job.assignedProviderId = provider.id;
    job.assignedProviderName = provider.name;
    job.assignedProviderPhone = provider.phone;
    job.assignedAt = DateTime.now();
    await _saveAll();
    notifyListeners();
    return true;
  }

  Future<bool> markOnTheWay(String jobId, String providerId) async {
    final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => throw StateError('Job not found'));
    if (job.status != JobStatus.assigned || job.assignedProviderId != providerId) return false;
    job.status = JobStatus.onTheWay;
    job.onTheWayAt = DateTime.now();
    await _saveAll();
    notifyListeners();
    return true;
  }

  Future<bool> markCompleted(String jobId, String providerId) async {
    final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => throw StateError('Job not found'));
    if (job.status != JobStatus.onTheWay || job.assignedProviderId != providerId) return false;
    job.status = JobStatus.completed;
    job.completedAt = DateTime.now();
    await _saveAll();
    notifyListeners();
    return true;
  }
}
