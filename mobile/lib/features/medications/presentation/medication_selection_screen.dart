import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../assessment/application/assessment_controller.dart';
import '../../assessment/data/schema_repository.dart';
import '../../assessment/domain/field_spec.dart';
import '../data/medication_repository.dart';
import '../domain/medication.dart';

class MedicationSelectionScreen extends ConsumerStatefulWidget {
  const MedicationSelectionScreen({super.key});

  @override
  ConsumerState<MedicationSelectionScreen> createState() =>
      _MedicationSelectionScreenState();
}

class _MedicationSelectionScreenState
    extends ConsumerState<MedicationSelectionScreen> {
  String _query = '';

  final Set<String> _selected = <String>{};

  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Medication>> medications =
        ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select your medications')),
      body: SafeArea(
        child: medications.when(
          loading: () => const AppLoadingView(message: 'Loading medications…'),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(medicationsProvider),
          ),
          data: (List<Medication> all) => Column(
            children: <Widget>[
              Expanded(child: _buildList(all)),
              _SelectionBar(
                selectedCount: _selected.length,
                isStarting: _starting,
                onContinue: () => _start(all),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Medication> all) {
    final List<Medication> visible = _filter(all);
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Choose every medicine you take regularly. '
            'You can select up to ${AssessmentController.maxMedications}.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or drug class',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (visible.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No medication matches "$_query".',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final Medication drug = visible[index];
                return _MedicationTile(
                  medication: drug,
                  selected: _selected.contains(drug.name),
                  onToggle: () => _toggle(drug),
                );
              },
            ),
          ),
      ],
    );
  }

  List<Medication> _filter(List<Medication> all) {
    if (_query.isEmpty) return all;
    final String needle = _query.toLowerCase();
    return all
        .where((Medication drug) =>
            drug.name.toLowerCase().contains(needle) ||
            drug.drugClass.toLowerCase().contains(needle))
        .toList();
  }

  void _toggle(Medication drug) {
    if (_selected.contains(drug.name)) {
      setState(() => _selected.remove(drug.name));
      return;
    }

    if (_selected.length >= AssessmentController.maxMedications) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can assess up to ${AssessmentController.maxMedications} '
            'medicines at a time.',
          ),
        ),
      );
      return;
    }

    setState(() => _selected.add(drug.name));
  }

  Future<void> _start(List<Medication> all) async {
    // Preserve the backend's ordering rather than tap order, so two patients
    // on the same medicines produce the same list.
    final List<Medication> chosen = all
        .where((Medication drug) => _selected.contains(drug.name))
        .toList();
    if (chosen.isEmpty || _starting) return;

    setState(() => _starting = true);
    try {
      final AssessmentSchema schema =
          await ref.read(assessmentSchemaProvider.future);
      if (!mounted) return;

      ref.read(assessmentControllerProvider.notifier).startAll(chosen, schema);
      context.go(AppRoutes.assessment);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.selected,
    required this.onToggle,
  });

  final Medication medication;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primary : theme.dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            medication.name.substring(0, 1),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          medication.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 2),
            Text(medication.drugClass),
            const SizedBox(height: 2),
            Text(
              medication.doseRangeLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: Checkbox(
          value: selected,
          onChanged: (_) => onToggle(),
        ),
        onTap: onToggle,
        selected: selected,
      ),
    );
  }
}

/// The bottom bar: how many are chosen, what the model will do with them, and
/// the button that starts the form.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.selectedCount,
    required this.isStarting,
    required this.onContinue,
  });

  final int selectedCount;
  final bool isStarting;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = selectedCount > 0 && !isStarting;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                selectedCount == 0
                    ? 'No medicine selected yet'
                    : '$selectedCount of ${AssessmentController.maxMedications}'
                        ' selected',
                style: theme.textTheme.labelLarge,
              ),
              if (selectedCount > 1) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  _explanation(selectedCount),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: enabled ? onContinue : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isStarting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            selectedCount <= 1
                                ? 'Continue'
                                : 'Continue with $selectedCount medicines',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Says plainly that each medicine is scored on its own, and warns when the
  /// model's own cap on concomitant medicines has been passed.
  String _explanation(int count) {
    const String base = 'Each medicine is assessed separately.';
    return count > 4
        ? '$base The model counts at most 3 other medicines, so the extra '
            'ones are not reflected in that count.'
        : base;
  }
}
