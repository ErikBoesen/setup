#!/usr/bin/env bash

# This script contains all setup commands that need to be executed as an administrator.

echo "Making boesene owner of /usr/local (for Homebrew and Golang)..."
chown -R boesene /usr/local
echo "Removing Adobe products (take a lot of data)..."
rm -rf /Applications/Adobe*
# TODO: Remove Adobe application support files etc.
echo "Removing iTunes..."
rm -rf /Applications/iTunes.app

echo "Removing broken kernel extensions..."
rm -rf /System/Library/Extensions/ZGHSUSBMassStorageFilter.kext /System/Library/Extensions/ZGHSUSBCDCACMData.kext
