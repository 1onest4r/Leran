import 'package:flutter/material.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            //left side column(2 parts width)
            const Expanded(flex: 2, child: LeftSidebar()),
            const VerticalDivider(width: 1, thickness: 1),
            const Expanded(flex: 5, child: RightSidebar()),
          ],
        ),
      ),
    );
  }
}
