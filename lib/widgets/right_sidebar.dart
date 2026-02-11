import 'package:flutter/material.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a STACK so we can float the button on top of the content
    return Stack(
      children: [
        // LAYER 1: The Main Content (Column)
        Column(
          children: [
            // --- HEADER (Integrated into note section) ---
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                40,
                60,
                10,
              ), // Right padding 60 to avoid button
              child: const TextField(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none, // Removes the box
                  // This is the "Simple Underscore" you asked for
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                ),
              ),
            ),

            // --- NOTE BODY ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const TextField(
                  maxLines: null, // Allows infinite lines
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Start typing your note here...",
                    border: InputBorder.none, // Clean look without borders
                  ),
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),

            // --- FOOTER (1, 2, 3) ---
            // Keeping this at the bottom as per original design
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _footerButton("1. Format"),
                  _footerButton("2. Tags"),
                  _footerButton("3. Export"),
                ],
              ),
            ),
          ],
        ),

        // LAYER 2: The Floating Hamburger Button
        // We use Positioned to place it exactly where we want
        Positioned(
          top: 30,
          right: 20,
          child: FloatingActionButton.small(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2, // Slight shadow
            onPressed: () {
              // Open options menu logic here
            },
            child: const Icon(Icons.menu),
          ),
        ),
      ],
    );
  }

  // A helper widget to make the footer code cleaner
  Widget _footerButton(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }
}
