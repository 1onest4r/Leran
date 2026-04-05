# leran

A new Flutter project.

isar

flutter pub run build_runner build (missing database code generator)

- [ ] add keyboard keys for shortcut hold alt for showing the shortcut keys specifically for desktop version
- [ ] add option for loading some chunks of the whole file for both home page and search
- [ ] split the note logic from folder_logic and integrate tags as ~tag name~ so the name must be between ~~ marks
- [ ] add option for search by title, content, tag (multiple categories can be selected but order is tag, title, content)
- [ ] make the clusters page working with proper clustering logic
- [ ] make the settings page working
  - [ ] make syncing page with folder picker to give user ability to sync partial data
  - [ ] make a cluster disabler working
- [ ] learn about syncthing and integrate into the project
- [ ] make feedback working in the settings page
- [ ] make theme toggle/changer working
- [ ] update the android release to 2.0.0+6, publish on linux and windows

- [ ] enable [[file name]] for linking the files and figure how how to easily index it for graphing

## How Leran the app works

it uses two open-source project (Isar noSQL database and syncthing for p2p data transfer securely)
the app simply serves as a bundle of controller for syncing raw .md data over network to
trusted devices that are verified by "syncthing". Isar dbs's purpose is to index the .md files so that
searching works flawlessly and further integration on using the clustered data as visual representation
would be a cool feature.

App is simply for syncing raw .md file over the network without ever registering to the app nor to anything
so user's whole db could live on one or maybe devices and whenever the user wants to access some notes or data, simply connecting to network would be enough (local first and then shared over network).

## Why is syncthing secure?

it uses TLS (transfer layer security) usually used with HTTP protocol to secure data being sent
since the HTTP communication consists of just plain texts the TLS works perfectly for this app
