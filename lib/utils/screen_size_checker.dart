import 'package:flutter/widgets.dart';

class ScreenSizeChecker {
  static const double _phoneBreakpoint = 600.0;
  static const double _tabletBreakpoint = 802.0;
  static const double _desktopBreakpoint = 1300.0;

  static bool isLandscapePhone(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < _desktopBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= _tabletBreakpoint && screenWidth < _desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= _desktopBreakpoint;
  }

  static bool isPhone(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth <= _phoneBreakpoint;
  }

  static bool isTabletLandscape(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isLandscape = screenWidth > screenHeight;
    print('anhtu ${isTablet(context)} ${screenWidth}x${screenHeight}');

    return isTablet(context) && isLandscape;
  }
}
