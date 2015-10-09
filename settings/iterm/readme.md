iTerm settings
==============

In `Preferences/General`, enable "Load preferences from custom folder" and use

	~/self/settings/iterm

Close Preferences and the application. If at any point the settings are requested to be saved select `No`, otherwise current settings will override the ones in this folder.

When the application is reopened new settings should be in effect.


Changes in the plist file
=========================

The iterm2.plist file usualy ends up with some minor changes after each time the iterm application is closed, as it saves information regarding the app state.

When settings are modified, make sure to close the iterm application. Only at that point settings are saved.
