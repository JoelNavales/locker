import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
import '../services/auth_repository.dart';
import '../services/locker_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/neu_back_button.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_card.dart';
import '../widgets/neu_text_field.dart';

/// Create a new locker (when [locker] is null) or customize an existing one:
/// rename, set priority, or delete.
class LockerDetailScreen extends ConsumerStatefulWidget {
  const LockerDetailScreen({super.key, this.locker});

  final LockerModel? locker;

  bool get isEditing => locker != null;

  @override
  ConsumerState<LockerDetailScreen> createState() => _LockerDetailScreenState();
}

class _LockerDetailScreenState extends ConsumerState<LockerDetailScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.locker?.subjectName ?? '',
  );
  late Priority _priority = widget.locker?.priority ?? Priority.medium;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_busy;

  String? get _uid => ref.read(authRepositoryProvider).currentUser?.uid;

  Future<void> _save() async {
    final String? uid = _uid;
    if (uid == null || !_canSave) return;
    setState(() => _busy = true);
    final LockerRepository repo = ref.read(lockerRepositoryProvider);
    final String name = _nameController.text.trim();
    try {
      if (widget.isEditing) {
        await repo.update(
          uid,
          widget.locker!.id,
          subjectName: name,
          priority: _priority,
        );
      } else {
        await repo.add(uid, subjectName: name, priority: _priority);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        _showSnack('Could not save. Check your connection.');
      }
    }
  }

  Future<void> _delete() async {
    final String? uid = _uid;
    if (uid == null || !widget.isEditing) return;
    final bool confirmed = await _confirmDelete();
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      await ref.read(lockerRepositoryProvider).delete(uid, widget.locker!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        _showSnack('Could not delete. Check your connection.');
      }
    }
  }

  Future<bool> _confirmDelete() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete locker?',
          style: AppTextStyles.heading(AppColors.ink),
        ),
        content: Text(
          'This removes "${widget.locker!.subjectName}" for good.',
          style: AppTextStyles.body(AppColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL', style: AppTextStyles.label(AppColors.ink)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'DELETE',
              style: AppTextStyles.label(AppColors.priorityHigh),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isEditing ? 'CUSTOMIZE\nLOCKER' : 'NEW\nLOCKER';

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: AppTheme.dotGridPainter),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NeuBackButton(onTap: () => Navigator.of(context).pop()),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.display(
                              AppColors.ink,
                            ).copyWith(fontSize: 34),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    NeuTextField(
                      label: 'Subject name',
                      hint: 'e.g. Capstone',
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    Text('PRIORITY', style: AppTextStyles.label(AppColors.ink)),
                    const SizedBox(height: AppTheme.spaceSm),
                    _PrioritySelector(
                      selected: _priority,
                      onSelect: (p) => setState(() => _priority = p),
                    ),
                    const SizedBox(height: AppTheme.spaceXl),
                    NeuButton(
                      label: _busy
                          ? 'SAVING…'
                          : (widget.isEditing
                                ? 'SAVE CHANGES'
                                : 'CREATE LOCKER'),
                      color: AppColors.priorityLow,
                      foreground: AppColors.onInk,
                      enabled: _canSave,
                      onTap: () {
                        _save();
                      },
                    ),
                    if (widget.isEditing) ...[
                      const SizedBox(height: AppTheme.spaceMd),
                      NeuButton(
                        label: 'DELETE LOCKER',
                        color: AppColors.priorityHigh,
                        foreground: AppColors.onInk,
                        enabled: !_busy,
                        onTap: () {
                          _delete();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected, required this.onSelect});

  final Priority selected;
  final ValueChanged<Priority> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final priority in Priority.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(priority),
              child: NeuCard(
                color: AppColors.forPriority(priority),
                radius: AppTheme.radius,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                border: priority == selected
                    ? Border.all(color: AppColors.ink, width: 5)
                    : null,
                child: Center(
                  child: Text(
                    priority.label,
                    style: AppTextStyles.label(AppColors.onPriority(priority)),
                  ),
                ),
              ),
            ),
          ),
          if (priority != Priority.values.last)
            const SizedBox(width: AppTheme.spaceSm),
        ],
      ],
    );
  }
}
