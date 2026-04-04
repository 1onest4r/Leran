import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/isar_service.dart';

class HomePageLogic extends ChangeNotifier {
  String? folderPath;
  bool isLoading = true;

  final IsarService dbService = IsarService();

  //when class is created automatically check for saved folder
  HomePageLogic() {
    loadSavedFolder();
  }

  //if the user had already picked folder in the past
  Future<void> loadSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    folderPath = prefs.getString('folder_path');

    //ensure the db is fully open before we let the ui load
    await dbService.db;

    isLoading = false;

    //tells ui to rebuild, col
    notifyListeners();
  }

  //picking the folder for use
  Future<void> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select your desired folder",
    );

    if (selectedDirectory != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('folder_path', selectedDirectory);
      folderPath = selectedDirectory;
      //tells the ui th folder is picked
      notifyListeners();
    }
  }

  //diconnect the active folder
  Future<void> disconnectFolder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('folder_path');
    folderPath = null;
    notifyListeners();
  }
}
