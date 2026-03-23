import 'package:flutter/material.dart';
import 'package:flutter_demo/ui/mobile/mobile_search_page.dart';
import '../../services/settings_service.dart';
import 'widgets/mobile_drawer.dart';
import 'widgets/note_card.dart';
import 'mobile_editor_page.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: settings.scaffoldColor,
      drawer: const MobileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER & CONTROLS
            _buildTopControls(settings),

            // TITLE BLOCK
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    "Folders",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: settings.textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "3 notes",
                    style: TextStyle(
                      fontSize: 14,
                      color: settings.dimTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ALIGNMENT / FILTER BAR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.sort, color: settings.dimTextColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Date modified",
                    style: TextStyle(
                      color: settings.dimTextColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(height: 12, width: 1, color: settings.dimTextColor),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward,
                    color: settings.dimTextColor,
                    size: 16,
                  ),
                ],
              ),
            ),

            // NOTES GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return NoteCard(
                    title: index == 0 ? "Shopping List" : "Idea 01",
                    subtitleText:
                        "Note • ${DateTime.now().day}/0${DateTime.now().month}",
                    timeText: "18:52",
                    onTap: () {
                      // Tap a note card to open editor!
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileEditorPage(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // THE NEW FAB STYLED WITH DESKTOP GREEN ACCENT
      floatingActionButton: FloatingActionButton(
        backgroundColor: settings.sidebarColor,
        elevation: 2, // Slight lift
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: settings.dividerColor,
            width: 1,
          ), // Optional matching rim
        ),
        onPressed: () {
          // Add a new note and open editor!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MobileEditorPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: settings.accentColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTopControls(SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer Trigger
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: settings.textColor, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: settings.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // REMOVED 3-DOTS & PDF; kept standard search icon
          IconButton(
            icon: Icon(Icons.search, color: settings.textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
