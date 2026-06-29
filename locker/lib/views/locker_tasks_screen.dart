import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/locker_model.dart';
import '../models/task_model.dart';
import '../services/auth_repository.dart';
import '../services/task_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../utils/app_dates.dart';
import '../widgets/neu_back_button.dart';
import '../widgets/neu_card.dart';
import '../widgets/neu_text_field.dart';
import 'locker_detail_screen.dart';

/// Lists the tasks for a single locker (subject). Tasks can be checked off,
/// expanded to manage subtasks, or deleted. The locker itself is customized
/// from the gear button in the header.
class LockerTasksScreen extends ConsumerStatefulWidget {
  const LockerTasksScreen({super.key, required this.locker});

  final LockerModel locker;

  @override
  ConsumerState<LockerTasksScreen> createState() => _LockerTasksScreenState();
}

class _LockerTasksScreenState extends ConsumerState<LockerTasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _adding = false;

  String get _lockerId => widget.locker.id;
  String? get _uid => ref.read(authRepositoryProvider).currentUser?.uid;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final String? uid = _uid;
    final String title = _taskController.text.trim();
    if (uid == null || title.isEmpty || _adding) return;
    setState(() => _adding = true);
    try {
      await ref.read(taskRepositoryProvider).add(uid, _lockerId, title: title);
      _taskController.clear();
    } catch (_) {
      _showSnack('Could not add task. Check your connection.');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _openCustomize() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LockerDetailScreen(locker: widget.locker),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider(_lockerId));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: AppTheme.dotGridPainter)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Row(
                    children: [
                      NeuBackButton(onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: Text(
                          widget.locker.subjectName.toUpperCase(),
                          style: AppTextStyles.heading(AppColors.ink),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openCustomize,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.forPriority(
                              widget.locker.priority,
                            ),
                            border: AppTheme.border,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radius,
                            ),
                            boxShadow: AppTheme.hardShadowSmall,
                          ),
                          child: Icon(
                            Icons.tune,
                            color: AppColors.onPriority(widget.locker.priority),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: NeuTextField(
                          label: 'New task',
                          hint: 'e.g. Read chapter 4',
                          controller: _taskController,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      _SquareAddButton(
                        enabled:
                            _taskController.text.trim().isNotEmpty && !_adding,
                        onTap: _addTask,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Expanded(
                  child: tasks.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(
                        'Could not load tasks.',
                        style: AppTextStyles.body(AppColors.ink),
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? _EmptyTasks()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppTheme.spaceMd,
                              0,
                              AppTheme.spaceMd,
                              AppTheme.spaceLg,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppTheme.spaceSm),
                            itemBuilder: (_, i) =>
                                _TaskTile(lockerId: _lockerId, task: items[i]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_box_outlined, size: 48, color: AppColors.ink),
          const SizedBox(height: AppTheme.spaceMd),
          Text('NO TASKS YET', style: AppTextStyles.heading(AppColors.ink)),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            'Add your first task above.',
            style: AppTextStyles.body(AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// A task row that expands to reveal and manage its subtasks.
class _TaskTile extends ConsumerStatefulWidget {
  const _TaskTile({required this.lockerId, required this.task});

  final String lockerId;
  final TaskModel task;

  @override
  ConsumerState<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<_TaskTile> {
  final TextEditingController _subtaskController = TextEditingController();
  bool _expanded = false;

  TaskModel get _task => widget.task;
  String get _lockerId => widget.lockerId;
  String? get _uid => ref.read(authRepositoryProvider).currentUser?.uid;
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    }
  }

  Future<void> _addSubtask() async {
    final String? uid = _uid;
    final String title = _subtaskController.text.trim();
    if (uid == null || title.isEmpty) return;
    _subtaskController.clear();
    await _guard(() => _repo.addSubtask(uid, _lockerId, _task, title: title));
  }

  Future<void> _pickDeadline() async {
    final String? uid = _uid;
    if (uid == null) return;
    final DateTime now = DateTime.now();
    final DateTime initial = _task.deadline ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    await _guard(
      () =>
          _repo.setDeadline(uid, _lockerId, _task.id, AppDates.dayOnly(picked)),
    );
  }

  Future<void> _clearDeadline() async {
    final String? uid = _uid;
    if (uid == null) return;
    await _guard(() => _repo.setDeadline(uid, _lockerId, _task.id, null));
  }

  Future<void> _confirmDelete() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete task?',
          style: AppTextStyles.heading(AppColors.ink),
        ),
        content: Text(
          'This removes "${_task.title}" and its subtasks.',
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
    if (ok != true) return;
    final String? uid = _uid;
    if (uid == null) return;
    await _guard(() => _repo.delete(uid, _lockerId, _task));
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _uid;
    return NeuCard(
      color: AppColors.surface,
      radius: AppTheme.radius,
      shadowOffset: const Offset(4, 4),
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CheckBox(
                checked: _task.done,
                onTap: uid == null
                    ? null
                    : () =>
                          _guard(() => _repo.toggleDone(uid, _lockerId, _task)),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _task.title,
                      style: AppTextStyles.title(AppColors.ink).copyWith(
                        decoration: _task.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: _task.done
                            ? AppColors.ink.withValues(alpha: 0.4)
                            : AppColors.ink,
                      ),
                    ),
                    if (_task.deadline != null) ...[
                      const SizedBox(height: 2),
                      _DeadlineLabel(
                        deadline: _task.deadline!,
                        done: _task.done,
                      ),
                    ],
                  ],
                ),
              ),
              if (_task.hasSubtasks)
                Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spaceXs),
                  child: Text(
                    '${_task.completedSubtasks}/${_task.subtasks.length}',
                    style: AppTextStyles.body(AppColors.ink),
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: AppTheme.spaceSm),
            const Divider(color: AppColors.ink, thickness: 2, height: 2),
            const SizedBox(height: AppTheme.spaceSm),
            for (int i = 0; i < _task.subtasks.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
                child: Row(
                  children: [
                    _CheckBox(
                      size: 22,
                      checked: _task.subtasks[i].done,
                      onTap: uid == null
                          ? null
                          : () => _guard(
                              () =>
                                  _repo.toggleSubtask(uid, _lockerId, _task, i),
                            ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        _task.subtasks[i].title,
                        style: AppTextStyles.body(AppColors.ink).copyWith(
                          decoration: _task.subtasks[i].done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: uid == null
                          ? null
                          : () => _guard(
                              () =>
                                  _repo.deleteSubtask(uid, _lockerId, _task, i),
                            ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addSubtask(),
                    style: AppTextStyles.body(AppColors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Add subtask',
                      hintStyle: AppTextStyles.body(
                        AppColors.ink.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _subtaskController.text.trim().isEmpty
                      ? null
                      : _addSubtask,
                  child: Icon(
                    Icons.add,
                    color: _subtaskController.text.trim().isEmpty
                        ? AppColors.ink.withValues(alpha: 0.3)
                        : AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                const Icon(Icons.event, size: 18, color: AppColors.ink),
                const SizedBox(width: AppTheme.spaceXs),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Text(
                    _task.deadline == null
                        ? 'SET DEADLINE'
                        : 'DUE ${AppDates.shortDate(_task.deadline!).toUpperCase()}',
                    style: AppTextStyles.body(AppColors.ink),
                  ),
                ),
                if (_task.deadline != null) ...[
                  const SizedBox(width: AppTheme.spaceSm),
                  GestureDetector(
                    onTap: _clearDeadline,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _confirmDelete,
                child: Text(
                  'DELETE TASK',
                  style: AppTextStyles.body(AppColors.priorityHigh),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small "DUE …" label under a task title. Turns red when the deadline has
/// passed and the task is still open.
class _DeadlineLabel extends StatelessWidget {
  const _DeadlineLabel({required this.deadline, required this.done});

  final DateTime deadline;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final bool overdue =
        !done && deadline.isBefore(AppDates.dayOnly(DateTime.now()));
    final Color color = overdue
        ? AppColors.priorityHigh
        : AppColors.ink.withValues(alpha: 0.6);
    return Text(
      '${overdue ? 'OVERDUE · ' : 'DUE '}${AppDates.shortDate(deadline).toUpperCase()}',
      style: AppTextStyles.caption(color),
    );
  }
}

/// Square neo-brutalist checkbox.
class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked, required this.onTap, this.size = 26});

  final bool checked;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked ? AppColors.priorityLow : AppColors.surface,
          border: AppTheme.border,
          borderRadius: BorderRadius.circular(AppTheme.radiusTile),
        ),
        child: checked
            ? Icon(Icons.check, size: size - 8, color: AppColors.onInk)
            : null,
      ),
    );
  }
}

/// Square "+" button matching the new-task field height.
class _SquareAddButton extends StatelessWidget {
  const _SquareAddButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.priorityLow,
            border: AppTheme.border,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: AppTheme.hardShadowSmall,
          ),
          child: const Icon(Icons.add, color: AppColors.onInk, size: 28),
        ),
      ),
    );
  }
}
