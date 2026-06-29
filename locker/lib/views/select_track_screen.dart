import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../viewmodels/track_vm.dart';
import '../widgets/error_banner.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_text_field.dart';

/// Collects the new user's education level and strand/course. Shown right
/// after signup; once saved, the [AuthGate] routes through to home.
class SelectTrackScreen extends ConsumerWidget {
  const SelectTrackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TrackState state = ref.watch(trackViewModelProvider);
    final TrackViewModel vm = ref.read(trackViewModelProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: AppTheme.dotGridPainter)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHERE DO\nYOU BELONG?',
                    style: AppTextStyles.display(
                      AppColors.ink,
                    ).copyWith(fontSize: 38),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    'Pick your level, then your ${state.level.trackLabel.toLowerCase()}.',
                    style: AppTextStyles.body(AppColors.ink),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  _LevelToggle(level: state.level, onChanged: vm.setLevel),
                  const SizedBox(height: AppTheme.spaceLg),
                  if (state.level == EducationLevel.shs)
                    _StrandPicker(
                      selected: state.strand,
                      onSelect: vm.selectStrand,
                    )
                  else
                    NeuTextField(
                      label: 'Course',
                      hint: 'e.g. BS Computer Science',
                      onChanged: vm.setCourse,
                    ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    ErrorBanner(message: state.errorMessage!),
                  ],
                  const SizedBox(height: AppTheme.spaceLg),
                  NeuButton(
                    label: state.isSubmitting ? 'SAVING…' : 'CONTINUE →',
                    color: AppColors.blue,
                    foreground: AppColors.onInk,
                    enabled: state.canSubmit,
                    onTap: () {
                      vm.submit();
                    },
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          ref.read(authRepositoryProvider).signOut(),
                      child: Text(
                        'NOT YOU? SIGN OUT',
                        style: AppTextStyles.label(
                          AppColors.ink,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelToggle extends StatelessWidget {
  const _LevelToggle({required this.level, required this.onChanged});

  final EducationLevel level;
  final ValueChanged<EducationLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in EducationLevel.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option == level ? AppColors.violet : AppColors.surface,
                  border: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  boxShadow: option == level
                      ? AppTheme.hardShadowSmall
                      : const [],
                ),
                child: Text(
                  option.label.toUpperCase(),
                  style: AppTextStyles.label(
                    option == level ? AppColors.onInk : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          if (option != EducationLevel.values.last)
            const SizedBox(width: AppTheme.spaceMd),
        ],
      ],
    );
  }
}

class _StrandPicker extends StatelessWidget {
  const _StrandPicker({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STRAND', style: AppTextStyles.label(AppColors.ink)),
        const SizedBox(height: AppTheme.spaceSm),
        Wrap(
          spacing: AppTheme.spaceSm,
          runSpacing: AppTheme.spaceSm,
          children: [
            for (final strand in TrackViewModel.shsStrands)
              GestureDetector(
                onTap: () => onSelect(strand),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                    vertical: AppTheme.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: strand == selected
                        ? AppColors.priorityMedium
                        : AppColors.surface,
                    border: AppTheme.border,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    boxShadow: strand == selected
                        ? AppTheme.hardShadowSmall
                        : const [],
                  ),
                  child: Text(
                    strand.toUpperCase(),
                    style: AppTextStyles.label(AppColors.ink),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
