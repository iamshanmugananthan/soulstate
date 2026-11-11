import 'package:flutter/widgets.dart';

/// Screen width breakpoints for responsive layouts.
const phoneWidth = 600.0;
const tabletWidth = 840.0;
const desktopWidth = 1100.0;

const railWidth = 640.0;
const railPageWidth = 720.0;
const splitWidth = 880.0;
const wideWidth = 1060.0;
const maxContentWidth = 1200.0;

const paneWidth = 480.0;
const compactPaneWidth = 400.0;
const detailWidth = 900.0;
const columnsWidth = 1000.0;

/// Returns true when the device screen is wide enough for a split/multi-pane layout.
bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= splitWidth;

/// Returns true when the display is wide enough for a navigation rail / sidebar.
bool hasSideRail(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= railWidth;

/// Returns true on tablet and PC widescreen layouts.
bool isTabletOrDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= tabletWidth;

/// Returns true if navigation rail should be in compact icon-only mode.
bool isCompactRail(BuildContext context) =>
    MediaQuery.sizeOf(context).width < wideWidth;

/// Returns true on very narrow phone screens.
bool stackedRows(BuildContext context) =>
    MediaQuery.sizeOf(context).width <
    360 * MediaQuery.textScalerOf(context).scale(1);

/// Returns true on ultra-narrow screens or compact watch displays.
bool bareRows(BuildContext context) =>
    MediaQuery.sizeOf(context).width <
    240 * MediaQuery.textScalerOf(context).scale(1);

/// Responsive layout builder helper.
enum ScreenType { mobile, tablet, desktop }

ScreenType screenTypeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= desktopWidth) return ScreenType.desktop;
  if (width >= phoneWidth) return ScreenType.tablet;
  return ScreenType.mobile;
}
