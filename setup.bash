#!/usr/bin/env bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

function install_dmg {
    # Parameters:
    #   install_dmg 1(App name) 2(Download URL) 3(DMG filename)
    echo "Installing $1..."
    curl -o /tmp/$3 $2
    hdiutil mount /tmp/$3
    cp -r /Volumes/$1/*.app $HOME/Documents/
    hdiutil unmount /Volumes/$1
    rm /tmp/$3
    open $HOME/Documents/$1.app
}

function install_zip {
    # Parameters:
    #   install_zip 1(App name) 2(Download URL) 3(ZIP filename)
    echo "Installing $1..."
    curl -Lo /tmp/$3 $2
    unzip -q /tmp/$3 -d /tmp
    mv /tmp/$1.app $HOME/Documents/$1.app
    open $HOME/Documents/$1.app
}

if xcode-select --version > /dev/null; then
    echo "XCode developer tools are installed!"
else
    echo "XCode developer tools must be installed!"
    xcode-select --install
    exit 1
fi

read -p "Have you run the root script?" _
read -p "Have you installed Homebrew?" _

echo "Installing & updating Homebrew packages (bg)..."
(cat packages.txt | xargs brew install && brew update) >/dev/null &

open "https://github.com/login"
read -p "Please sign into GitHub before running. Press enter to continue." _

echo "Cloning bin..."
git clone -q https://github.com/ErikBoesen/macbin ~/.bin &
(echo "Cloning dotfiles..."
git clone -q https://github.com/ErikBoesen/.files ~/.files

echo "Bootstrapping dotfiles..."
~/.files/bootstrap.sh) &

if keybase --version >/dev/null; then
    echo "Keybase is already installed!"
else
    install_dmg "Keybase" "https://prerelease.keybase.io/Keybase.dmg" "Keybase.dmg"
fi

echo "Please login to Keybase:"
keybase login
wait

keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key-import --import

echo "Keybase git commit signing setup complete!"

echo "Installing Source Code Pro font... (font book will open and need you to click install)"
# TODO: Download latest release automatically.
(rm -rf /tmp/source-code* /tmp/1.05*
curl -Lks "https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip" --output /tmp/
unzip "/tmp/1.050R-it.zip"
open "/tmp/source-code-pro-2.030R-ro-1.050R-it/OTF/*") &

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

echo "Making \$GOPATH..."
mkdir -p /usr/local/go

install_zip "Atom" "https://atom.io/download/mac" "atom-mac.zip"

echo "Installing Atom packages (bg)..."
while read package; do
    if [[ ! -d "$HOME/.atom/packages/$package" ]]; then
        apm install $package &
    fi
done < packages_apm.txt

install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "googlechrome.dmg"

echo "Opening Slack downloads page."
# Slack's download URL contains a version, so just open it for now.
open "https://slack.com/downloads/osx"

echo "Downloading and starting Spotify installer..."
curl -LOk "https://download.scdn.co/SpotifyInstaller.zip"
unzip "SpotifyInstaller.zip"
open "Install Spotify.app"

echo "We're done!"
echo "Remember to remove toolbar items and FIX SPACES SETTINGS!"


# TODO: remove toolbar items, fix spaces settings
