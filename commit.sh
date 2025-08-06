# Takes two arguments: the commit message and the commit type
# Commits the changes with the provided message
# Increases the version number in VERSION.md based on the commit type [major, minor, patch]
#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <commit_message> <commit_type>"
    exit 1
fi

COMMIT_MESSAGE=$1
COMMIT_TYPE=$2
VERSION_FILE="VERSION.md"

# Read the current version from VERSION.md
if [ ! -f "$VERSION_FILE" ]; then
    echo "Version file $VERSION_FILE does not exist."
    exit 1
fi

# Read the current version from VERSION.md
source "$VERSION_FILE"
# Increment the version based on the commit type
if [ "$COMMIT_TYPE" == "major" ]; then
    MAJOR_VERSION=$((MAJOR_VERSION + 1))
    MINOR_VERSION=0
    PATCH_VERSION=0
elif [ "$COMMIT_TYPE" == "minor" ]; then
    MINOR_VERSION=$((MINOR_VERSION + 1))
    PATCH_VERSION=0
elif [ "$COMMIT_TYPE" == "patch" ]; then
    PATCH_VERSION=$((PATCH_VERSION + 1))
else
    echo "Invalid commit type. Use 'major', 'minor', or 'patch'."
    exit 1
fi

# Write the new version to VERSION.md
echo "MAJOR_VERSION=$MAJOR_VERSION" > "$VERSION_FILE"
echo "MINOR_VERSION=$MINOR_VERSION" >> "$VERSION_FILE"
echo "PATCH_VERSION=$PATCH_VERSION" >> "$VERSION_FILE"

# Commit the changes
git add "$VERSION_FILE"


# Update the version in pubspec.yaml
if [ -f "frontend/pubspec.yaml" ]; then
    sed -i "s/^version: .*/version: $MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION/" frontend/pubspec.yaml
    git add frontend/pubspec.yaml
    git commit -m "Update version in pubspec.yaml to $MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION"
else
    echo "pubspec.yaml not found. Skipping version update in pubspec.yaml."
fi

git commit -m "$COMMIT_MESSAGE"