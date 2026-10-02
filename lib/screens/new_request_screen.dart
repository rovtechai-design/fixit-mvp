import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/app_repository.dart';
import '../models/job_request.dart';
import '../models/service_category.dart';
import '../util/photo_preview.dart';
import '../util/validators.dart';
import 'confirmation_screen.dart';

class NewRequestScreen extends StatefulWidget {
  final ServiceCategory category;
  const NewRequestScreen({super.key, required this.category});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  String? _photoPath;
  PreferredDay _day = PreferredDay.today;
  PreferredSlot _slot = PreferredSlot.morning;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final customer = AppRepository.instance.currentCustomer;
    _descriptionController = TextEditingController();
    _addressController = TextEditingController(text: customer?.address ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked != null) setState(() => _photoPath = picked.path);
  }

  Future<void> _showPhotoSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final customer = AppRepository.instance.currentCustomer;
    if (customer == null) return;
    setState(() => _submitting = true);
    final job = await AppRepository.instance.submitJob(
      customer: customer,
      category: widget.category,
      description: _descriptionController.text,
      photoPath: _photoPath,
      address: _addressController.text,
      preferredDay: _day,
      preferredSlot: _slot,
    );
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConfirmationScreen(job: job)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Photo (optional)', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _buildPhotoPicker(context),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "What's the problem?",
                    hintText: 'e.g. Tap in the kitchen is leaking',
                  ),
                  maxLines: 3,
                  validator: (v) => validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                  validator: (v) => validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 20),
                Text('Preferred day', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: PreferredDay.values
                      .map((d) => ChoiceChip(
                            label: Text(d.label),
                            selected: _day == d,
                            onSelected: (_) => setState(() => _day = d),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('Preferred time slot', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: PreferredSlot.values
                      .map((s) => ChoiceChip(
                            label: Text(s.label),
                            selected: _slot == s,
                            onSelected: (_) => setState(() => _slot = s),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Visit charge applies. Final price confirmed on-site.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Submit request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    if (kIsWeb) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 6),
            Text(
              'Photo capture is available in the Android app',
              style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_photoPath != null) ...[
          buildPhotoPreview(_photoPath!),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          icon: Icon(_photoPath == null ? Icons.add_a_photo : Icons.refresh),
          label: Text(_photoPath == null ? 'Add photo' : 'Retake / change photo'),
          onPressed: _showPhotoSourceSheet,
        ),
      ],
    );
  }
}
