import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fixit_mvp/data/app_repository.dart';
import 'package:fixit_mvp/models/job_request.dart';
import 'package:fixit_mvp/models/service_category.dart';
import 'package:fixit_mvp/models/trade.dart';

void main() {
  late AppRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = AppRepository.instance;
    repo.debugReset();
    await repo.init();
  });

  test('first launch seeds customers, providers and jobs', () {
    expect(repo.customers, isNotEmpty);
    expect(repo.providers, isNotEmpty);
    expect(repo.jobs, isNotEmpty);
  });

  test('signing in with a new phone creates a new customer and sets the session', () async {
    final customer = await repo.signInCustomer(
      name: 'Test User',
      phone: '9000000001',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    expect(repo.currentCustomer?.id, customer.id);
    expect(repo.lastCustomerId, customer.id);
  });

  test('signing in again with the same phone reuses the existing profile', () async {
    final first = await repo.signInCustomer(
      name: 'Test User',
      phone: '9000000002',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    final countAfterFirst = repo.customers.length;

    final second = await repo.signInCustomer(
      name: 'Test User Updated',
      phone: '9000000002',
      flat: 'Flat 2',
      building: 'Test Tower',
      area: 'Test Area',
    );

    expect(second.id, first.id);
    expect(repo.customers.length, countAfterFirst);
    expect(repo.getCustomerById(first.id)!.name, 'Test User Updated');
  });

  test('only one provider can accept a submitted job', () async {
    final customer = await repo.signInCustomer(
      name: 'Needs Help',
      phone: '9000000003',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    final job = await repo.submitJob(
      customer: customer,
      category: ServiceCategory.plumbing,
      description: 'Leaky tap',
      address: customer.address,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.morning,
    );

    final providerA = await repo.signInProvider(name: 'Provider A', phone: '9000000004', trade: Trade.plumber);
    final providerB = await repo.signInProvider(name: 'Provider B', phone: '9000000005', trade: Trade.plumber);

    final firstAccept = await repo.acceptJob(job.id, providerA);
    final secondAccept = await repo.acceptJob(job.id, providerB);

    expect(firstAccept, isTrue);
    expect(secondAccept, isFalse);
    expect(repo.getJobById(job.id)!.assignedProviderId, providerA.id);
    expect(repo.getJobById(job.id)!.status, JobStatus.assigned);
  });

  test('status can only move forward through the correct sequence', () async {
    final customer = await repo.signInCustomer(
      name: 'Needs Help',
      phone: '9000000006',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    final job = await repo.submitJob(
      customer: customer,
      category: ServiceCategory.electrical,
      description: 'Socket sparking',
      address: customer.address,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.afternoon,
    );
    final provider = await repo.signInProvider(name: 'Electrician', phone: '9000000007', trade: Trade.electrician);

    // Can't skip straight to onTheWay/completed before being assigned.
    expect(await repo.markOnTheWay(job.id, provider.id), isFalse);
    expect(await repo.markCompleted(job.id, provider.id), isFalse);

    expect(await repo.acceptJob(job.id, provider), isTrue);
    expect(await repo.markCompleted(job.id, provider.id), isFalse); // can't skip onTheWay

    expect(await repo.markOnTheWay(job.id, provider.id), isTrue);
    expect(await repo.markCompleted(job.id, provider.id), isTrue);
    expect(repo.getJobById(job.id)!.status, JobStatus.completed);
  });

  test('a job can only be cancelled by its own customer while still submitted', () async {
    final customer = await repo.signInCustomer(
      name: 'Needs Help',
      phone: '9000000008',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    final otherCustomer = await repo.signInCustomer(
      name: 'Someone Else',
      phone: '9000000009',
      flat: 'Flat 2',
      building: 'Test Tower',
      area: 'Test Area',
    );
    final job = await repo.submitJob(
      customer: customer,
      category: ServiceCategory.gardening,
      description: 'Lawn mowing',
      address: customer.address,
      preferredDay: PreferredDay.tomorrow,
      preferredSlot: PreferredSlot.evening,
    );

    expect(await repo.cancelJob(job.id, otherCustomer.id), isFalse);
    expect(await repo.cancelJob(job.id, customer.id), isTrue);
    expect(repo.getJobById(job.id)!.status, JobStatus.cancelled);

    // Re-signing in as the customer and submitting a fresh job, accepting it,
    // then trying to cancel should fail since it's no longer "submitted".
    final provider = await repo.signInProvider(name: 'Gardener', phone: '9000000010', trade: Trade.gardener);
    final job2 = await repo.submitJob(
      customer: customer,
      category: ServiceCategory.gardening,
      description: 'Hedge trimming',
      address: customer.address,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.morning,
    );
    await repo.acceptJob(job2.id, provider);
    expect(await repo.cancelJob(job2.id, customer.id), isFalse);
  });

  test('available jobs for a trade exclude other trades but include "Not sure"', () async {
    final customer = await repo.signInCustomer(
      name: 'Needs Help',
      phone: '9000000011',
      flat: 'Flat 1',
      building: 'Test Tower',
      area: 'Test Area',
    );
    await repo.submitJob(
      customer: customer,
      category: ServiceCategory.tailoringAlterations,
      description: 'Hem trousers',
      address: customer.address,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.morning,
    );
    await repo.submitJob(
      customer: customer,
      category: ServiceCategory.notSure,
      description: 'Unclear issue',
      address: customer.address,
      preferredDay: PreferredDay.today,
      preferredSlot: PreferredSlot.evening,
    );

    final tailorJobs = repo.availableJobsForProvider(Trade.tailor);
    expect(tailorJobs.any((j) => j.category == ServiceCategory.tailoringAlterations), isTrue);
    expect(tailorJobs.any((j) => j.category == ServiceCategory.notSure), isTrue);

    final plumberJobs = repo.availableJobsForProvider(Trade.plumber);
    expect(plumberJobs.any((j) => j.category == ServiceCategory.tailoringAlterations), isFalse);
    expect(plumberJobs.any((j) => j.category == ServiceCategory.notSure), isTrue);
  });
}
