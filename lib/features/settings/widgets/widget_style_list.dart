import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/core/i18n/l10n.dart';

class WidgetStyleList extends StatelessWidget {
  const WidgetStyleList({super.key});

  static const _channel = MethodChannel('soulstate/app_icon');
  static const _legacyChannel = MethodChannel('streak/app_icon');

  static Future<T?> invokeChannel<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } catch (_) {
      return await _legacyChannel.invokeMethod<T>(method, arguments);
    }
  }
  static const _kinds = [
    'habit',
    'today',
    'heatmap',
    'todos',
    'dashboard',
    'money',
    'meals',
  ];

  static String _name(BuildContext context, String kind) => switch (kind) {
    'today' => context.l10n.widget_kind_today,
    'heatmap' => context.l10n.widget_kind_heatmap,
    'todos' => context.l10n.widget_kind_todos,
    'dashboard' => 'Dashboard Widget',
    'money' => 'Money Tracker Widget',
    'meals' => 'Meal Tracker Widget',
    _ => context.l10n.widget_kind_habit,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final kind in _kinds)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WidgetTile(kind: kind, name: _name(context, kind)),
          ),
      ],
    );
  }
}

class _WidgetTile extends StatefulWidget {
  const _WidgetTile({required this.kind, required this.name});

  final String kind;
  final String name;

  @override
  State<_WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<_WidgetTile> {
  late final _preview = WidgetStyleList.invokeChannel<Uint8List>(
    'widgetPreview',
    {'kind': widget.kind},
  );

  void _onTap() {
    _showWidgetOptions(context, widget.kind, widget.name);
  }

  void _showWidgetOptions(BuildContext context, String kind, String title) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      switch (kind) {
                        'dashboard' => LucideIcons.layoutDashboard,
                        'money' => LucideIcons.wallet,
                        'meals' => LucideIcons.utensils,
                        'todos' => LucideIcons.checkSquare,
                        'heatmap' => LucideIcons.grid,
                        _ => LucideIcons.flame,
                      },
                      color: Theme.of(sheetContext).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  switch (kind) {
                    'dashboard' =>
                      'Quick glances for your daily habit streaks, completed tasks, and score directly synced with your Soul State Vault.',
                    'money' =>
                      'Compact home screen balance, monthly expenditures, and one-tap quick transaction logging.',
                    'meals' =>
                      'Daily calorie counter, nutrition healthiness rating, and rapid meal logging from your launcher.',
                    'todos' =>
                      'Interactive checklist of your daily tasks and reminders right on your home screen.',
                    'today' =>
                      'Quick-tap habit check-ins and today\'s completion streak.',
                    'heatmap' =>
                      'Annual activity contribution grid for habits.',
                    _ => 'Custom Soul State home screen widget.',
                  },
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final pinned = await WidgetStyleList.invokeChannel<bool>(
                      'pinWidget',
                      {'kind': kind},
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            pinned == true
                                ? 'Widget pinned to Home Screen'
                                : 'Select widget from your Home Screen launcher',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Add to Home Screen'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    WidgetStyleList.invokeChannel(
                      'openWidgetEditor',
                      {'kind': kind},
                    );
                  },
                  icon: const Icon(LucideIcons.palette),
                  label: const Text('Customize Appearance'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 132,
                child: FutureBuilder<Uint8List?>(
                  future: _preview,
                  builder: (context, shot) {
                    final bytes = shot.data;
                    if (bytes != null && bytes.isNotEmpty) {
                      return Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      );
                    }
                    return _CustomWidgetMockup(kind: widget.kind);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.pencil, size: 18, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomWidgetMockup extends StatelessWidget {
  const _CustomWidgetMockup({required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141419) : const Color(0xFFE8E9F0);
    final text = isDark ? Colors.white : Colors.black87;
    final muted = isDark ? Colors.white54 : Colors.black45;

    return Center(
      child: Container(
        width: 260,
        height: 124,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        child: switch (kind) {
          'dashboard' => _buildDashboardMock(text, muted),
          'money' => _buildMoneyMock(text, muted),
          'meals' => _buildMealsMock(text, muted),
          _ => _buildGenericMock(text, muted),
        },
      ),
    );
  }

  Widget _buildDashboardMock(Color text, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.flame, size: 16, color: Color(0xFFFF5722)),
                const SizedBox(width: 6),
                Text(
                  'Soul State Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '80% Done',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('Habits', '4 / 5', text, muted),
            _statItem('Money', '₹1,240', text, muted),
            _statItem('Meals', '3 logged', text, muted),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.8,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyMock(Color text, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.wallet, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  'Money Tracker',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ],
            ),
            Text(
              'October',
              style: TextStyle(fontSize: 10, color: muted),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining Balance',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
                Text(
                  '+₹14,500.00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '-₹2,400',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '+ Add Expense',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealsMock(Color text, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.utensils, size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  'Meal & Nutrition',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '75% Healthy',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories Logged',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
                Text(
                  '1,850 / 2,200 kcal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _mealIcon(LucideIcons.coffee, true),
                const SizedBox(width: 4),
                _mealIcon(LucideIcons.sandwich, true),
                const SizedBox(width: 4),
                _mealIcon(LucideIcons.utensils, true),
                const SizedBox(width: 4),
                _mealIcon(LucideIcons.apple, false),
              ],
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.84,
            minHeight: 5,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericMock(Color text, Color muted) {
    return Center(
      child: Text(
        'Soul State Widget',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

  Widget _statItem(String label, String value, Color text, Color muted) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: text)),
        Text(label, style: TextStyle(fontSize: 9, color: muted)),
      ],
    );
  }

  Widget _mealIcon(IconData icon, bool done) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: done ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 11,
        color: done ? const Color(0xFF10B981) : Colors.grey,
      ),
    );
  }
}
