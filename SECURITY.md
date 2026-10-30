# Security

Quadra uses the macOS Accessibility permission to move other apps' windows. It reads only the
position, size and title of the windows it arranges: the focused window, or the open apps' windows
when you save or restore a workspace. Workspaces are kept in Quadra's settings on your Mac.

Its only network access is a request to GitHub, at most once a day, asking for the latest
release (`api.github.com/repos/vulpini-br/quadra/releases/latest`). Nothing about you or your
Mac is sent. You can turn it off in Settings. Quadra for Windows does the same with the list of
releases (`api.github.com/repos/vulpini-br/quadra/releases`), where it looks for the newest
Windows release, and needs no special permission to move windows.

Releases are signed with an Apple Developer ID (team AE7E7GAZLV) and notarized by Apple, so
macOS opens them without warnings and keeps the Accessibility permission across updates.

If you find a security problem, please report it privately: open the **Security** tab of this
repository and click **Report a vulnerability**. Please don't open a public issue for it.

Fixes go into the latest version only.
