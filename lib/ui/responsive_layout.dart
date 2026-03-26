import 'package:flutter/material.dart';
import 'desktop/desktop_home_page.dart';
import 'mobile/mobile_home_page.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Typically mobile constraints max width is less than 600px.
        if (constraints.maxWidth < 600) {
          return MobileHomePage();
        } else {
          // Fall back to your desktop workspace
          return DesktopHomePage();
        }
      },
    );
  }
}
