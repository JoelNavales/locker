import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/task_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../utils/app_dates.dart';
import '../widgets/neu_card.dart';
import 'locker_tasks_screen.dart';

/// Month calendar of task deadlines across every locker. Days with deadlines
/// are marked; selecting a day lists its tasks below. Built as body content for
/// the home screen's Calendar tab (no Scaffold of its own).
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = AppDates.dayOnly(now);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  /// Groups deadline entries by their calendar day.
  Map<DateTime, List<AgendaEntry>> _entriesByDay(List<AgendaEntry> entries) {
    final map = <DateTime, List<AgendaEntry>>{};
    for (final entry in entries) {
      final DateTime day = AppDates.dayOnly(entry.deadline);
      map.putIfAbsent(day, () => []).add(entry);
    }
    return map;
  }

  void _openLocker(AgendaEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LockerTasksScreen(locker: entry.locker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final byDay = _entriesByDay(ref.watch(agendaProvider));
    final List<AgendaEntry> dayEntries = [...?byDay[_selectedDay]]
      ..sort((a, b) => a.task.title.compareTo(b.task.title));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
          child: _MonthHeader(
            label: AppDates.monthYear(_focusedMonth),
            onPrev: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
          child: _MonthGrid(
            month: _focusedMonth,
            selectedDay: _selectedDay,
            byDay: byDay,
            onSelect: (day) => setState(() => _selectedDay = day),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
          child: Text(
            AppDates.shortDate(_selectedDay).toUpperCase(),
            style: AppTextStyles.label(AppColors.ink),
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Expanded(
          child: dayEntries.isEmpty
              ? Center(
                  child: Text(
                    'Nothing due this day.',
                    style: AppTextStyles.body(AppColors.ink),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMd,
                    0,
                    AppTheme.spaceMd,
                    AppTheme.spaceLg,
                  ),
                  itemCount: dayEntries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppTheme.spaceSm),
                  itemBuilder: (_, i) => _AgendaTile(
                    entry: dayEntries[i],
                    onTap: () => _openLocker(dayEntries[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ArrowButton(icon: Icons.chevron_left, onTap: onPrev),
        Text(label.toUpperCase(), style: AppTextStyles.heading(AppColors.ink)),
        _ArrowButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: AppTheme.border,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: AppTheme.hardShadowSmall,
        ),
        child: Icon(icon, color: AppColors.ink),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.byDay,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<AgendaEntry>> byDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final DateTime firstOfMonth = DateTime(month.year, month.month);
    // weekday: Mon=1..Sun=7. Convert to Sunday-first offset (Sun=0).
    final int leadingBlanks = firstOfMonth.weekday % 7;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final DateTime today = AppDates.dayOnly(DateTime.now());

    final List<Widget> cells = [
      for (final initial in AppDates.weekdayInitials)
        Center(
          child: Text(initial, style: AppTextStyles.caption(AppColors.ink)),
        ),
      for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (int day = 1; day <= daysInMonth; day++)
        _DayCell(
          day: day,
          selected: AppDates.sameDay(
            selectedDay,
            DateTime(month.year, month.month, day),
          ),
          isToday: AppDates.sameDay(
            today,
            DateTime(month.year, month.month, day),
          ),
          hasDeadline:
              byDay.containsKey(DateTime(month.year, month.month, day)) &&
              byDay[DateTime(month.year, month.month, day)]!.isNotEmpty,
          onTap: () => onSelect(DateTime(month.year, month.month, day)),
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.hasDeadline,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isToday;
  final bool hasDeadline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill = selected
        ? AppColors.blue
        : (isToday ? AppColors.priorityMedium : AppColors.surface);
    final Color fg = selected ? AppColors.onInk : AppColors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          border: AppTheme.border,
          borderRadius: BorderRadius.circular(AppTheme.radiusTile),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: AppTextStyles.body(fg)),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasDeadline
                    ? (selected ? AppColors.onInk : AppColors.priorityHigh)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required this.entry, required this.onTap});

  final AgendaEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.forPriority(entry.locker.priority);
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        color: AppColors.surface,
        radius: AppTheme.radius,
        shadowOffset: const Offset(4, 4),
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 36,
              decoration: BoxDecoration(
                color: accent,
                border: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.task.title,
                    style: AppTextStyles.title(AppColors.ink).copyWith(
                      decoration: entry.task.done
                          ? TextDecoration.lineThrough
                          : null,
                      color: entry.task.done
                          ? AppColors.ink.withValues(alpha: 0.4)
                          : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.locker.subjectName.toUpperCase(),
                    style: AppTextStyles.caption(AppColors.ink),
                  ),
                ],
              ),
            ),
            if (entry.task.done)
              const Icon(
                Icons.check_circle,
                color: AppColors.priorityLow,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
