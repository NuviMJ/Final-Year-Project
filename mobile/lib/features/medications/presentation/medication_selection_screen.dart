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
import '../../../l10n/app_localizations.dart';

/// Step one of the assessment: which medications are being taken, and at what
/// dose.
///
/// The list comes from the backend rather than being hard-coded, so it always
/// matches what the deployed model can actually assess.
///
/// Dose is asked here rather than on the form because it is the one input that
/// differs per medication — a single "daily dose" question cannot describe
/// four tablets. Everything the form goes on to ask describes the patient, and
/// is the same whichever tablet is being scored.
///
/// The model still scores one drug at a time, so the selection produces one
/// prediction per medication rather than a joint assessment.
class MedicationSelectionScreen extends ConsumerStatefulWidget {
  const MedicationSelectionScreen({super.key});

  @override
  ConsumerState<MedicationSelectionScreen> createState() =>
      _MedicationSelectionScreenState();
}

class _MedicationSelectionScreenState
    extends ConsumerState<MedicationSelectionScreen> {
  String _query = '';

  /// Selected drug names mapped to the dose the patient takes.
  ///
  /// Keyed by name rather than by object, so filtering the visible list can
  /// never drop a selection already made.
  final Map<String, double> _selected = <String, double>{};

  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Medication>> medications =
        ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationsSelectYourMedications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.assessmentBack,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: medications.when(
          loading: () => AppLoadingView(message: l10n.medicationsLoadingMedications),
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
            'Choose every medicine you take regularly, up to '
            '${AssessmentController.maxMedications}. '
            'Check the daily dose shown and change it if it is not yours.',
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
                  dose: _selected[drug.name],
                  onToggle: () => _toggle(drug),
                  onEditDose: () => _editDose(drug),
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
    if (_selected.containsKey(drug.name)) {
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

    // Selecting a medicine offers its usual prescribed dose straight away, so
    // a patient on a standard dose has nothing further to do.
    setState(() => _selected[drug.name] = drug.defaultDose);
  }

  Future<void> _editDose(Medication drug) async {
    final double? chosen = await showDialog<double>(
      context: context,
      builder: (BuildContext context) => _DosePickerDialog(
        medication: drug,
        current: _selected[drug.name] ?? drug.defaultDose,
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _selected[drug.name] = chosen);
  }

  /// Seeds a fresh assessment for every selected medication and opens the form.
  ///
  /// The schema must be in hand before the form is built, since every field and
  /// its starting value comes from it. Awaiting the provider here means the
  /// first attempt absorbs the fetch — later ones are instant, because the
  /// contract is cached for the session.
  Future<void> _start(List<Medication> all) async {
    // Preserve the backend's ordering rather than tap order, so two patients
    // on the same medicines produce the same list.
    final List<Medication> chosen = all
        .where((Medication drug) => _selected.containsKey(drug.name))
        .toList();
    if (chosen.isEmpty || _starting) return;

    setState(() => _starting = true);
    try {
      final AssessmentSchema schema =
          await ref.read(assessmentSchemaProvider.future);
      if (!mounted) return;

      ref.read(assessmentControllerProvider.notifier).startAll(
            chosen,
            schema,
            doses: Map<String, double>.of(_selected),
          );
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

/// One medication: its name, and once selected, its daily dose.
///
/// Drug class and permitted dose range are deliberately not shown. A patient
/// choosing their own tablets recognises the name; the rest was detail written
/// for a developer reading the API.
class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.dose,
    required this.onToggle,
    required this.onEditDose,
  });

  final Medication medication;

  /// Null when the medication is not selected.
  final double? dose;

  final VoidCallback onToggle;
  final VoidCallback onEditDose;

  bool get _selected => dose != null;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selected ? AppColors.primary : theme.dividerColor,
          width: _selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        leading: Checkbox(
          value: _selected,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          medication.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: _selected
            ? Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  medication.doseLabel(dose!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        trailing: _selected
            ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.medicationsChangeTheDose,
                onPressed: onEditDose,
              )
            : null,
        onTap: onToggle,
        selected: _selected,
      ),
    );
  }
}

/// Lets the patient pick from the doses this drug is actually prescribed at.
///
/// Offering the real doses rather than a slider means the value is always one
/// the model has seen, and sidesteps rounding: a slider stepping across
/// amlodipine's 2.5–10 mg range could not land on 2.5 or 7.5 at all.
class _DosePickerDialog extends StatelessWidget {
  const _DosePickerDialog({required this.medication, required this.current});

  final Medication medication;
  final double current;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<double> options = medication.typicalDoses.isEmpty
        ? <double>[medication.doseMin, medication.defaultDose, medication.doseMax]
        : medication.typicalDoses;

    return AlertDialog(
      title: Text(medication.name),
      contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.medicationsHowMuchDoYou,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            for (final double option in options)
              RadioListTile<double>(
                value: option,
                groupValue: current,
                title: Text(medication.doseLabel(option)),
                onChanged: (double? selected) =>
                    Navigator.of(context).pop(selected),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.medicationsCancel),
        ),
      ],
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
