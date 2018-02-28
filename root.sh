#!/usr/bin/env bash

echo "Making boesene owner of /usr/local (for Homebrew and Golang)..."
chown -R boesene /usr/local
echo "Removing Adobe products (take a lot of data)..."
rm -rf /Applications/Adobe*
# TODO: Remove Adobe application support files etc.
echo "Removing iTunes..."
rm -rf /Applications/iTunes.app

echo "Resetting root password (you'll need to enter a new password)..."
passwd
