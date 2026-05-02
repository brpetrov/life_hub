import 'package:flutter/material.dart';

import '../domain/frequency.dart';
import '../domain/hub_category.dart';
import '../domain/hub_item.dart';

class HubItemFormDialog extends StatefulWidget {
  const HubItemFormDialog({required this.item, super.key});

  final HubItem item;

  static Future<HubItem?> show(BuildContext context, {required HubItem item}) {
    return showDialog<HubItem>(
      context: context,
      builder: (context) => HubItemFormDialog(item: item),
    );
  }

  @override
  State<HubItemFormDialog> createState() => _HubItemFormDialogState();
}

class _HubItemFormDialogState extends State<HubItemFormDialog> {
  static const _baseFrequencyOptions = [0, 1, 3, 6, 12, 18, 24, 60, 120];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late HubCategory _category;
  late int _frequencyMonths;

  List<int> get _frequencyOptions {
    return {..._baseFrequencyOptions, _frequencyMonths}.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _category = widget.item.category;
    _frequencyMonths = widget.item.frequency.months;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      widget.item.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        frequency: Frequency(_frequencyMonths),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = availableWidth < 560 ? availableWidth : 560.0;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: const Text('Edit reminder'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Enter a reminder name.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<HubCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final category in HubCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (category) {
                    if (category == null) {
                      return;
                    }

                    setState(() {
                      _category = category;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _frequencyMonths,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: [
                    for (final months in _frequencyOptions)
                      DropdownMenuItem(
                        value: months,
                        child: Text(Frequency(months).label),
                      ),
                  ],
                  onChanged: (months) {
                    if (months == null) {
                      return;
                    }

                    setState(() {
                      _frequencyMonths = months;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
