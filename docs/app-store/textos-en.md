# App Store page — English

Paste these into App Store Connect (App Information and the version page). Limits in brackets.

**Name** [30]
Quadra – Window Grid

**Subtitle** [30]
Arrange windows on a grid

**Promotional text** [170]
Drag across a grid and the window moves to that area. Layouts and workspaces with their own shortcuts, multiple displays and ultrawide screens.

**Keywords** [100, comma-separated, no spaces after commas]
window,manager,tiling,snap,resize,layout,grid,ultrawide,displays,split,screen,organize,workspace

**Description** [4000]

Quadra arranges your windows on a grid. Press a shortcut or click the icon in the menu bar, drag across the grid, and the window moves to exactly that area of the screen.

DRAG ON A GRID
• Pick any area with 1 to 20 columns and rows.
• A see-through panel opens in the middle of the screen, with a preview of where the window will land.
• Click another window while the grid is open to move that one instead.

LAYOUTS WITH THEIR OWN SHORTCUTS
• Save the areas you use most, like "left half" or "center", and apply them with one keystroke.
• Six ready-made layouts: halves (Control-Option-arrows), full screen and center.

WORKSPACES
• Save where the windows of several apps are, and put them all back with one shortcut.
• Closed apps are opened for you, and each app's window goes back to its place.

MULTIPLE DISPLAYS AND ULTRAWIDE
• Choose the display in the panel, or send a window to the next display with a shortcut.
• Made for ultrawide monitors, and works with portrait and laptop displays too.

YOUR WAY
• Adjustable gaps between windows, grid shape, size and opacity.
• Opens at login, lives in the menu bar.
• In English and Brazilian Portuguese.

HOW IT MOVES WINDOWS
macOS doesn't let App Store apps move other apps' windows directly, so Quadra does it through Apple's Shortcuts app. The first time, add the Quadra shortcut with one click and allow Quadra to use Shortcuts. The welcome window walks you through it.

PRIVATE
Quadra collects no data and makes no network requests. It reads where windows are from the macOS window list, and sends only the position and size of the window to move to the Quadra shortcut, which runs on your Mac. Layouts and workspaces are saved on your Mac.

Quadra is free and open source, made by Vulpini.

**Support URL**
https://github.com/vulpini-br/quadra/issues

**Marketing URL**
https://github.com/vulpini-br/quadra

**Privacy policy URL**
https://github.com/vulpini-br/quadra/blob/main/PRIVACY.md

**Category**
Productivity

**Copyright**
2026 Vulpini Contabilidade Ltda

**App Privacy** (in App Store Connect)
Data Not Collected

**Notes for App Review**

Quadra is a menu bar app that moves and resizes the focused window to an area chosen on a grid, and can save and restore the windows of several apps at once (workspaces).

Sandboxed apps can't use the Accessibility API on other apps, so Quadra moves windows through Apple's Shortcuts app. The app bundle includes a shortcut named "Quadra" (Contents/Resources/Quadra.shortcut) made only of the built-in Find Windows, Resize Window and Move Window actions. Quadra runs it in the background through Shortcuts Events, using the com.apple.security.scripting-targets entitlement for the com.apple.shortcuts.run access group, and passes only the app name and the target position and size. Window positions are read with CGWindowListCopyWindowInfo (no titles or contents). Quadra makes no network requests.

How to test:
1. Launch Quadra. In the welcome window click "Add Shortcut", then "Add Shortcut" again in the Shortcuts app.
2. Back in Quadra, click "Allow Quadra", then "OK" when macOS asks to let Quadra control "Shortcuts Events". The welcome window then says "Quadra is ready".
3. Open TextEdit with a document window and keep it in front.
4. Press Control-Option-Left Arrow: the TextEdit window moves to the left half. Control-Option-Right Arrow: right half. Control-Option-C: center.
5. Press Control-Option-G, or click the grid icon in the menu bar. A grid panel appears. Drag across some cells: the window moves to that area.
6. Right-click the menu bar icon and choose "Save Current Windows as Workspace…". Move the TextEdit window, then choose the workspace in the same menu: the window goes back.
7. Right-click the menu bar icon for Settings & Layouts, where layouts, workspaces and shortcuts can be edited.

No account or login is needed.
