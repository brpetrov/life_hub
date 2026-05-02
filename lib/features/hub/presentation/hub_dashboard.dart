import 'package:flutter/material.dart';

import '../data/hub_item_repository.dart';
import '../domain/hub_category.dart';
import '../domain/hub_item.dart';
import 'hub_category_filter_bar.dart';
import 'hub_item_card.dart';
import 'hub_item_details_sheet.dart';
import 'hub_status_bar.dart';

class HubDashboard extends StatefulWidget {
  const HubDashboard({
    required this.repository,
    required this.onSignOut,
    this.signedInEmail,
    this.onAddReminders,
    super.key,
  });

  final HubItemRepository repository;
  final VoidCallback onSignOut;
  final String? signedInEmail;
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
    HubItemDetailsSheet.show(context, item: item);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Hub'),
        actions: [
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
  });

  final List<HubItem> items;
  final HubCategory? selectedCategory;
  final ValueChanged<HubCategory?> onCategorySelected;

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
