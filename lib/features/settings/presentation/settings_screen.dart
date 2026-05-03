import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../hub/data/hub_item_repository.dart';
import '../../hub/domain/hub_item.dart';
import '../data/app_settings_repository.dart';
import '../domain/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settings,
    required this.settingsRepository,
    required this.itemRepository,
    required this.onDeleteAccount,
    this.signedInEmail,
    this.displayName,
    super.key,
  });

  final AppSettings settings;
  final AppSettingsRepository settingsRepository;
  final HubItemRepository itemRepository;
  final Future<void> Function(String password) onDeleteAccount;
  final String? signedInEmail;
  final String? displayName;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _isUpdatingTheme = false;
  var _isExporting = false;
  var _isDeleting = false;
  late AppThemePreference _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.settings.themeMode;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.themeMode != widget.settings.themeMode) {
      _themeMode = widget.settings.themeMode;
    }
  }

  Future<void> _updateThemeMode(AppThemePreference themeMode) async {
    if (_isUpdatingTheme || themeMode == _themeMode) {
      return;
    }

    setState(() {
      _isUpdatingTheme = true;
    });

    try {
      await widget.settingsRepository.updateThemeMode(themeMode);

      if (!mounted) {
        return;
      }

      setState(() {
        _themeMode = themeMode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme set to ${themeMode.label}')),
      );
    } catch (error) {
      _showError('Could not update theme: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingTheme = false;
        });
      }
    }
  }

  Future<void> _exportData() async {
    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final items = await widget.itemRepository.fetchItems();
      final exportText = _buildExportJson(items);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return _ExportDialog(itemCount: items.length, exportText: exportText);
        },
      );
    } catch (error) {
      _showError('Could not export reminders: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) {
      return;
    }

    final password = await showDialog<String>(
      context: context,
      builder: (context) => const _DeleteAccountDialog(),
    );

    if (password == null || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.onDeleteAccount(password);
    } catch (error) {
      _showError('Could not delete account: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _buildExportJson(List<HubItem> items) {
    final export = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map(_itemToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  Map<String, dynamic> _itemToJson(HubItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category.value,
      'description': item.description,
      'frequencyMonths': item.frequency.months,
      'lastDoneDate': item.lastDoneDate?.toIso8601String(),
      'nextDueDate': item.nextDueDate?.toIso8601String(),
      'source': item.source.value,
      'presetId': item.presetId,
      'createdAt': item.createdAt?.toIso8601String(),
      'updatedAt': item.updatedAt?.toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    _SettingsSection(
                      title: 'Profile',
                      icon: Icons.account_circle_outlined,
                      children: [
                        _ProfileRow(
                          label: 'Email',
                          value: widget.signedInEmail ?? 'Unknown email',
                        ),
                        const SizedBox(height: 12),
                        _ProfileRow(
                          label: 'Display name',
                          value: _displayNameText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SettingsSection(
                      title: 'Appearance',
                      icon: Icons.palette_outlined,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SegmentedButton<AppThemePreference>(
                            segments: [
                              for (final option in AppThemePreference.values)
                                ButtonSegment(
                                  value: option,
                                  icon: Icon(_iconForTheme(option)),
                                  label: Text(option.label),
                                ),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: _isUpdatingTheme
                                ? null
                                : (selection) {
                                    _updateThemeMode(selection.single);
                                  },
                          ),
                        ),
                        if (_isUpdatingTheme) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SettingsSection(
                      title: 'Data',
                      icon: Icons.file_download_outlined,
                      children: [
                        _ActionTile(
                          title: 'Export reminders',
                          subtitle: 'Copy your active reminders as JSON.',
                          icon: Icons.data_object_outlined,
                          isBusy: _isExporting,
                          onTap: _exportData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SettingsSection(
                      title: 'Account',
                      icon: Icons.admin_panel_settings_outlined,
                      children: [
                        _ActionTile(
                          title: 'Delete account',
                          subtitle:
                              'Remove your reminders, settings, and login.',
                          icon: Icons.delete_forever_outlined,
                          iconColor: theme.colorScheme.error,
                          isBusy: _isDeleting,
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _displayNameText {
    final displayName = widget.displayName?.trim();

    if (displayName == null || displayName.isEmpty) {
      return 'Not set';
    }

    return displayName;
  }

  IconData _iconForTheme(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.system => Icons.devices_outlined,
      AppThemePreference.light => Icons.light_mode_outlined,
      AppThemePreference.dark => Icons.dark_mode_outlined,
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isBusy,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isBusy;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: isBusy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: !isBusy,
      onTap: isBusy ? null : onTap,
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.itemCount, required this.exportText});

  final int itemCount;
  final String exportText;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: exportText));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export copied')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = availableWidth < 640 ? availableWidth : 640.0;

    return AlertDialog(
      title: const Text('Reminder export'),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$itemCount ${itemCount == 1 ? 'reminder' : 'reminders'}'),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                child: SelectableText(
                  exportText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => _copy(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy JSON'),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = availableWidth < 480 ? availableWidth : 480.0;

    return AlertDialog(
      title: const Text('Delete account?'),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Enter your password.';
              }

              return null;
            },
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
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Delete account'),
        ),
      ],
    );
  }
}
