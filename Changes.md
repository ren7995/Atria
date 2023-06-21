beta6:
- Fixed app library expanded folder view icons having labels
- Added per-page layout
- 3D touch menu is getting a bit crowded, I got to think of something to do abt it (like add reset page layout to the edit view)
- Tap "Edit This Page" to configure for that page only.
- Resetting a value in this menu will make it reset to the global value, not the default. 
- "Reset This Page" to delete the page's custom settings and restore it to global settings
- Different pages CAN have different rows, columns, icon scale, offsets/insets, everything! Go crazy!
- https://streamable.com/ieptx5

Known quirks:
- You can add icons to pages infinitely, despite the amount of rows/columns

beta7:
- Icon scaling now properly animates when resetting (0.2 second animation)
- Fixed iOS 14.6 support (Apple renamed a method :/)
- Added support for custom font files (put it at /Library/PreferenceBundles/AtriaPrefs.bundle/Custom.ttf)

beta8:
- Capped the width of the view for iPads
- Added hide icon badges option
- Completely redesigned setting selection system thanks to Alpha_Stream:
    - Tap current setting label to select new option
    - Long press and release the setting label to toggle per-page editing (edits the page you are currently on. This will switch with you as you move pages)
    - Icons will come later
- Fixed issues where some but not all App Library labels would hide inside expanded folders
- Renamed the "Hide Icon Labels" to "Hide Homescreen Icon Labels" to make it more obvious that switch is intended to hide labels on the homescreen only
- Added option to hide 3D Touch menu actions

beta9:
- Added import/export settings strings to instantly share configuration with others. Export copies a unique string to clipboard, including everything but your icon state. Import will take a string from your clipboard, and attempt to apply the conifguration from it
- Removed almost all 3D touch menu items
- Long pressing the current settings text now freezes configuration for that list view:
    - Settings will only be adjusted for the current page in this mode (you will see "Page Only (Page#)")
    - Long pressing again will exit per-page mode for that page, and it will be reset to global defaults
    - When opening configuration menu on a page, the label will tell you if the page is in per-page mode

beta10:
- Fixed image color adaptation on the splash screens
- Fixed dock insets not applying for the third or fourth time :/
- Added some icons, not all yet (HUGE thanks to Alpha, I really appreciate it)
- Added hide page dots option
- Added hide folder icon background blur option

beta11:
- Fixed row/column amounts being shown as decimals
- Fixed buggy icon rearrangement (less buggy now)
- Fixed icons being allowed off pages
- The two above bullet points are all thanks to the wonders of NSMapTable
- Fixed welcome label for some users

beta13:
- Added reset save state button in Settings
- Per page layout is now toggleable from an icon on the left hand corner of the view when selecting a setting. This should make it more obvious and user friendly
- Improved internal settings handling for ARIEditingMainView
- Added dynamic background view (should work in landscape and portrait)
    - Customizable alpha
    - Top, Bottom, Left, Right insets
    - configurable per page

beta14:
- Moved splash view controllers to SpringBoard
- Fixed splash view controllers on iPhone SE 1st gen

beta15:
- Added tint color for background blur
- Added tint intensity setting
- Fixed Welcome label glitching out on iPads with today view

Version 1.1.0:
- Initial iOS 13 support
- Fixed background blur showing in iOS page editor
- Fixed folders being dispersed upon respring
- Added Barrel support
- Fixed freeze caused by background blur option when tapping page dots to edit pages
- Fixed "Reset Save State" button in preferences not actually removing the saved icon state
- Fixed visual glitch when opening folder icons from the dock
- The editing view will now display the settings selection view by default to avoid confusion and ease the user experience
- Added a triple tap gesture on homescreen (an additional activation method, can be disabled in settings)
- Added icon spacing option
- Icons inside folders will now also scale

Version 1.1.1:
- Added option to disable icon scaling in folders
- Added option to disable dock
- Fixed icon previews when exiting folders
- Fixed crash when moving icons between pages with per-page layout
- Fixed icon list preview in iOS page edit mode and wallpaper preview

Version 1.2.0:
- Huge changes + performance improvements. It should now be much better on older devices
- Fixed race condition that would occasionally lead to a crash when starting SpringBoard
- Fixed obscure crash that would occur when creating a new page, moving all icons away, and then moving an icon back

Version 1.3.0:
- Added time-based welcome text option
- Added icon drop shadow option to settings
- Support for adding App Library to iPads on iOS 14 (experimental)
- Page dot configuration (x and y positions)
- Added small tooltip-like labels to the editor which give a guide on how to use the tweak (can be disabled in settings)
- Resolved issues with the dock on plus devices when rotating to landscape
- Fixed welcome label frame when adjusting page insets
- Fixed dock icon spacing not working on iOS 13
- Fixed a bug where the slider label would not correctly display values outside of its range
- Fixed a bug that would cause icons inside App Library folders to always be hidden when "Hide Homescreen Icon Labels" was on
- Cleaned up code, improved handling of tweak settings
- Stop using deprecated methods in preferences

Version 1.3.1:
- Fixed an issue that caused settings to appear in the editor view when they shouldn't have
- Fixed issues editing background blur settings
- Corrected issues that broke per-page editing

Version 1.3.2:
- Added Page Dots editing option to the 3D touch menu (a new way of chosing what to edit will hopefully be coming in the future to avoid this clutter)
- Fixed icon shadow option causing lag when editing pages of icons
- Added ShyLabels compatibility

Version 1.3.3:
- iOS 15 is now officially a supported version
- Resolved major issues regarding compatibility with later versions of iOS 15
- Keyboard now correctly displays as a decimal pad when typing in values with the editor
- Fixed an issue that caused the keyboard to remain visible when returning to the previous screen of the settings editor

Version 1.4.0:
- Added full iOS 16 support
- Added official rootless support
- Improvements to iPad support, including proper layout in landscape orientation (please contact me if something isn't working as intended on iPads)
- Added Dynamic Widget Sizing options to preferences, which automatically resizes widgets for an optimal experience
- Added option to show page labels on every page (also configurable per-page)
- Added option to display a drop shadow behind page labels
- Added option to force enable floating dock
- Added dock configuration support for iPads/floating dock
- Added options for enabling/disabling recents and app library icon for iPads/floating dock
- Added option to disable homescreen today view
- Revamped and cleaned up preferences
- Editor visual adjustments
- Floating dock (both on iPads and with the tweak) should now hide when typing values in the editor
- Fixed editor going behind the keyboard when typing values
- Fixed certain preference values not updating and requiring a respring when changed
- Fixed issues that made widgets unable to be placed in certain spots when the number of rows was changed
- Fixed issues that made widgets place incorrectly or be unable to be placed in certain spots horizontally
- Fixed numerous other compatibility issues with widgets
- Fixed an issue that caused page labels to be improperly positioned when reordering pages
- Fixed optimization issues with page labels
- Fixed a crash that would occur when reordering pages
- Fixed a crash due to a compatibility issue with Zenith
- Fixed background blur or page label not appearing when creating a new page
- Improved performance and appearance of icon drop shadow option
- Other unlisted QOL changes

Known issues:
- Coversheet icon fly-in animation may look incorrect
