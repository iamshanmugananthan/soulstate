import 'dart:ui';

const shippedLanguages = {'en'};

List<Locale> get shippedLocales => const [Locale('en')];

Locale pickLocale(Iterable<Locale>? wanted) => const Locale('en');
