#!/bin/bash
# Prints the notes for a release: the version's section of CHANGELOG.md plus how to install.
# Usage: Tools/release-notes.sh 1.1.0   (or v1.1.0)
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1#v}"

NOTES="$(awk -v heading="## $VERSION" '$0 == heading { found = 1; next } found && /^## / { exit } found' CHANGELOG.md)"
if [[ -z "${NOTES//[[:space:]]/}" ]]; then
  echo "CHANGELOG.md has no section \"## $VERSION\"" >&2
  exit 1
fi

echo "## What's new"
echo "$NOTES"
cat <<'EOF'

## Install

With Homebrew:

```bash
brew install --cask vulpini-br/tap/quadra
```

Or download **Quadra.zip** below, unzip it, move **Quadra.app** to **Applications** and open it.
Allow **Accessibility** when Quadra asks. Signed and notarized by Apple. Requires macOS 14 or later.

Already have Quadra? It tells you about new versions; with Homebrew, run `brew upgrade --cask quadra`.

---

**Em português:** instale com `brew install --cask vulpini-br/tap/quadra` ou baixe o **Quadra.zip**,
mova o app para **Aplicativos** e abra. Depois permita a **Acessibilidade** quando o Quadra pedir.
Assinado e verificado pela Apple.
EOF
