#!/bin/sh

if [ $# -ne 1 ]; then
    echo usage: $0 plist-file
    exit 1
fi

plist="$1"
dir="$(dirname "$plist")"
versionNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")

# Only increment the build number if source files have changed
if [ -n "$(find "$dir" \! -path "*xcuserdata*" \! -path "*.git" -newer "$plist")" ]; then
    buildnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleVersion" "$plist")
    if [ -z "$buildnum" ]; then
        echo "No build number in $plist"
        exit 2
    fi
    buildnum=$(expr $buildnum + 1)

    /usr/libexec/PlistBuddy "$SRCROOT/Ticker/Settings.bundle/Root.plist" -c "set PreferenceSpecifiers:4:DefaultValue $versionNumber ($buildnum)"
    /usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "$plist"

    echo "Incremented build number to $buildnum"
else
    echo "Not incrementing build number as source files have not changed"
fi