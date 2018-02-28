#!/usr/bin/env bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

if git --version | grep -c "git version" >/dev/null; then
    echo "XCode developer tools have been installed!"
else
    echo "XCode developer tools must be installed!"
    xcode-select --install
    exit 1
fi

read -p "Have you run the root script?" _
read -p "Have you installed Homebrew?" _

open "https://github.com/login"
read -p "Please sign into GitHub before running. Press enter to continue." _

echo "Installing Homebrew packages..."
cat packages.txt | xargs brew install &

echo "Cloning bin..."
git clone -q https://github.com/ErikBoesen/macbin ~/.bin
echo "Cloning dotfiles..."
git clone -q https://github.com/ErikBoesen/.files ~/.files

echo "Bootstrapping dotfiles..."
~/.files/bootstrap.sh

echo "Installing gpg..."
brew install gpg
echo "Installing Keybase..."
curl "https://prerelease.keybase.io/Keybase.dmg" --output /tmp/Keybase.dmg
hdiutil mount "/tmp/Keybase.dmg"
mv "/Volumes/Keybase/Keybase.app" "$HOME/Documents/Keybase.app"
hdiutil unmount "/Volumes/Keybase"
open "$HOME/Documents/Keybase.app"

echo "Please login to Keybase:"
keybase login


keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key-import --import

echo "Keybase git commit signing setup complete!"

echo "Installing wget..."
brew install wget

echo "Installing Source Code Pro font... (font book will open and need you to click install)"
# TODO: Download latest release automatically.
rm -rf /tmp/source-code* /tmp/1.05*
curl -Lk "https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip" --output /tmp/
unzip "/tmp/1.050R-it.zip"
open "/tmp/source-code-pro-2.030R-ro-1.050R-it/OTF/*"

echo "Preparing to install oh-my-zsh, you'll need to enter your user password."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "You're going to need to set up your SSH config. Since it's private we can't curl it, but we'll open it and then you can paste it."
# TODO: Figure out some way to download this automatically.
mkdir -p "$HOME/.ssh"
sleep 1s
open "https://gist.github.com/ErikBoesen/3e796aa1772f7c99fcdd54e8d12ae188/raw/"
nano "$HOME/.ssh/config"

echo "Opening Unsplash page with a search for 'parrot' so you can find a desktop background."
open "https://unsplash.com/search/parrot"

echo "Installing erkbsn zsh theme..."
wget -quiet "https://raw.githubusercontent.com/ErikBoesen/erkbsn/master/erkbsn.zsh-theme" -O "$HOME/.oh-my-zsh/themes/erkbsn.zsh-theme"


echo "Done with configuration! Beginning independent installs."

echo "Opening GIMP download page..."
# TODO: Auto-download
open "https://www.gimp.org/downloads/"

echo "Installing golang..."
brew install golang
mkdir -p /usr/local/go
export GOPATH=/usr/local/go

echo "Installing Atom..."
curl -O "https://atom.io/download/mac"
unzip "atom-mac.zip"
mv "Atom.app" "$HOME/Documents/Atom.app"
open "$HOME/Documents/Atom.app"

count=`ls -1 $HOME/.atom/packages 2>/dev/null | wc -l`
if (( $count <= 1 )); then
    echo "Installing atom packages..."
    echo "(This often takes a while. Be patient.)"
    apm install atom-beautify linter linter-pylama merge-conflicts language-common-lisp
fi

echo "Installing Google Chrome..."
curl -O "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
hdiutil mount "googlechrome.dmg"
mv "/Volumes/Google Chrome/Google Chrome.app" "$HOME/Documents/Google Chrome.app"
hdiutil unmount "/Volumes/Google Chrome"
open "$HOME/Documents/Google Chrome.app"

echo "Opening Slack downloads page."
# Slack's download URL contains a version, so just open it for now.
open "https://slack.com/downloads/osx"

echo "Downloading and starting Spotify installer..."
curl -LOk "https://download.scdn.co/SpotifyInstaller.zip"
unzip "SpotifyInstaller.zip" > /dev/null
open "Spotify Installer.app" # TODO: Does this work?

#echo "Installing Discord (Standard)..."
#curl -O "https://discordapp.com/api/download?platform=osx"
#hdiutil mount "Discord.dmg"
#mv -R "/Volumes/Discord.app/Discord.app" "$HOME/Documents/Discord.app"
#hdiutil unmount "/Volumes/Discord"
#open "$HOME/Documents/Discord.app"

#echo "Installing Discord (Canary)..."
#curl -O "https://discordapp.com/api/download/canary?platform=osx"
#hdiutil mount "Discord Canary.dmg"
#mv "/Volumes/Discord/Discord Canary.app" "$HOME/Documents/Discord Canary.app"
#hdiutil unmount "/Volumes/Discord"
#open "$HOME/Documents/Discord Canary.app"

echo "Last step: running brew upgrade to upgrade Python3 and everything else. Will probably take a bit."
echo "(Install silenced.)"
brew upgrade

echo "We're done!"
echo "Remember to remove toolbar items and FIX SPACES SETTINGS!"


# TODO: remove toolbar items, fix spaces settings
