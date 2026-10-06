#!/bin/bash
# Move the Fernhilfe commits onto a new upstream RustDesk release.
#
#   lui/update-upstream.sh 1.5.1
#
# - fetches upstream tags
# - keeps the current state as branch fernhilfe-<old upstream version>
# - rebases the commits between the old upstream tag and fernhilfe onto the new tag
#   (git rerere remembers conflict resolutions from earlier updates)
# - prints the build tool versions upstream now uses, to compare with lui/build/Containerfile
#
# After it: lui/build.sh --image, test (lui/README.md), bump lui/CHANGELOG.md, tag <new>-lui.1.
set -euo pipefail
cd "$(dirname "$0")/.."
NEW=${1:?usage: lui/update-upstream.sh <upstream tag, e.g. 1.5.1>}
BRANCH=fernhilfe

[ -z "$(git status --porcelain --untracked-files=no)" ] || { echo "Working tree not clean." >&2; exit 1; }
git config rerere.enabled true
git config rerere.autoupdate true
git fetch upstream --tags --force
git rev-parse -q --verify "refs/tags/$NEW" >/dev/null || { echo "No upstream tag $NEW." >&2; exit 1; }

OLD=$(git describe --tags --abbrev=0 --match '[0-9]*.[0-9]*.[0-9]*' --exclude '*-lui*' "$BRANCH")
echo "Upstream base: $OLD -> $NEW"
git branch -f "$BRANCH-$OLD" "$BRANCH"
echo "Old state kept as branch $BRANCH-$OLD"

git checkout -q "$BRANCH"
if ! git rebase --onto "$NEW" "$OLD" "$BRANCH"; then
  cat >&2 <<MSG

Conflicts. Resolve them (lui/UPSTREAM.md lists every hook), then:
  git add <files> && git rebase --continue
Abort with: git rebase --abort && git checkout $BRANCH && git reset --hard $BRANCH-$OLD
MSG
  exit 1
fi
git submodule update --init --recursive

echo
echo "Build tool versions upstream uses now (compare with lui/build/Containerfile):"
grep -hE '^\s+(RUST_VERSION|FLUTTER_VERSION|VCPKG_COMMIT_ID|VCPKG_CMAKE_VERSION|FLUTTER_RUST_BRIDGE_VERSION|CARGO_EXPAND_VERSION):' \
  .github/workflows/flutter-build.yml .github/workflows/bridge.yml | sed 's/^ */  /'
grep -n 'flutter-version: "' .github/workflows/bridge.yml | head -1 | sed 's/^/  bridge /'
echo
echo "Done. Next: lui/build.sh --image, test, CHANGELOG, tag $NEW-lui.1"
