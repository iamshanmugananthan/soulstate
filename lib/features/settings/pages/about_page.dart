import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:soulstate/app/theme/app_theme.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/widgets/entrance.dart';
import 'package:soulstate/core/widgets/typewriter.dart';
import 'package:url_launcher/url_launcher.dart';

const _kWebsiteUrl = 'https://shanmugananthan.com';
const _kProfileUrl = 'https://github.com/iamshanmugananthan';
const _kCoffeeUrl = 'https://buymeacoffee.com/shanmugananthan';
const _kGitHubUrl = 'https://github.com/iamshanmugananthan/soulstate';
const _base = Duration(milliseconds: 340);

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = 'v${info.version}');
      }
    });
  }

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final muted = context.tokens.muted;

    final nameStyle = TextStyle(
      fontFamily: AppTheme.classicFont,
      fontSize: 44,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -1,
      color: scheme.onSurface,
    );

    final subtitleStyle = TextStyle(
      fontFamily: AppTheme.classicFont,
      fontWeight: FontWeight.w500,
      fontSize: 17,
      height: 1.3,
      color: muted,
    );

    final storyStyle = TextStyle(
      fontSize: 15,
      height: 1.7,
      color: scheme.onSurface.withValues(alpha: 0.85),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.about),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: context.pagePadding(24, 8, 24, 40),
        children: [
          Entrance(
            delay: _base,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.88, end: 1),
                duration: const Duration(milliseconds: 620),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.28),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(
            index: 1,
            delay: _base,
            child: Typewriter(
              text: context.l10n.about_app,
              duration: const Duration(milliseconds: 640),
              delay: const Duration(milliseconds: 120),
              style: nameStyle,
            ),
          ),
          const SizedBox(height: 10),
          Entrance(
            index: 2,
            delay: _base,
            child: Typewriter(
              text: context.l10n.about_tagline,
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 380),
              style: subtitleStyle,
            ),
          ),
          const SizedBox(height: 30),
          Entrance(
            index: 3,
            delay: _base,
            child: Typewriter(
              text: context.l10n.about_story,
              duration: const Duration(milliseconds: 2200),
              delay: const Duration(milliseconds: 1400),
              style: storyStyle,
            ),
          ),
          const SizedBox(height: 32),
          Entrance(
            index: 4,
            delay: _base,
            child: Column(
              children: [
                _BuyMeACoffeeButton(
                  onTap: () => _open(_kCoffeeUrl),
                ),
                const SizedBox(height: 14),
                _LinkButton(
                  icon: LucideIcons.globe,
                  label: 'shanmugananthan.com',
                  onTap: () => _open(_kWebsiteUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Entrance(
            index: 5,
            delay: _base,
            child: Center(
              child: _MadeBy(onTap: () => _open(_kProfileUrl)),
            ),
          ),
          const SizedBox(height: 10),
          Entrance(
            index: 6,
            delay: _base,
            child: Center(
              child: Text(
                _version,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: muted.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Entrance(
            index: 7,
            delay: _base,
            child: GestureDetector(
              onTap: () => _open('$_kGitHubUrl/blob/main/LICENSE'),
              child: Text(
                context.l10n.license_label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: muted.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MadeBy extends StatelessWidget {
  const _MadeBy({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface.withValues(alpha: 0.85),
    );

    return Semantics(
      link: true,
      label: 'Shanmugananthan',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Soul State by '),
                TextSpan(
                  text: 'Shanmugananthan',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ),
    );
  }
}

class _BuyMeACoffeeButton extends StatelessWidget {
  const _BuyMeACoffeeButton({required this.onTap});

  final VoidCallback onTap;

  static const _bmcYellow = Color(0xFFFFDD00);
  static const _bmcBlack = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bmcYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FFDD00),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label: context.l10n.buy_me_a_coffee,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.black12,
            highlightColor: Colors.black.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.coffee,
                    size: 20,
                    color: _bmcBlack,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.buy_me_a_coffee,
                    style: const TextStyle(
                      color: _bmcBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: scheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
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
