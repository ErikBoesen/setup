#!/usr/bin/env bash

read -p "Parts of this script won't work if you don't have access to /usr/local. Make sure to gain access before running this script. Press enter to continue." _

echo "Adding git identity information..."
git config --global user.name "ErikBoesen"
git config --global user.email me@erikboesen.com

echo "Please login to Keybase:"
keybase login

echo "Installing gpg..."
brew install gpg

keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key-import --import

gpg --list-secret-keys

read -p "Right above, there should be a line reading 'sec   4096R/######## [Date]'. Please copy and paste the ########: " signingkey

echo "Editing git config to enable signing..."
git config --global user.signingkey $signingkey
git config --global commit.gpgsign true

echo "Adding commit alias to always sign commits..."
git config --global alias.commit "commit -S"

# I've already done this; if someone else is using this they'll need this code.
#keybase pgp export | pbcopy
#read -p "You're now going to need to add a key to GitHub. The key has been copied to your clipboard. Press enter when ready and click 'New GPG key' then paste." _
#open "https://github.com/settings/keys"

echo "Keybase git commit signing setup complete!"

echo "Installing Source Code Pro font... (font book will open and need you to click install)"
# TODO: Download latest release automatically.
curl -LOk "https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip"
unzip "1.050R-it.zip"
open "source-code-pro-2.030R-ro-1.050R-it/OTF/*"


echo "Creating temporary setup-files directory..."
mkdir -p "$HOME/Desktop/setup-files"
cd "$HOME/Desktop/setup-files"

echo "Preparing to install oh-my-zsh, you'll need to enter your user password."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Installing your zsh config from gist..."
curl "https://gist.githubusercontent.com/ErikBoesen/c5d3d575c8f1b592b473f9b128ef3d7c/raw/3809cc153f746d1c57e751946ff847e7e68e5f3e/.zshrc" > "$HOME/.zshrc"


echo "Installing erkbsn zsh theme..."
curl "https://raw.githubusercontent.com/ErikBoesen/erkbsn/master/erkbsn.zsh-theme" > "$HOME/.oh-my-zsh/themes/erkbsn.zsh-theme"

mkdir -p "$HOME/.ssh"
curl "https://gist.githubusercontent.com/ErikBoesen/3e796aa1772f7c99fcdd54e8d12ae188/raw/5db29319a54622068533669050a12470be75f09a/ssh%2520config" > "$HOME/.ssh/config"

echo "Done with configuration! Beginning app installs."

echo "Installing Atom..."
curl -O "https://atom.io/download/mac"
unzip "atom-mac.zip"
mv "Atom.app" "$HOME/Documents/Atom.app"
open "$HOME/Documents/Atom.app"

# TODO: Auto-install atom plugins
for $package in "atom-beautify" "linter" "linter-pylama" "merge-conflicts"; do
    apm install $package
done

echo "Installing Google Chrome..."
curl -O "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
hdiutil mount "googlechrome.dmg"
mv "/Volumes/Google Chrome/Google Chrome.app" "$HOME/Documents/Google Chrome.app"
hdiutil unmount "/Volumes/Google Chrome"
open "$HOME/Documents/Google Chrome.app"

echo "Installing Google Drive..."
curl -O "https://dl.google.com/drive/installgoogledrive.dmg"
hdiutil mount "installgoogledrive.dmg"
mv "/Volumes/Google Drive/Google Drive.app" "$HOME/Documents/Google Drive.app"
hdiutil unmount "/Volumes/Google Drive"
open "$HOME/Documents/Google Drive.app"

echo "Opening Slack downloads page."
# Slack's download URL contains a version, so just open it for now.
open "https://slack.com/downloads/osx"

echo "Downloading and starting Spotify installer..."
curl -LOk "https://download.scdn.co/SpotifyInstaller.zip"
unzip "SpotifyInstaller.zip"
open "Spotify Installer.app" # TODO: Does this work?

echo "Installing Discord (Standard)..."
curl -O "https://discordapp.com/api/download?platform=osx"
hdiutil mount "Discord.dmg"
mv -R "/Volumes/Discord.app/Discord.app" "$HOME/Documents/Discord.app"
hdiutil unmount "/Volumes/Discord"
open "$HOME/Documents/Discord.app"

echo "Installing Discord (Canary)..."
curl -O "https://discordapp.com/api/download/canary?platform=osx"
hdiutil mount "Discord Canary.dmg"
mv "/Volumes/Discord/Discord Canary.app" "$HOME/Documents/Discord Canary.app"
hdiutil unmount "/Volumes/Discord"
open "$HOME/Documents/Discord Canary.app"

echo "Installing terminal settings..."
cp ~/Google\ Drive/Fun/com.apple.Terminal.plist ~/Library/Preferences/com.apple.Terminal.plist

echo "Cloning ErikBoesen/bin..."
git clone https://github.com/ErikBoesen/bin ~/bin

read -p "Done! Do you want to remove the ~/Desktop/setup-files directory? (y/n, lowercase)" remove
if [ remove == "y" ]; then
    rm -rf "$HOME/Desktop/setup-files"
fi


# TODO: remove toolbar items, fix spaces settings
