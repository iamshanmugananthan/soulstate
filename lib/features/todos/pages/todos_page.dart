import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/routing/back_handlers.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/app_confirm_dialog.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/core/widgets/app_text_field.dart';
import 'package:soulstate/core/widgets/hold_menu.dart';
import 'package:soulstate/core/widgets/glass.dart';
import 'package:soulstate/core/widgets/option_sheet.dart';
import 'package:soulstate/features/settings/pages/settings_page.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/features/todos/data/todo_groups.dart';
import 'package:soulstate/features/todos/pages/todo_editor_page.dart';
import 'package:soulstate/features/todos/state/todo_tags_controller.dart';
import 'package:soulstate/features/todos/state/todos_controller.dart';
import 'package:soulstate/features/todos/widgets/reminder_schedule_sheet.dart';
import 'package:soulstate/features/todos/widgets/todo_add_menu.dart';
import 'package:soulstate/features/todos/widgets/todo_bulk_edit.dart';
import 'package:soulstate/features/todos/widgets/todo_labels.dart';
import 'package:soulstate/features/todos/widgets/todo_select_bar.dart';
import 'package:soulstate/features/todos/widgets/todo_tile.dart';
import 'package:soulstate/features/todos/widgets/todo_trash.dart';
import 'package:soulstate/features/todos/widgets/todos_page_parts.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  bool _showCompleted = false;
  bool _searching = false;
  String _query = '';
  String? _tagFilter;
  final _completing = <String>{};
  final _cards = <String, GlobalKey>{};
  final _trashing = <String>{};
  final _selected = <String>{};
  final _scrolled = ValueNotifier(false);
  final _fab = GlobalKey();

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _query = '';
    });
  }

  bool _matches(Todo todo) {
    if (_query.isNotEmpty && !todo.searchText.contains(_query)) {
      return false;
    }
    return switch (_tagFilter) {
      null => true,
      '' => todo.tags.isEmpty,
      final id => todo.tags.contains(id),
    };
  }

  @override
  void initState() {
    super.initState();
    BackHandlers.add(_backOut);
  }

  @override
  void dispose() {
    BackHandlers.remove(_backOut);
    _scrolled.dispose();
    super.dispose();
  }

  bool get _holdsBack => _selected.isNotEmpty || _searching;

  bool _backOut() {
    if (!_holdsBack || !BackHandlers.isVisible(context)) return false;
    if (_selected.isNotEmpty) {
      setState(_selected.clear);
    } else {
      _toggleSearch();
    }
    return true;
  }

  Future<void> _toggle(Todo todo) async {
    final todos = context.read<TodosController>();
    if (todo.done) return todos.toggle(todo.id);
    if (!_completing.add(todo.id)) return;
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    await todos.toggle(todo.id);
    if (mounted) setState(() => _completing.remove(todo.id));
  }

  Rect? _rectOf(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  bool get _filtering => _query.isNotEmpty || _tagFilter != null;

  GlobalKey _card(String id) => _cards.putIfAbsent(id, GlobalKey.new);

  bool _hidden(String id) => _trashing.contains(id);

  Widget _held(Todo todo, {required Widget child}) => HoldMenu(
        preview: (context, lifted) => _preview(todo.id),
        actions: [
          HoldMenuAction(
            icon: LucideIcons.pencil,
            label: context.l10n.edit,
            onSelected: () => _open(todo),
          ),
          HoldMenuAction(
            icon: todo.pinned ? LucideIcons.pinOff : LucideIcons.pin,
            label: todo.pinned ? context.l10n.todo_unpin : context.l10n.todo_pin,
            onSelected: () => _pin([todo]),
          ),
          HoldMenuAction(
            icon: todo.done ? LucideIcons.undo2 : LucideIcons.checkCheck,
            label: todo.done
                ? context.l10n.todo_mark_open
                : context.l10n.todo_mark_done,
            onSelected: () => _toggle(todo),
          ),
          HoldMenuAction(
            icon: LucideIcons.squareCheck,
            label: context.l10n.todo_select,
            onSelected: () => setState(() => _selected.add(todo.id)),
          ),
          HoldMenuAction(
            icon: LucideIcons.trash2,
            label: context.l10n.delete,
            danger: true,
            onSelected: () => _trash([todo]),
          ),
        ],
        child: RepaintBoundary(
          child: TodoSelectable(
            selecting: _selected.isNotEmpty,
            selected: _selected.contains(todo.id),
            radius: 18,
            child: child,
          ),
        ),
      );

  void _tap(Todo todo) {
    if (_selected.isEmpty) {
      _open(todo);
      return;
    }
    setState(() {
      if (!_selected.remove(todo.id)) _selected.add(todo.id);
    });
  }

  List<Todo> get _picked {
    final todos = context.read<TodosController>().all;
    return [for (final todo in todos) if (_selected.contains(todo.id)) todo];
  }

  Future<void> _pin(List<Todo> todos) async {
    final controller = context.read<TodosController>();
    final pin = !todos.every((todo) => todo.pinned);
    setState(_selected.clear);
    for (final todo in todos) {
      await controller.update(todo.copyWith(pinned: pin));
    }
  }

  Future<void> _finish(List<Todo> todos) async {
    final controller = context.read<TodosController>();
    setState(_selected.clear);
    for (final todo in todos.where((todo) => !todo.done)) {
      await controller.toggle(todo.id);
    }
  }

  void _toggleCompleted() {
    setState(() => _showCompleted = !_showCompleted);
  }

  Future<void> _trash(List<Todo> todos) async {
    final cards = <TrashCard>[
      for (final todo in todos)
        if (_rectOf(_card(todo.id).currentContext) case final rect?)
          (from: rect, card: _preview(todo.id)),
    ];
    final ids = {for (final todo in todos) todo.id};
    setState(_selected.clear);
    if (cards.isEmpty) return discardTodos(context, todos);
    setState(() => _trashing.addAll(ids));
    await throwInTrash(
      context,
      cards: cards,
      onThrown: () {
        if (mounted) discardTodos(context, todos);
      },
    );
    if (mounted) setState(() => _trashing.removeAll(ids));
  }

  Widget _tile(Todo todo, int index, int length, {bool overdue = false}) {
    final corners = todoCorners(false, index, length);
    return TodoSwipeable(
      todo: todo,
      corners: corners,
      onDelete: () => _delete(todo),
      child: Opacity(
        opacity: _hidden(todo.id) ? 0 : 1,
        child: Builder(
          key: _card(todo.id),
          builder: (_) => _held(
            todo,
            child: TodoTile(
              todo: todo,
              overdue: overdue,
              corners: corners,
              showProject: true,
              checking: _completing.contains(todo.id),
              onToggle: () => _toggle(todo),
              onEdit: () => _tap(todo),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(
    TodosController todos,
    List<TodoSection> sections,
    List<Todo> completed,
  ) {
    final showDone = _showCompleted || _query.isNotEmpty;
    final rows = <({Key? key, Widget Function() build})>[
      for (final section in sections) ...[
        (
          key: null,
          build: () => TodoSectionHeader(
                label: todoGroupLabel(context, section.group),
                count: section.todos.length,
                danger: section.group == TodoGroup.overdue,
              ),
        ),
        for (final (index, todo) in section.todos.indexed)
          (
            key: ValueKey(todo.id),
            build: () => _tile(
                  todo,
                  index,
                  section.todos.length,
                  overdue: section.group == TodoGroup.overdue,
                ),
          ),
        (key: null, build: () => const SizedBox(height: 10)),
      ],
      if (completed.isNotEmpty)
        (
          key: null,
          build: () => TodoCompletedHeader(
                count: completed.length,
                expanded: showDone,
                onTap: _toggleCompleted,
              ),
        ),
      if (showDone)
        for (final (index, todo) in completed.indexed)
          (
            key: ValueKey('done-${todo.id}'),
            build: () => _tile(todo, index, completed.length),
          ),
    ];
    final places = <Key, int>{
      for (final (index, row) in rows.indexed)
        if (row.key case final key?) key: index,
    };

    return ListView.builder(
      key: const ValueKey('list'),
      padding: context.pagePadding(16, 8, 16, 148),
      itemCount: rows.length,
      findChildIndexCallback: (key) => places[key],
      itemBuilder: (context, index) => rows[index].build(),
    );
  }

  List<TodoSection> _visibleSections(List<TodoSection> sections) {
    if (!_filtering) return sections;
    final result = <TodoSection>[];
    for (final section in sections) {
      final todos = section.todos.where(_matches).toList();
      if (todos.isNotEmpty) {
        result.add(TodoSection(group: section.group, todos: todos));
      }
    }
    return result;
  }

  Future<void> _open(Todo todo) async {
    if (todo.minutes != null && !todo.done) {
      await showReminderScheduleSheet(context, todo: todo);
      return;
    }
    final deleted = await openTodoEditor(context, todo: todo);
    if (deleted != true || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    final fresh = context.read<TodosController>().byId(todo.id) ?? todo;
    await _trash([fresh]);
  }

  Widget _preview(String id) {
    final todo = context.read<TodosController>().byId(id);
    if (todo == null) return const SizedBox.shrink();
    return TodoTile(todo: todo, overdue: false, onToggle: () {}, onEdit: () {});
  }

  Future<void> _compose() => openTodoEditor(context);

  Future<void> _pickOrder(TodosController todos) => showOptionSheet(
        context,
        title: context.l10n.todo_sort,
        options: [
          context.l10n.todo_sort_high_first,
          context.l10n.todo_sort_low_first,
        ],
        index: todos.lowFirst ? 1 : 0,
        onSelected: (index) => todos.setLowFirst(index == 1),
      );

  Future<void> _add() async {
    final anchor = _rectOf(_fab.currentContext);
    final picked = anchor != null
        ? await showTodoAddMenu(
            context,
            anchor: anchor,
            options: [
              (icon: LucideIcons.checkSquare, label: context.l10n.todo_new),
              (icon: LucideIcons.alarmClock, label: context.l10n.add_reminder),
            ],
          )
        : null;
    if (!mounted) return;
    if (picked == null && anchor != null) return;
    if (picked == 1) {
      await showReminderScheduleSheet(context);
      return;
    }
    openTodoEditor(context);
  }

  Future<void> _delete(Todo todo) => _trash([todo]);

  Future<void> _clearCompleted(int count) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.todo_clear_completed,
      message: context.l10n.todo_clear_completed_body(count),
      confirmLabel: context.l10n.delete,
      icon: LucideIcons.eraser,
    );
    if (confirmed == true && mounted) {
      await context.read<TodosController>().clearCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodosController>();
    final tags = context.watch<TodoTagsController>();
    const classic = true;
    final labels = tags.labels;
    final all = todos.sections;
    final sections = _visibleSections(all);
    final completed = todos.completed.where(_matches).toList();
    final searchable = all.isNotEmpty || todos.completed.isNotEmpty;

    final pushed = ModalRoute.of(context)?.canPop ?? false;

    return PopScope(
      canPop: !pushed || Platform.isIOS,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !pushed || BackHandlers.handle()) return;
        AppNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.todos),
          actions: [
            _HeaderAction(
              glass: classic,
              tooltip: context.l10n.settings,
              icon: const Icon(LucideIcons.settings, size: 20),
              onTap: () => AppNavigator.push(const SettingsPage()),
            ),
            if (searchable)
              _HeaderAction(
                glass: classic,
                tooltip: context.l10n.todo_sort,
                icon: const Icon(LucideIcons.arrowDownUp, size: 20),
                onTap: () => _pickOrder(todos),
              ),
            if (searchable)
              _HeaderAction(
                glass: classic,
                tooltip: context.l10n.todo_search,
                icon: Icon(
                  _searching ? LucideIcons.x : LucideIcons.search,
                  size: 20,
                ),
                onTap: _toggleSearch,
              ),
            if (completed.isNotEmpty && !_searching)
              _HeaderAction(
                glass: classic,
                tooltip: context.l10n.todo_clear_completed,
                icon: const Icon(LucideIcons.eraser, size: 20),
                onTap: () => _clearCompleted(completed.length),
              ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: _selected.isEmpty
            ? FloatingActionButton(
                key: _fab,
                onPressed: _add,
                child: const Icon(LucideIcons.plus),
              )
            : null,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Stack(
              children: [
                Column(
                  children: [
                    if (_searching)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: AppTextField(
                          hint: context.l10n.todo_search,
                          autofocus: true,
                          onChanged: (value) => setState(
                            () => _query = value.trim().toLowerCase(),
                          ),
                        ),
                      ),
                    if (labels.isNotEmpty)
                      TodoTagBar(
                        tags: labels,
                        selected: _tagFilter,
                        untagged: todos.untaggedCount(),
                        project: null,
                        onSelected: (id) => setState(() => _tagFilter = id),
                        projects: const [],
                        onProject: null,
                      ),
                    Expanded(
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification: (note) {
                          if (note.depth == 0 &&
                              note.metrics.axis == Axis.vertical) {
                            _scrolled.value = note.metrics.pixels > 2;
                          }
                          return false;
                        },
                        child: Stack(
                          children: [
                            sections.isEmpty && completed.isEmpty
                                ? (!_filtering
                                    ? TodoEmptyState(onAdd: _compose)
                                    : AppEmptyState(
                                        icon: _query.isEmpty
                                            ? LucideIcons.tag
                                            : LucideIcons.search,
                                        title: context.l10n.todo_search_empty,
                                      ))
                                : _list(todos, sections, completed),
                            if (classic)
                              HeaderBlur(scrolled: _scrolled, height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 78 + context.bottomInset,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.6),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _selected.isEmpty
                          ? const SizedBox.shrink()
                          : TodoSelectBar(
                              count: _selected.length,
                              pinned: _picked.every((todo) => todo.pinned),
                              onClose: () => setState(_selected.clear),
                              onPin: () => _pin(_picked),
                              onEdit: () => editTodos(context, _selected.toList()),
                              onDone: () => _finish(_picked),
                              onDelete: () => _trash(_picked),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.glass,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final bool glass;
  final String tooltip;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    if (!glass) {
      return IconButton(tooltip: tooltip, icon: icon, onPressed: onTap);
    }
    final glyph = icon is Icon ? icon.icon : null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GlassIconButton(
        icon: glyph ?? LucideIcons.circle,
        tooltip: tooltip,
        size: 38,
        onTap: onTap,
      ),
    );
  }
}
