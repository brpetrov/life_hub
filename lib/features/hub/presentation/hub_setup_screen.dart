import 'package:flutter/material.dart';

import '../../settings/data/app_settings_repository.dart';
import '../data/hub_item_repository.dart';
import '../domain/frequency.dart';
import '../domain/hub_category.dart';
import '../domain/hub_item.dart';
import '../domain/hub_preset.dart';
import 'hub_date_format.dart';

class HubSetupScreen extends StatefulWidget {
  const HubSetupScreen({
    required this.repository,
    required this.settingsRepository,
    required this.isOnboarding,
    this.onSignOut,
    this.onFinished,
    super.key,
  });

  final HubItemRepository repository;
  final AppSettingsRepository settingsRepository;
  final bool isOnboarding;
  final VoidCallback? onSignOut;
  final VoidCallback? onFinished;

  @override
  State<HubSetupScreen> createState() => _HubSetupScreenState();
}

class _HubSetupScreenState extends State<HubSetupScreen> {
  final Set<String> _selectedPresetIds = {};
  final List<_CustomReminderDraft> _customReminders = [];

  var _isSaving = false;

  int get _saveCount => _selectedPresetIds.length + _customReminders.length;

  Future<void> _addCustomReminder() async {
    final reminder = await showDialog<_CustomReminderDraft>(
      context: context,
      builder: (context) => const _CustomReminderDialog(),
    );

    if (reminder == null || !mounted) {
      return;
    }

    setState(() {
      _customReminders.add(reminder);
    });
  }

  Future<void> _save() async {
    if (_saveCount == 0 || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final createdAt = DateTime.now();
      final selectedPresetItems = HubPreset.all
          .where((preset) => _selectedPresetIds.contains(preset.id))
          .map((preset) => preset.toHubItem(createdAt: createdAt));
      final customItems = _customReminders.map((reminder) {
        return reminder.toHubItem(createdAt: createdAt);
      });

      await widget.repository.createItems([
        ...selectedPresetItems,
        ...customItems,
      ]);

      if (widget.isOnboarding) {
        await widget.settingsRepository.completeOnboarding();
      }

      if (!mounted) {
        return;
      }

      widget.onFinished?.call();

      if (!widget.isOnboarding && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save reminders: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _selectAll() {
    setState(() {
      _selectedPresetIds
        ..clear()
        ..addAll(HubPreset.all.map((preset) => preset.id));
    });
  }

  void _clearAllPresets() {
    setState(() {
      _selectedPresetIds.clear();
    });
  }

  void _setCategorySelected(HubCategory category, bool selected) {
    final presetIds = HubPreset.all
        .where((preset) => preset.category == category)
        .map((preset) => preset.id);

    setState(() {
      if (selected) {
        _selectedPresetIds.addAll(presetIds);
      } else {
        _selectedPresetIds.removeAll(presetIds);
      }
    });
  }

  void _togglePreset(String presetId, bool selected) {
    setState(() {
      if (selected) {
        _selectedPresetIds.add(presetId);
      } else {
        _selectedPresetIds.remove(presetId);
      }
    });
  }

  void _removeCustomReminder(_CustomReminderDraft reminder) {
    setState(() {
      _customReminders.remove(reminder);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedPresets = HubPreset.groupedByCategory();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Set up reminders' : 'Add reminders'),
        automaticallyImplyLeading: !widget.isOnboarding,
        actions: [
          if (widget.isOnboarding && widget.onSignOut != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: _isSaving ? null : widget.onSignOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isOnboarding
                              ? 'Choose the reminders you want Life Hub to track first.'
                              : 'Choose more reminders to add to your hub.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: _isSaving ? null : _selectAll,
                              icon: const Icon(Icons.done_all),
                              label: const Text('Select all presets'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isSaving ? null : _clearAllPresets,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear presets'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isSaving ? null : _addCustomReminder,
                              icon: const Icon(Icons.add),
                              label: const Text('Custom reminder'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            for (final entry in groupedPresets.entries)
              if (entry.value.isNotEmpty)
                SliverToBoxAdapter(
                  child: _PresetCategorySection(
                    category: entry.key,
                    presets: entry.value,
                    selectedPresetIds: _selectedPresetIds,
                    onPresetToggled: _togglePreset,
                    onCategorySelectionChanged: _setCategorySelected,
                  ),
                ),
            SliverToBoxAdapter(
              child: _CustomReminderSection(
                reminders: _customReminders,
                onAdd: _addCustomReminder,
                onRemove: _removeCustomReminder,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _saveCount == 0
                          ? 'Select at least one reminder'
                          : '$_saveCount ${_saveCount == 1 ? 'reminder' : 'reminders'} selected',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saveCount == 0 || _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(widget.isOnboarding ? 'Save setup' : 'Add'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetCategorySection extends StatelessWidget {
  const _PresetCategorySection({
    required this.category,
    required this.presets,
    required this.selectedPresetIds,
    required this.onPresetToggled,
    required this.onCategorySelectionChanged,
  });

  final HubCategory category;
  final List<HubPreset> presets;
  final Set<String> selectedPresetIds;
  final void Function(String presetId, bool selected) onPresetToggled;
  final void Function(HubCategory category, bool selected)
  onCategorySelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = presets
        .where((preset) => selectedPresetIds.contains(preset.id))
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            _iconForCategory(category),
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${category.label} Hub',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$selectedCount of ${presets.length} selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            onCategorySelectionChanged(category, true),
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('All'),
                      ),
                      TextButton.icon(
                        onPressed: selectedCount == 0
                            ? null
                            : () => onCategorySelectionChanged(category, false),
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: theme.colorScheme.outlineVariant),
                  for (final preset in presets) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: CheckboxListTile(
                          value: selectedPresetIds.contains(preset.id),
                          onChanged: (selected) {
                            onPresetToggled(preset.id, selected ?? false);
                          },
                          title: Text(
                            preset.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${preset.description} ${preset.frequency.label}.',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(HubCategory category) {
    return switch (category) {
      HubCategory.car => Icons.directions_car_outlined,
      HubCategory.home => Icons.home_outlined,
      HubCategory.health => Icons.health_and_safety_outlined,
      HubCategory.tech => Icons.devices_outlined,
      HubCategory.pets => Icons.pets_outlined,
      HubCategory.documents => Icons.description_outlined,
      HubCategory.seasonal => Icons.wb_sunny_outlined,
      HubCategory.custom => Icons.tune_outlined,
    };
  }
}

class _CustomReminderSection extends StatelessWidget {
  const _CustomReminderSection({
    required this.reminders,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_CustomReminderDraft> reminders;
  final VoidCallback onAdd;
  final ValueChanged<_CustomReminderDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom Hub',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${reminders.length} custom ${reminders.length == 1 ? 'reminder' : 'reminders'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add),
                        label: const Text('Add custom'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: theme.colorScheme.outlineVariant),
                  if (reminders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_task_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add anything that does not fit the preset list.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final reminder in reminders)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.edit_note_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          reminder.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${reminder.category.label}, '
                          '${reminder.frequency.label}, '
                          '${_formatOptionalDate(reminder.nextDueDate)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove custom reminder',
                          onPressed: () => onRemove(reminder),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatOptionalDate(DateTime? date) {
    return date == null ? 'no due date' : 'due ${HubDateFormat.short(date)}';
  }
}

class _CustomReminderDialog extends StatefulWidget {
  const _CustomReminderDialog();

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  static const _frequencyOptions = [0, 1, 3, 6, 12, 24, 60, 120];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  HubCategory _category = HubCategory.custom;
  var _frequencyMonths = 12;
  DateTime? _nextDueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 25),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _nextDueDate = pickedDate;
    });
  }

  void _clearDueDate() {
    setState(() {
      _nextDueDate = null;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _CustomReminderDraft(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        frequency: Frequency(_frequencyMonths),
        nextDueDate: _nextDueDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = availableWidth < 560 ? availableWidth : 560.0;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: const Text('Custom reminder'),
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
                    hintText: 'Boiler filter clean',
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
                    hintText: 'What needs checking or renewing?',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  minLines: 2,
                  maxLines: 4,
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
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due date',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _nextDueDate == null
                              ? 'Optional'
                              : HubDateFormat.short(_nextDueDate!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDueDate,
                        child: Text(_nextDueDate == null ? 'Pick' : 'Change'),
                      ),
                      if (_nextDueDate != null)
                        IconButton(
                          tooltip: 'Clear due date',
                          onPressed: _clearDueDate,
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
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
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

class _CustomReminderDraft {
  const _CustomReminderDraft({
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
  });

  final String name;
  final String description;
  final HubCategory category;
  final Frequency frequency;
  final DateTime? nextDueDate;

  HubItem toHubItem({required DateTime createdAt}) {
    return HubItem(
      id: '',
      name: name,
      category: category,
      description: description,
      frequency: frequency,
      nextDueDate: nextDueDate,
      source: HubItemSource.custom,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
