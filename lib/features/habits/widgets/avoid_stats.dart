import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/utils/amount_format.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/core/widgets/section_label.dart';
import 'package:soulstate/features/habits/data/avoid_month.dart';
import 'package:soulstate/features/habits/data/book_read.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/habit_form_kind.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/core/widgets/charts/stat_charts.dart';
import 'package:soulstate/core/widgets/charts/stat_kit.dart';

String goalAmount(
  BuildContext context, {
  required HabitKind kind,
  required bool time,
  required String unit,
  required double value,
}) {
  if (kind != HabitKind.quantitative) return context.l10n.count_times(value.round());
  if (time) return formatMinutes(value);
  return '${formatAmount(value)} $unit'.trim();
}

String habitGoalAmount(BuildContext context, Habit habit, double value) => goalAmount(
      context,
      kind: habit.kind,
      time: habit.isTimeAmount,
      unit: habit.unitLabel,
      value: value,
    );

class CleanGoalCard extends StatelessWidget {
  const CleanGoalCard({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final goal = habit.cleanGoal;
    final streak = habit.currentStreak;
    final reached = streak >= goal;
    return _GoalCard(
      title: context.l10n.clean_goal,
      ratio: goal <= 0 ? 0 : streak / goal,
      reached: reached,
      value: '$streak',
      of: context.l10n.clean_goal_of(goal),
      headline: reached
          ? context.l10n.clean_goal_reached
          : context.l10n.clean_goal_left(goal - streak),
      sub: reached ? context.l10n.clean_goal_again : context.l10n.count_days(goal),
      color: habit.color.shownIn(context),
    );
  }
}

class TotalGoalCard extends StatelessWidget {
  const TotalGoalCard({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final goal = habit.totalGoal;
    final done = habit.totalDone;
    final reached = done >= goal;
    String amount(double value) => habitGoalAmount(context, habit, value);
    return _GoalCard(
      title: context.l10n.total_goal,
      ratio: done / goal,
      reached: reached,
      value: habit.amountText(done),
      of: context.l10n.total_goal_of(habit.amountText(goal)),
      headline: reached
          ? context.l10n.clean_goal_reached
          : context.l10n.total_goal_left(amount(goal - done)),
      sub: amount(goal),
      color: habit.color.shownIn(context),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.habit});

  final Habit habit;

  Future<void> _newBook(BuildContext context) async {
    final controller = context.read<HabitsController>();
    final pages = await pickBookPages(
      context,
      title: context.l10n.book_new,
      pages: habit.bookPages,
      unit: habit.unitLabel,
      color: habit.color.shownIn(context),
    );
    if (pages == null) return;
    await controller.update(habit.newBook(pages));
  }

  @override
  Widget build(BuildContext context) {
    final book = habit.book;
    final color = habit.color.shownIn(context);
    String amount(double value) => habitGoalAmount(context, habit, value);
    return _GoalCard(
      title: context.l10n.book,
      ratio: book.page / book.pages,
      reached: false,
      value: habit.amountText(book.page),
      of: context.l10n.total_goal_of(habit.amountText(book.pages)),
      headline: context.l10n.total_goal_left(amount(book.left)),
      sub: context.l10n.book_reads(book.finished),
      color: color,
      footer: _BookReads(
        reads: book.reads,
        color: color,
        amount: amount,
        onNewBook: () => _newBook(context),
      ),
    );
  }
}

class _BookReads extends StatelessWidget {
  const _BookReads({
    required this.reads,
    required this.color,
    required this.amount,
    required this.onNewBook,
  });

  final List<BookRead> reads;
  final Color color;
  final String Function(double value) amount;
  final VoidCallback onNewBook;

  String _day(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return date.year == AppClock.today().year
        ? DateFormat.MMMd(locale).format(date)
        : DateFormat.yMMMd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final strong = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: context.colors.onSurface,
    );
    final muted = TextStyle(fontSize: 12, color: context.tokens.muted);

    final rows = [
      for (final (i, read) in reads.indexed)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: read.isFinished ? color : color.withValues(alpha: 0.14),
                ),
                child: read.isFinished
                    ? Icon(LucideIcons.check, size: 16, color: color.ink)
                    : Text('${i + 1}', style: strong.copyWith(fontSize: 13, color: color)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      read.isFinished
                          ? TextSpan(children: [
                              TextSpan(text: _day(context, read.start)),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    LucideIcons.arrowRight,
                                    size: 14,
                                    color: context.tokens.muted,
                                  ),
                                ),
                              ),
                              TextSpan(text: _day(context, read.end!)),
                            ])
                          : TextSpan(text: context.l10n.book_since(_day(context, read.start))),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: strong,
                    ),
                    Text(
                      '${context.l10n.book_read_number(i + 1)} · ${amount(read.pages)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                read.isFinished
                    ? context.l10n.count_days(read.days)
                    : context.l10n.book_reading_now,
                style: muted.copyWith(
                  fontWeight: FontWeight.w700,
                  color: read.isFinished ? null : color,
                ),
              ),
            ],
          ),
        ),
    ].reversed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        ...rows,
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: onNewBook,
            icon: Icon(LucideIcons.bookPlus, size: 17, color: color),
            label: Text(context.l10n.book_new, style: TextStyle(color: color)),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.ratio,
    required this.reached,
    required this.value,
    required this.of,
    required this.headline,
    required this.sub,
    required this.color,
    this.footer,
  });

  final String title;
  final double ratio;
  final bool reached;
  final String value;
  final String of;
  final String headline;
  final String sub;
  final Color color;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tint = reached ? context.tokens.success : color;
    final titleStyle = TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: context.colors.onSurface,
    );
    final body = TextStyle(
      fontSize: 12.5,
      height: 1.35,
      color: context.tokens.muted,
    );

    final top = Row(
      children: [
        _GoalRing(
          ratio: ratio,
          reached: reached,
          value: value,
          of: of,
          color: tint,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                headline,
                style: titleStyle.copyWith(color: reached ? tint : null),
              ),
              const SizedBox(height: 3),
              Text(sub, style: body),
            ],
          ),
        ),
      ],
    );
    final content = footer == null
        ? top
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [top, footer!],
          );

    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({
    required this.ratio,
    required this.reached,
    required this.value,
    required this.of,
    required this.color,
  });

  final double ratio;
  final bool reached;
  final String value;
  final String of;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 74,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: t,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
            Center(
              child: reached
                  ? Icon(LucideIcons.trophy, size: 26, color: color)
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: context.colors.onSurface,
                              ),
                            ),
                            Text(
                              of,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.tokens.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvoidMonthSection extends StatefulWidget {
  const AvoidMonthSection({super.key, required this.habit});

  final Habit habit;

  @override
  State<AvoidMonthSection> createState() => _AvoidMonthSectionState();
}

class _AvoidMonthSectionState extends State<AvoidMonthSection> {
  late DateTime _month = _current;

  DateTime get _current {
    final today = AppClock.today();
    return DateTime(today.year, today.month);
  }

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final symbol = context.watch<SettingsController>().currency;
    final locale = Localizations.localeOf(context).toString();
    String money(double value) => formatMoney(value, symbol, locale);

    final first = AvoidMonth.firstOf(habit);
    final month = _month.isBefore(first) ? first : _month;
    final data = AvoidMonth.of(habit, month);
    final showSaved = habit.hasCost;
    final showSpent = habit.logsSpent || data.spent > 0;
    final balance = data.saved - data.spent;
    final expenses = data.expenses;
    String day(DateTime date) => DateFormat.MMMEd(locale).format(date);

    final label = DateFormat.yMMMM(locale).format(month);
    final nav = _MonthNav(
      label: label.isEmpty ? label : label[0].toUpperCase() + label.substring(1),
      onPrevious: month.isAfter(first) ? () => _shift(-1) : null,
      onNext: month.isBefore(_current) ? () => _shift(1) : null,
    );

    final color = habit.color.shownIn(context);
    final success = context.tokens.success;
    final danger = context.tokens.danger;
    final history = _history(context, habit, month, locale, danger);
    final stats = [
      (LucideIcons.shieldCheck, context.l10n.clean_days, '${data.cleanDays}', color),
      (LucideIcons.triangleAlert, context.l10n.relapses, '${data.relapses}', danger),
      if (showSaved)
        (LucideIcons.piggyBank, context.l10n.money_saved, money(data.saved), success),
      if (showSpent)
        (LucideIcons.wallet, context.l10n.money_spent, money(data.spent), danger),
      if (showSaved && showSpent)
        (
          LucideIcons.scale,
          context.l10n.avoid_balance,
          '${balance > 0 ? '+' : ''}${money(balance)}',
          balance >= 0 ? success : danger,
        ),
    ];

    final tiles = [
      for (final (i, (icon, label, value, tint)) in stats.indexed)
        MiniStat(
          icon: icon,
          label: label,
          value: value,
          color: tint,
          wide: i.isEven && i == stats.length - 1,
        ),
    ];
    final body = Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          i + 1 < tiles.length
              ? StatPair(left: tiles[i], right: tiles[i + 1])
              : tiles[i],
        ],
        for (final (date, amount) in expenses) ...[
          const SizedBox(height: 8),
          MiniStat(
            icon: LucideIcons.receipt,
            label: day(date),
            value: money(amount),
            color: danger,
            wide: true,
          ),
        ],
      ],
    );

    return _withHistory(history, Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(context.l10n.avoid_month, trailing: nav),
        body,
      ],
    ));
  }

  Widget _withHistory(Widget? history, Widget month) {
    if (history == null) return month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [history, const SizedBox(height: 20), month],
    );
  }

  Widget? _history(
    BuildContext context,
    Habit habit,
    DateTime month,
    String locale,
    Color danger,
  ) {
    final months = AvoidMonth.monthsOf(habit);
    if (months.length < 2) return null;
    final counts = [for (final m in months) AvoidMonth.of(habit, m).relapses];
    final total = counts.fold(0, (sum, n) => sum + n);
    final shown = months.length > 12 ? months.length - 12 : 0;
    final average = context.l10n.times_per_month(
      formatAmount(((total / months.length) * 10).round() / 10),
    );
    final last = months.length - shown - 1;
    final pick = months.indexOf(month) - shown;
    final bars = ValueBars(
      values: [for (final n in counts.skip(shown)) n.toDouble()],
      color: danger,
      barWidth: 11,
      selected: pick >= 0 ? pick : null,
      onSelect: (index) => setState(() => _month = months[shown + index]),
      label: (index) => last < 7 || (last - index).isEven
          ? DateFormat.MMM(locale).format(months[shown + index])
          : '',
      tooltip: (value) => context.l10n.count_times(value.round()),
      axisFormat: (value) => '${value.round()}',
    );
    final caption = '${context.l10n.average_short} · $average';

    return StatCard(
      title: context.l10n.avoid_by_month,
      icon: LucideIcons.chartColumn,
      color: danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption, style: statLabel(context)),
          const SizedBox(height: 18),
          bars,
        ],
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final muted = context.tokens.muted;
    Widget arrow(IconData icon, VoidCallback? onTap) => IconButton(
          icon: Icon(icon, size: 18),
          color: muted,
          disabledColor: muted.withValues(alpha: 0.3),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          onPressed: onTap,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(LucideIcons.chevronLeft, onPrevious),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
        ),
        arrow(LucideIcons.chevronRight, onNext),
      ],
    );
  }
}
