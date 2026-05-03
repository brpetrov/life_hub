import 'package:flutter/material.dart';

import '../data/hub_item_repository.dart';
import '../domain/hub_category.dart';
import '../domain/hub_item.dart';
import 'hub_category_filter_bar.dart';
import 'hub_date_format.dart';
import 'hub_item_card.dart';
import 'hub_item_details_sheet.dart';
import 'hub_item_form_dialog.dart';
import 'hub_status_bar.dart';

class HubDashboard extends StatefulWidget {
  const HubDashboard({
    required this.repository,
    required this.onSignOut,
    this.signedInEmail,
    this.onOpenSettings,
    this.onAddReminders,
    super.key,
  });

  final HubItemRepository repository;
  final VoidCallback onSignOut;
  final String? signedInEmail;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onAddReminders;

  @override
  State<HubDashboard> createState() => _HubDashboardState();
}

class _HubDashboardState extends State<HubDashboard> {
  late Stream<List<HubItem>> _itemsStream;
  HubCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _itemsStream = widget.repository.watchItems();
  }

  @override
  void didUpdateWidget(covariant HubDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.repository != widget.repository) {
      _itemsStream = widget.repository.watchItems();
      _selectedCategory = null;
    }
  }

  void _retry() {
    setState(() {
      _itemsStream = widget.repository.watchItems();
    });
  }

  void _selectCategory(HubCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showDetails(HubItem item) {
    HubItemDetailsSheet.show(
      context,
      item: item,
      onEdit: () {
        _editItem(item);
      },
      onSetDueDate: () {
        _setDueDate(item);
      },
      onMarkDone: () {
        _markDone(item);
      },
      onToggleNotificationsMuted: () {
        _toggleNotificationsMuted(item);
      },
      onDelete: () {
        _deleteItem(item);
      },
    );
  }

  void _handleAddReminders() {
    final callback = widget.onAddReminders;

    if (callback != null) {
      callback();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder setup is coming next.')),
    );
  }

  Future<void> _editItem(HubItem item) async {
    final updatedItem = await HubItemFormDialog.show(context, item: item);

    if (updatedItem == null || !mounted) {
      return;
    }

    await _runRepositoryAction(
      () => widget.repository.updateItem(updatedItem),
      successMessage: 'Reminder updated',
      errorMessage: 'Could not update reminder',
    );
  }

  Future<void> _setDueDate(HubItem item) async {
    final initialDate = item.nextDueDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 25),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    await _runRepositoryAction(
      () =>
          widget.repository.updateItem(item.copyWith(nextDueDate: pickedDate)),
      successMessage: 'Due date set for ${HubDateFormat.short(pickedDate)}',
      errorMessage: 'Could not set due date',
    );
  }

  Future<void> _markDone(HubItem item) async {
    await _runRepositoryAction(
      () => widget.repository.markDone(item),
      successMessage: 'Marked done',
      errorMessage: 'Could not mark reminder done',
    );
  }

  Future<void> _toggleNotificationsMuted(HubItem item) async {
    final updatedItem = item.copyWith(
      notificationsMuted: !item.notificationsMuted,
    );

    await _runRepositoryAction(
      () => widget.repository.updateItem(updatedItem),
      successMessage: updatedItem.notificationsMuted
          ? 'Reminder notifications muted'
          : 'Reminder notifications enabled',
      errorMessage: 'Could not update reminder notifications',
    );
  }

  Future<void> _deleteItem(HubItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete reminder?'),
          content: Text('Delete "${item.name}" from your hub?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _runRepositoryAction(
      () => widget.repository.deleteItem(item.id),
      successMessage: 'Reminder deleted',
      errorMessage: 'Could not delete reminder',
    );
  }

  Future<void> _runRepositoryAction(
    Future<void> Function() action, {
    required String successMessage,
    required String errorMessage,
  }) async {
    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$errorMessage: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Hub'),
        actions: [
          if (widget.onOpenSettings != null)
            IconButton(
              tooltip: 'Settings',
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<HubItem>>(
          stream: _itemsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _HubLoadingState();
            }

            if (snapshot.hasError) {
              return _HubErrorState(
                error: snapshot.error.toString(),
                onRetry: _retry,
              );
            }

            return _HubLoadedState(
              items: snapshot.data ?? const [],
              selectedCategory: _selectedCategory,
              signedInEmail: widget.signedInEmail,
              onCategorySelected: _selectCategory,
              onAddReminders: _handleAddReminders,
              onItemSelected: _showDetails,
            );
          },
        ),
      ),
    );
  }
}

class _HubLoadingState extends StatelessWidget {
  const _HubLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _HubErrorState extends StatelessWidget {
  const _HubErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load reminders',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubLoadedState extends StatelessWidget {
  const _HubLoadedState({
    required this.items,
    required this.selectedCategory,
    required this.signedInEmail,
    required this.onCategorySelected,
    required this.onAddReminders,
    required this.onItemSelected,
  });

  final List<HubItem> items;
  final HubCategory? selectedCategory;
  final String? signedInEmail;
  final ValueChanged<HubCategory?> onCategorySelected;
  final VoidCallback onAddReminders;
  final ValueChanged<HubItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory == null
        ? items
        : items.where((item) => item.category == selectedCategory).toList();

    if (items.isEmpty) {
      return _HubEmptyState(
        signedInEmail: signedInEmail,
        onAddReminders: onAddReminders,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HubHeader(
            items: items,
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
            onAddReminders: onAddReminders,
          ),
        ),
        if (filteredItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _FilteredEmptyState(
              selectedCategory: selectedCategory!,
              onClearFilter: () => onCategorySelected(null),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final crossAxisCount = width >= 900 ? 2 : 1;

                return SliverGrid.builder(
                  itemCount: filteredItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 172,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return HubItemCard(
                      item: item,
                      onTap: () => onItemSelected(item),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({
    required this.items,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddReminders,
  });

  final List<HubItem> items;
  final HubCategory? selectedCategory;
  final ValueChanged<HubCategory?> onCategorySelected;
  final VoidCallback onAddReminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminders',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${items.length} active ${items.length == 1 ? 'item' : 'items'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onAddReminders,
                    icon: const Icon(Icons.add),
                    label: const Text('Add reminders'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HubStatusBar(items: items),
              const SizedBox(height: 16),
              HubCategoryFilterBar(
                items: items,
                selectedCategory: selectedCategory,
                onSelected: onCategorySelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubEmptyState extends StatelessWidget {
  const _HubEmptyState({
    required this.signedInEmail,
    required this.onAddReminders,
  });

  final String? signedInEmail;
  final VoidCallback onAddReminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checklist_rtl_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'No reminders yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Signed in as ${signedInEmail ?? 'this account'}.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddReminders,
                icon: const Icon(Icons.add),
                label: const Text('Add reminders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({
    required this.selectedCategory,
    required this.onClearFilter,
  });

  final HubCategory selectedCategory;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${selectedCategory.label.toLowerCase()} reminders',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(Icons.close),
              label: const Text('Show all'),
            ),
          ],
        ),
      ),
    );
  }
}
