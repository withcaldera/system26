#!/bin/sh

echo "🐶 Running Checks..."

# Clear any stale index lock so formatting can stage changes
rm -f .git/index.lock

# 1. Swift Format (Apple)
echo "✨ Running swift-format..."
# swift-format might be noisy, but we capture exit code.
xcrun swift-format format --in-place --recursive System26 Packages

# Re-stage any files modified by swift-format
git add System26 Packages

# 2. SwiftLint (Realm)
if which swiftlint >/dev/null; then
    # Clear any stale index lock so formatting can stage changes
    rm -f .git/index.lock
    echo "🧹 Running SwiftLint Auto-Correct (quiet)..."
    # Fix paths: remove --path, just pass directories
    swiftlint --quiet --fix System26 Packages

    # Re-stage again in case SwiftLint made changes.
    git add System26 Packages

    # Run linting in strict mode.
    echo "🔍 Verifying with SwiftLint (quiet)..."
    swiftlint --quiet lint --strict System26 Packages
else
    echo "⚠️ SwiftLint not found. Skipping linting."
fi

RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo "✅ Checks passed!"
else
    echo "❌ Checks failed. Fix the errors above or use --no-verify to bypass."
fi

exit $RESULT
