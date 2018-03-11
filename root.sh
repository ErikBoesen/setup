#!/usr/bin/env bash

# TODO: Install Homebrew automatically
echo "Making boesene owner of /usr/local (for Homebrew and Golang)..."
chown -R boesene /usr/local
echo "Removing Adobe products (take a lot of data)..."
rm -rf /Applications/Adobe*
# TODO: Remove Adobe application support files etc.
echo "Disabling iTunes..."
rm -rf /Applications/iTunes.app/Contents/Info.plist
echo "Disabling inconvenient Chrome restrictions..."
plutil -remove DeveloperToolsDisabled /Library/Managed\ Preferences/com.google.Chrome.plist
plutil -remove IncognitoModeAvailability /Library/Managed\ Preferences/com.google.Chrome.plist
echo "Resetting root password..."
passwd
