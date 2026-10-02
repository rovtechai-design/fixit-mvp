import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../util/validators.dart';
import 'customer_home_screen.dart';

class SignInCustomerScreen extends StatefulWidget {
  const SignInCustomerScreen({super.key});

  @override
  State<SignInCustomerScreen> createState() => _SignInCustomerScreenState();
}

class _SignInCustomerScreenState extends State<SignInCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _flatController = TextEditingController();
  final _buildingController = TextEditingController();
  final _areaController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _flatController.dispose();
    _buildingController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await AppRepository.instance.signInCustomer(
      name: _nameController.text,
      phone: _phoneController.text,
      flat: _flatController.text,
      building: _buildingController.text,
      area: _areaController.text,
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('I need help')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tell us a little about you', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number', prefixText: '+91 '),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: validatePhone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _flatController,
                  decoration: const InputDecoration(labelText: 'Flat / house no.'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequired(v, 'Flat / house no.'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _buildingController,
                  decoration: const InputDecoration(labelText: 'Building / society'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequired(v, 'Building / society'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(labelText: 'Area'),
                  textInputAction: TextInputAction.done,
                  validator: (v) => validateRequired(v, 'Area'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
