import 'package:flutter/material.dart';
import '../widgets/right_sidebar.dart';
import '../widgets/left_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            const Expanded(flex: 2, child: LeftSidebar()),
            // A subtle dark green divider
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color.fromARGB(255, 66, 66, 66),
            ),
            const Expanded(flex: 6, child: RightSidebar()),
          ],
        ),
      ),
    );
  }
}
