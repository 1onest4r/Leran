# flutter_demo

this project is for class uses for now.

used external packages:

-path_provider ^2.1.1

-file_picker ^10.3.10

TODO:
fix header being not saved in note taking section
fix the workflow of the current file with UI, LOGIC, SERVICE (for better life)
fix in note taking section the cursor not moving into the blank space
fix text in header not being saved
fix the ui scaling issue in the settings
fix the latency issue when typing little faster

add text styling semantics
add a button for choosing another folder in the current session
add into the settings option for selection a new folder
add a feature where it asks for permission from user

in note taking section add a feature for headers, line breaker and copying stylized text cleanly
pick a proper color for better UX
the app using how much performance? must be addressed after finishing first page

"===================STUFF TO REMEMBER=========================="
-building ui must be faster than 16ms
-remember to use database if loading/saving large stuffs but for small stuffs saving right away is fine
-remember to aslways make distinction between ui, logic and services

"=============================================================="

=================================================================
LERAN THE NOTE TAKING APP - ARCHITECTURE & DATA FLOW EXPLANATION
=================================================================

To make this app scalable for complex features like a 3D Graph View,
the code is now strictly separated into three layers:

1. SERVICES (The Hands)
2. LOGIC (The Brain)
3. UI (The Face)

---

1. THE SERVICES LAYER (file_service.dart, settings_service.dart)

---

WHAT IT DOES: Talks to the device hardware (Disk drives, OS memory).
RULES: It knows NOTHING about the UI or the App's state. It only takes
inputs and returns outputs.
EXAMPLE: FileService doesn't know what tabs are open. It just says "Give
me a path and a string, and I will save it to the hard drive."

---

2. THE LOGIC LAYER (vault*controller.dart) -> \_NEW*

---

WHAT IT DOES: This is the central "Brain" (State Manager).
It holds all the active data: What vault is open? What tabs are active?
What text is currently typed but unsaved?
RULES: It contains NO Flutter UI widgets (No Colors, No TextFields).
HOW IT WORKS:

- It acts as a "Singleton" (meaning only one instance of it exists in the app).
- When a user types a letter, the UI tells VaultController to update the text.
- VaultController updates its memory, and then yells "notifyListeners()!"
- Any UI listening to it instantly updates automatically.

---

3. THE UI LAYER (home_page.dart, right_sidebar.dart, etc.)

---

WHAT IT DOES: Displays pixels on the screen and detects mouse clicks.
RULES: UI Widgets are now "Dumb". They do not calculate logic.
HOW IT WORKS:

- LeftSidebar doesn't delete files anymore. It just says:
  "Hey VaultController, the user clicked delete. Do your thing."
- RightSidebar doesn't worry about keeping track of open tabs. It just says:
  "Hey VaultController, give me the list of open tabs so I can draw them."

=========================================================
WHY IS THIS IMPORTANT FOR YOUR 3D GRAPH VIEW?
=========================================================
In the old code, if you built a 3D Graph View, you would have to pass
variables down from HomePage -> GraphView -> Nodes, creating a huge mess.

Now, your 3D Graph widget can simply be dropped anywhere in the app and call:
`final vault = VaultController();`
`List<FileSystemEntity> allFiles = vault.files;`

Boom. You instantly have access to every file in the vault, completely
bypassing the UI tree!
