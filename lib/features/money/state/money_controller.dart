import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/dashboard_widget_service.dart';
import 'package:soulstate/services/money_widget_service.dart';
import 'package:uuid/uuid.dart';

class MoneyController extends ChangeNotifier {
  MoneyController() {
    _load();
  }

  static const _uuid = Uuid();

  List<MoneyTransaction> _all = [];
  List<MoneyCategory> _categories = [];
  Map<String, MoneyCategory> _byId = {};
  Map<String, int> _usage = {};

  List<MoneyTransaction> get transactions => List.unmodifiable(_all);

  List<MoneyCategory> get categories => List.unmodifiable(_categories);

  bool get isEmpty => _all.isEmpty;

  void reload() {
    _load();
    notifyListeners();
  }

  void _load() {
    var cats = LocalStore.readMoneyCategories();
    if (cats.isEmpty) {
      cats = MoneyDefaults.seeds();
      // Quiet: defaults are not "edits", so they must never win a sync
      // against a category another device deleted on purpose.
      unawaited(
        LocalStore.quietly(() => LocalStore.writeMoneyCategories(cats)),
      );
    }
    _categories = cats..sort(_byOrder);
    _all = LocalStore.readMoneyTransactions()..sort(_newestFirst);
    _index();
    unawaited(MoneyWidgetService.sync(_all));
    unawaited(DashboardWidgetService.sync());
  }

  static int _byOrder(MoneyCategory a, MoneyCategory b) {
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
  }

  static int _newestFirst(MoneyTransaction a, MoneyTransaction b) {
    final byTime = b.at.compareTo(a.at);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }

  void _index() {
    _byId = {for (final c in _categories) c.id: c};
    _usage = {};
    for (final tx in _all) {
      _usage[tx.categoryId] = (_usage[tx.categoryId] ?? 0) + 1;
    }
  }

  /// Category and transaction lookup queries.

  MoneyCategory? category(String id) => _byId[id];

  MoneyCategory? categoryOf(MoneyTransaction tx) => _byId[tx.categoryId];

  /// The name to show for a transaction, even if its category was deleted.
  String nameOf(MoneyTransaction tx, String fallback) {
    final live = _byId[tx.categoryId]?.name;
    if (live != null && live.isNotEmpty) return live;
    return tx.label.isNotEmpty ? tx.label : fallback;
  }

  int usageOf(String categoryId) => _usage[categoryId] ?? 0;

  /// Number of transactions that would lose their category if [id] (and any
  /// sub-categories) were deleted.
  int usageWithChildren(String id) {
    var total = usageOf(id);
    for (final child in childrenOf(id)) {
      total += usageOf(child.id);
    }
    return total;
  }

  List<MoneyCategory> groups(MoneyKind kind) => [
    for (final c in _categories)
      if (c.kind == kind && c.isGroup) c,
  ];

  List<MoneyCategory> childrenOf(String groupId) => [
    for (final c in _categories)
      if (c.parentId == groupId) c,
  ];

  /// Most-used categories first, padded with top-level ones in their order.
  List<MoneyCategory> frequent(MoneyKind kind, {int limit = 7}) {
    final pool = [
      for (final c in _categories)
        if (c.kind == kind) c,
    ];
    final used =
        [
          for (final c in pool)
            if (usageOf(c.id) > 0) c,
        ]..sort((a, b) {
          final byUse = usageOf(b.id).compareTo(usageOf(a.id));
          return byUse != 0 ? byUse : _byOrder(a, b);
        });
    final rest = [
      for (final c in pool)
        if (usageOf(c.id) == 0 && c.isGroup) c,
    ];
    return [...used, ...rest].take(limit).toList();
  }

  List<MoneyTransaction> inRange(MoneyRange range) =>
      MoneyStats.within(_all, range);

  List<MoneyTransaction> forCategory(String categoryId) => [
    for (final tx in _all)
      if (tx.categoryId == categoryId) tx,
  ];

  /// Transaction recording, editing, and deletion.

  Future<MoneyTransaction> addTransaction({
    required MoneyKind kind,
    required double amount,
    required String categoryId,
    required DateTime at,
    String note = '',
  }) async {
    final tx = MoneyTransaction(
      id: _uuid.v4(),
      kind: kind,
      amount: amount,
      categoryId: categoryId,
      at: at,
      note: note.trim(),
      label: _byId[categoryId]?.name ?? '',
    );
    await saveTransaction(tx);
    return tx;
  }

  /// Inserts or replaces a transaction. Also used to undo a delete.
  Future<void> saveTransaction(MoneyTransaction tx) async {
    final label = _byId[tx.categoryId]?.name ?? tx.label;
    final saved = label == tx.label ? tx : tx.copyWith(label: label);
    _all = [
      for (final other in _all)
        if (other.id != saved.id) other,
      saved,
    ]..sort(_newestFirst);
    _index();
    notifyListeners();
    await LocalStore.writeMoneyTransaction(saved);
    await VaultManager.syncCurrentVault();
    unawaited(MoneyWidgetService.sync(_all));
    unawaited(DashboardWidgetService.sync());
  }

  Future<void> deleteTransaction(String id) async {
    _all = [
      for (final tx in _all)
        if (tx.id != id) tx,
    ];
    _index();
    notifyListeners();
    await LocalStore.removeMoneyTransactions([id]);
    await VaultManager.syncCurrentVault();
    unawaited(MoneyWidgetService.sync(_all));
    unawaited(DashboardWidgetService.sync());
  }

  Future<void> deleteAllTransactions() async {
    _all = [];
    _index();
    notifyListeners();
    await LocalStore.clearMoneyTransactions();
    await VaultManager.syncCurrentVault();
    unawaited(MoneyWidgetService.sync(_all));
    unawaited(DashboardWidgetService.sync());
  }

  /// Category management and customization.

  Future<MoneyCategory> createCategory({
    required String name,
    required MoneyKind kind,
    required Color color,
    required String icon,
    String parentId = '',
  }) async {
    final siblings = _categories.where(
      (c) => c.kind == kind && c.parentId == parentId,
    );
    final next =
        siblings.fold<int>(-1, (top, c) => c.order > top ? c.order : top) + 1;
    final category = MoneyCategory(
      id: _uuid.v4(),
      name: name.trim(),
      kind: kind,
      color: color,
      parentId: parentId,
      icon: icon,
      order: next,
    );
    _categories = [..._categories, category]..sort(_byOrder);
    _index();
    notifyListeners();
    await LocalStore.writeMoneyCategory(category);
    await VaultManager.syncCurrentVault();
    return category;
  }

  Future<void> updateCategory(MoneyCategory category) async {
    final before = _byId[category.id];
    if (before == null) return;
    _categories = [
      for (final c in _categories)
        if (c.id == category.id) category else c,
    ]..sort(_byOrder);
    _index();
    notifyListeners();
    await LocalStore.writeMoneyCategory(category);
    if (before.name != category.name) {
      await _relabel({category.id: category.name});
    }
    await VaultManager.syncCurrentVault();
  }

  /// Deletes a category and its sub-categories. Their transactions are kept
  /// and keep showing the name the category had.
  Future<void> deleteCategory(String id) async {
    final gone = <String>{id, for (final c in childrenOf(id)) c.id};
    final names = {
      for (final categoryId in gone)
        if (_byId[categoryId] case final c?) categoryId: c.name,
    };
    await _relabel(names);
    _categories = [
      for (final c in _categories)
        if (!gone.contains(c.id)) c,
    ];
    _index();
    notifyListeners();
    await LocalStore.removeMoneyCategories(gone);
    await VaultManager.syncCurrentVault();
  }

  /// Replaces every category with the built-in defaults. Transactions are kept.
  Future<void> resetCategories() async {
    final seeds = MoneyDefaults.seeds();
    final keep = {for (final c in seeds) c.id};
    final lost = [
      for (final c in _categories)
        if (!keep.contains(c.id)) c,
    ];
    await _relabel({for (final c in lost) c.id: c.name});
    _categories = seeds..sort(_byOrder);
    _index();
    notifyListeners();
    await LocalStore.removeMoneyCategories(lost.map((c) => c.id));
    await LocalStore.writeMoneyCategories(seeds);
    await VaultManager.syncCurrentVault();
  }

  Future<void> _relabel(Map<String, String> names) async {
    if (names.isEmpty) return;
    final changed = <MoneyTransaction>[];
    final next = <MoneyTransaction>[];
    for (final tx in _all) {
      final name = names[tx.categoryId];
      if (name != null && name.isNotEmpty && name != tx.label) {
        final updated = tx.copyWith(label: name);
        changed.add(updated);
        next.add(updated);
      } else {
        next.add(tx);
      }
    }
    if (changed.isEmpty) return;
    _all = next;
    notifyListeners();
    for (final tx in changed) {
      await LocalStore.writeMoneyTransaction(tx);
    }
  }
}
