import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';

class MoneyCategory {
  const MoneyCategory({
    required this.id,
    required this.name,
    required this.kind,
    required this.color,
    this.parentId = '',
    this.icon = 'tag',
    this.order = 0,
  });

  final String id;
  final String name;
  final MoneyKind kind;
  final Color color;

  /// Empty for top-level categories (every income category, and each expense
  /// group); otherwise the id of the expense group it belongs to.
  final String parentId;
  final String icon;
  final int order;

  bool get isGroup => parentId.isEmpty;

  MoneyCategory copyWith({
    String? name,
    Color? color,
    String? parentId,
    String? icon,
    int? order,
  }) => MoneyCategory(
    id: id,
    name: name ?? this.name,
    kind: kind,
    color: color ?? this.color,
    parentId: parentId ?? this.parentId,
    icon: icon ?? this.icon,
    order: order ?? this.order,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'color': color.toARGB32(),
    'parent': parentId,
    'icon': icon,
    'order': order,
  };

  factory MoneyCategory.fromMap(Map<String, dynamic> map) => MoneyCategory(
    id: map['id'] as String,
    name: (map['name'] ?? '') as String,
    kind: moneyKindFrom(map['kind']),
    color: Color((map['color'] ?? 0xFF8E8E93) as int),
    parentId: (map['parent'] ?? '') as String,
    icon: (map['icon'] ?? 'tag') as String,
    order: ((map['order'] ?? 0) as num).toInt(),
  );
}

class MoneyIcons {
  const MoneyIcons._();

  static const Map<String, IconData> all = {
    'tag': LucideIcons.tag,
    'wallet': LucideIcons.wallet,
    'banknote': LucideIcons.banknote,
    'coins': LucideIcons.coins,
    'piggy': LucideIcons.piggyBank,
    'card': LucideIcons.creditCard,
    'landmark': LucideIcons.landmark,
    'receipt': LucideIcons.receipt,
    'dollar': LucideIcons.circleDollarSign,
    'badge': LucideIcons.badgeDollarSign,
    'euro': LucideIcons.euro,
    'pound': LucideIcons.poundSterling,
    'trend': LucideIcons.trendingUp,
    'vault': LucideIcons.vault,
    'percent': LucideIcons.percent,
    'handshake': LucideIcons.handshake,
    'handcoins': LucideIcons.handCoins,
    'utensils': LucideIcons.utensils,
    'coffee': LucideIcons.coffee,
    'beer': LucideIcons.beer,
    'wine': LucideIcons.wine,
    'soda': LucideIcons.cupSoda,
    'pizza': LucideIcons.pizza,
    'sandwich': LucideIcons.sandwich,
    'salad': LucideIcons.salad,
    'cake': LucideIcons.cake,
    'apple': LucideIcons.apple,
    'milk': LucideIcons.milk,
    'cart': LucideIcons.shoppingCart,
    'bag': LucideIcons.shoppingBag,
    'store': LucideIcons.store,
    'shirt': LucideIcons.shirt,
    'gem': LucideIcons.gem,
    'phone': LucideIcons.smartphone,
    'laptop': LucideIcons.laptop,
    'headphones': LucideIcons.headphones,
    'camera': LucideIcons.camera,
    'car': LucideIcons.car,
    'bike': LucideIcons.bike,
    'plane': LucideIcons.plane,
    'navigation': LucideIcons.navigation,
    'pin': LucideIcons.mapPin,
    'gauge': LucideIcons.gauge,
    'wrench': LucideIcons.wrench,
    'hammer': LucideIcons.hammer,
    'house': LucideIcons.house,
    'sofa': LucideIcons.sofa,
    'bed': LucideIcons.bed,
    'lamp': LucideIcons.lamp,
    'washer': LucideIcons.washingMachine,
    'fridge': LucideIcons.refrigerator,
    'bulb': LucideIcons.lightbulb,
    'wifi': LucideIcons.wifi,
    'call': LucideIcons.phone,
    'drop': LucideIcons.droplet,
    'zap': LucideIcons.zap,
    'plug': LucideIcons.plug,
    'tv': LucideIcons.tv,
    'heartpulse': LucideIcons.heartPulse,
    'stethoscope': LucideIcons.stethoscope,
    'pill': LucideIcons.pill,
    'dumbbell': LucideIcons.dumbbell,
    'shield': LucideIcons.shieldCheck,
    'activity': LucideIcons.activity,
    'game': LucideIcons.gamepad2,
    'film': LucideIcons.film,
    'music': LucideIcons.music,
    'popcorn': LucideIcons.popcorn,
    'drama': LucideIcons.drama,
    'ticket': LucideIcons.ticket,
    'palette': LucideIcons.palette,
    'book': LucideIcons.book,
    'party': LucideIcons.partyPopper,
    'graduation': LucideIcons.graduationCap,
    'school': LucideIcons.school,
    'briefcase': LucideIcons.briefcase,
    'target': LucideIcons.target,
    'brain': LucideIcons.brain,
    'baby': LucideIcons.baby,
    'toy': LucideIcons.toyBrick,
    'backpack': LucideIcons.backpack,
    'users': LucideIcons.users,
    'gift': LucideIcons.gift,
    'heart': LucideIcons.heart,
    'handheart': LucideIcons.handHeart,
    'flower': LucideIcons.flower,
    'dog': LucideIcons.dog,
    'cat': LucideIcons.cat,
    'bone': LucideIcons.bone,
    'leaf': LucideIcons.leaf,
    'star': LucideIcons.star,
    'flame': LucideIcons.flame,
    'sparkles': LucideIcons.sparkles,
    'globe': LucideIcons.globe,
    'more': LucideIcons.ellipsis,
  };

  static List<String> get names => all.keys.toList();

  static IconData resolve(String name) => all[name] ?? LucideIcons.tag;
}

class MoneyPalette {
  const MoneyPalette._();

  static const Color fallback = Color(0xFF8E8E93);

  static const List<Color> colors = [
    Color(0xFFFF9500),
    Color(0xFF5AC8FA),
    Color(0xFF7C5CFC),
    Color(0xFFFF2D95),
    Color(0xFFFF3B30),
    Color(0xFF34C759),
    Color(0xFFFFCC00),
    Color(0xFF00C8A0),
    Color(0xFFE91E63),
    Color(0xFF3B82F6),
    Color(0xFF8E8E93),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF64748B),
  ];
}

/// The categories a fresh install starts with. Ids are fixed so that two
/// devices that both seed these end up with the same records when they sync.
class MoneyDefaults {
  const MoneyDefaults._();

  static List<MoneyCategory> seeds() {
    final out = <MoneyCategory>[];
    var order = 0;

    void group(
      String id,
      String name,
      String icon,
      Color color,
      List<(String, String, String)> children,
    ) {
      out.add(
        MoneyCategory(
          id: 'exp_$id',
          name: name,
          kind: MoneyKind.expense,
          color: color,
          icon: icon,
          order: order++,
        ),
      );
      for (final (index, child) in children.indexed) {
        out.add(
          MoneyCategory(
            id: 'exp_${id}_${child.$1}',
            name: child.$2,
            kind: MoneyKind.expense,
            color: color,
            parentId: 'exp_$id',
            icon: child.$3,
            order: index,
          ),
        );
      }
    }

    group('food', 'Food & Beverages', 'utensils', const Color(0xFFFF9500), [
      ('food', 'Food', 'pizza'),
      ('drinks', 'Beverages', 'soda'),
      ('daily', 'Daily Necessities', 'cart'),
    ]);
    group('transport', 'Transport', 'car', const Color(0xFF5AC8FA), [
      ('fuel', 'Fuel', 'gauge'),
      ('parking', 'Parking', 'pin'),
      ('service', 'Services & Maintenance', 'wrench'),
      ('taxi', 'Taxi', 'navigation'),
    ]);
    group('growth', 'Personal Development', 'brain', const Color(0xFF7C5CFC), [
      ('business', 'Business', 'briefcase'),
      ('education', 'Education', 'graduation'),
      ('invest', 'Investment', 'trend'),
    ]);
    group('shopping', 'Shopping', 'bag', const Color(0xFFFF2D95), [
      ('clothes', 'Clothes', 'shirt'),
      ('accessories', 'Accessories', 'gem'),
      ('devices', 'Electronic Devices', 'phone'),
    ]);
    group('fun', 'Entertainment', 'popcorn', const Color(0xFFFF3B30), [
      ('movies', 'Movies', 'film'),
      ('games', 'Games', 'game'),
      ('music', 'Music', 'music'),
      ('travel', 'Travel', 'plane'),
    ]);
    group('home', 'Home', 'house', const Color(0xFF34C759), [
      ('pets', 'Pets', 'dog'),
      ('furniture', 'Furnishings', 'sofa'),
      ('repairs', 'Home Services', 'hammer'),
      ('rent', 'Mortgage & Rent', 'landmark'),
    ]);
    group('bills', 'Utility Bills', 'receipt', const Color(0xFFFFCC00), [
      ('power', 'Electricity', 'bulb'),
      ('internet', 'Internet', 'wifi'),
      ('mobile', 'Mobile Phone', 'call'),
      ('water', 'Water', 'drop'),
    ]);
    group('health', 'Health', 'heartpulse', const Color(0xFF00C8A0), [
      ('sports', 'Sports', 'dumbbell'),
      ('insurance', 'Health Insurance', 'shield'),
      ('doctor', 'Doctor', 'stethoscope'),
      ('medicine', 'Medicine', 'pill'),
    ]);
    group('gifts', 'Gifts & Donations', 'gift', const Color(0xFFE91E63), [
      ('gifts', 'Gifts', 'gift'),
      ('wedding', 'Wedding', 'heart'),
      ('funeral', 'Funeral', 'flower'),
      ('charity', 'Charity', 'handheart'),
    ]);
    group('kids', 'Kids', 'baby', const Color(0xFF3B82F6), [
      ('pocket', 'Pocket Money', 'coins'),
      ('baby', 'Baby Products', 'baby'),
      ('daycare', 'Babysitter & Daycare', 'users'),
      ('tuition', 'Tuition', 'school'),
    ]);
    group('other', 'Other', 'more', const Color(0xFF8E8E93), const []);

    const income = [
      ('salary', 'Salary', 'banknote', Color(0xFF22C55E)),
      ('invest', 'Investment', 'trend', Color(0xFF14B8A6)),
      ('bonus', 'Bonus', 'badge', Color(0xFFF59E0B)),
      ('side', 'Side job', 'laptop', Color(0xFF3B82F6)),
      ('gifts', 'Gifts', 'gift', Color(0xFFE91E63)),
      ('other', 'Other', 'dollar', Color(0xFF8E8E93)),
    ];
    for (final (index, item) in income.indexed) {
      out.add(
        MoneyCategory(
          id: 'inc_${item.$1}',
          name: item.$2,
          kind: MoneyKind.income,
          color: item.$4,
          icon: item.$3,
          order: index,
        ),
      );
    }
    return out;
  }
}
