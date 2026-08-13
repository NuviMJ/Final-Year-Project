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

/// Step one of the assessment: which medication is being taken.
///
/// The list comes from the backend rather than being hard-coded, so it always
/// matches what the deployed model can actually assess. Selecting a medication
/// also fixes the dose unit and permitted dose range for the next step, which
/// is why those are shown here.
class MedicationSelectionScreen extends ConsumerStatefulWidget {
  const MedicationSelectionScreen({super.key});

  @override
  ConsumerState<MedicationSelectionScreen> createState() =>
      _MedicationSelectionScreenState();
}

class _MedicationSelectionScreenState
    extends ConsumerState<MedicationSelectionScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Medication>> medications =
        ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select your medication')),
      body: SafeArea(
        child: medications.when(
          loading: () => const AppLoadingView(message: 'Loading medications…'),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(medicationsProvider),
          ),
          data: (List<Medication> all) => _List(
            medications: _filter(all),
            query: _query,
            onQueryChanged: (String value) => setState(() => _query = value),
          ),
        ),
      ),
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
}

class _List extends StatelessWidget {
  const _List({
    required this.medications,
    required this.query,
    required this.onQueryChanged,
  });

  final List<Medication> medications;
  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or drug class',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (medications.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No medication matches "$query".',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) =>
                  _MedicationTile(medication: medications[index]),

            ),
          ),
      ],
    );
  }
}

class _MedicationTile extends ConsumerWidget {
  const _MedicationTile({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _startAssessment(context, ref),
      ),
    );
  }

  /// Seeds a fresh assessment for this medication and opens the form.
  ///
  /// The schema must be in hand before the form is built, since every field and
  /// its starting value comes from it. Awaiting the provider here means the
  /// first tap absorbs the fetch — subsequent ones are instant, because the
  /// contract is cached for the session.
  Future<void> _startAssessment(BuildContext context, WidgetRef ref) async {
    try {
      final AssessmentSchema schema =
          await ref.read(assessmentSchemaProvider.future);
      if (!context.mounted) return;

      ref.read(assessmentControllerProvider.notifier).start(medication, schema);
      context.go(AppRoutes.assessment);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
