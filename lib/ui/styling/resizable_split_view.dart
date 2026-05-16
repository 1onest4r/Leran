import 'package:flutter/material.dart';

class ResizableSplitView extends StatefulWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double defaultLeftWidth;

  const ResizableSplitView({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.defaultLeftWidth = 350,
  });

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double _leftWidth;

  @override
  void initState() {
    super.initState();
    _leftWidth = widget.defaultLeftWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // 1. Never let the left menu get smaller than 260px (protects dropdowns)
        double minLeft = 260.0;

        // 2. Always leave at least 250px for the right-side Note Editor
        double maxLeft = maxWidth - 250.0;

        // 3. Safety fallback in case the window gets extremely small
        if (maxLeft < minLeft) maxLeft = minLeft;

        // 4. Safely clamp the user's drag width to these safe zones
        final safeLeftWidth = _leftWidth.clamp(minLeft, maxLeft);

        return Row(
          children: [
            SizedBox(width: safeLeftWidth, child: widget.leftChild),

            // The Draggable Edge
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _leftWidth += details.delta.dx;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(width: 6, color: Colors.white10),
              ),
            ),

            Expanded(child: widget.rightChild),
          ],
        );
      },
    );
  }
}
