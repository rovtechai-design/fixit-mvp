import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../models/trade.dart';
import '../util/validators.dart';
import 'provider_home_screen.dart';

class SignInProviderScreen extends StatefulWidget {
  const SignInProviderScreen({super.key});

  @override
  State<SignInProviderScreen> createState() => _SignInProviderScreenState();
}

class _SignInProviderScreenState extends State<SignInProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Trade _trade = Trade.plumber;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await AppRepository.instance.signInProvider(
      name: _nameController.text,
      phone: _phoneController.text,
      trade: _trade,
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("I'm a service provider")),
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
                DropdownButtonFormField<Trade>(
                  initialValue: _trade,
                  decoration: const InputDecoration(labelText: 'Trade'),
                  items: Trade.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _trade = v ?? _trade),
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
