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
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color.fromARGB(255, 61, 61, 61),
            ),
            const Expanded(flex: 6, child: RightSidebar()),
          ],
        ),
      ),
    );
  }
}
