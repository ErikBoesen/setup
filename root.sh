#!/usr/bin/env bash

# TODO: Install Homebrew automatically

echo "Changing PATH (commands like chown aren't there by default)..."
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

echo "Making boesene owner of /usr/local (for Homebrew and Golang)..."
chown -R boesene /usr/local

echo "Disabling iTunes..."
rm -f /Applications/iTunes.app/Contents/Info.plist

echo "Removing inconvenient managed preferences..."
rm -f /Library/Managed\ Preferences/com.google.Chrome.plist \
      /Library/Managed\ Preferences/*/com.google.Chrome.plist

echo "Running clean script..."
git clone https://github.com/ErikBoesen/clean /tmp/clean
/tmp/clean/clean.sh

echo "Disabling inconvenient Chrome restrictions..."
plutil -remove DeveloperToolsDisabled /Library/Managed\ Preferences/com.google.Chrome.plist
plutil -remove IncognitoModeAvailability /Library/Managed\ Preferences/com.google.Chrome.plist

echo "Enabling SSH..."
systemsetup -setremotelogin on >/dev/null
echo "Opening SSH to all users..."
dscl . change /Groups/com.apple.access_ssh RecordName com.apple.access_ssh com.apple.access_ssh-disabled >/dev/null
echo "Resetting root password..."
passwd
