import 'package:flutter/material.dart';
import '../../logic/home_page_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageLogic _folderLogic = HomePageLogic();

  @override
  void dispose() {
    _folderLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "VAULT",
          style: TextStyle(
            color: Color(0xFF33B996),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _folderLogic,
        builder: (context, child) {
          if (_folderLogic.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF33B996)),
            );
          }

          if (_folderLogic.folderPath != null) {
            return _buildActiveFolder();
          } else {
            return _buildNoFolder();
          }
        },
      ),
    );
  }

  Widget _buildNoFolder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 80,
            color: Colors.teal.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Active Vault",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Select a folder on your device to serve as your digital archive. Your notes will be stored safely here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF33B996), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.folder_open),
            label: const Text(
              "Select Local Folder",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFolder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF33B996),
            size: 60,
          ),
          const SizedBox(height: 20),
          const Text(
            "Folder Connected!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _folderLogic.folderPath!,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _folderLogic.disconnectFolder,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              "Disconnect Folder",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
