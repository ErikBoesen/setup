#!/usr/bin/env bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

start=$(date +%s)

app_target="$HOME/Applications"

function install_dmg {
    # Parameters:
    #   install_dmg 1(App name) 2(Download URL) 3(DMG filename)
    if [ -d "$app_target/$1.app" ]; then
        echo "$1 is already installed."
        return
    fi
    echo "Installing $1..."
    curl -o /tmp/$3 $2
    hdiutil mount /tmp/$3
    cp -r /Volumes/$1/*.app $app_target/
    hdiutil unmount /Volumes/$1
    rm /tmp/$3
    open $app_target/$1.app
}

function install_zip {
    # Parameters:
    #   install_zip 1(App name) 2(Download URL) 3(ZIP filename)
    if [ -d "$app_target/$1.app" ]; then
        echo "$1 is already installed."
        return
    fi
    echo "Installing $1..."
    curl -Lo /tmp/$3 $2
    unzip -q /tmp/$3 -d /tmp/
    mv /tmp/$1.app $app_target/
    open $app_target/$1.app
}

if xcode-select --version > /dev/null; then
    echo "XCode developer tools are installed!"
else
    echo "XCode developer tools must be installed!"
    xcode-select --install
    exit 1
fi

if [ "$(stat -f '%u' /usr)" = 0 ]; then
    echo "You must run root.sh (as root) first!"
    exit 1
fi

if ! brew --version >/dev/null; then
    echo "Homebrew not installed!"
    exit 1
fi

echo "Installing & updating Homebrew packages (bg)..."
(cat res/packages_brew.txt | xargs brew install && brew update) >/dev/null &

echo "Installing crontab..."
crontab res/crontab

open "https://github.com/login"
read -p "Please sign into GitHub before running. Press enter to continue." _

echo "Cloning bin..."
git clone -q https://github.com/ErikBoesen/macbin ~/.bin &
(echo "Cloning dotfiles..."
git clone -q https://github.com/ErikBoesen/.files ~/.files

echo "Bootstrapping dotfiles..."
~/.files/bootstrap.sh) &

install_dmg "Keybase" "https://prerelease.keybase.io/Keybase.dmg" "Keybase.dmg"

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

echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Opening Unsplash page with a search for 'parrot' so you can find a desktop background."
open "https://unsplash.com/search/parrot"

echo "Disabling space rearranging based on recent use..."
defaults write com.apple.dock mru-spaces -bool false

echo "Disable opening Photos on plug..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

echo "Changing graphics settings for speed..."
# https://www.defaults-write.com/10-terminal-commands-to-speed-up-macos-sierra-on-your-mac/
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.finder DisableAllAnimations -bool true

echo "Disabling mission control and spaces..."
# https://www.defaults-write.com/mac-os-x-disable-mission-control-and-spaces/
defaults write com.apple.dock mcx-expose-disabled -bool TRUE

echo "Disabling Dashboard..."
defaults write com.apple.dashboard mcx-disabled -bool TRUE

echo "Removing Launchpad animations.."
# TODO: Totally disable Launchpad
defaults write com.apple.dock springboard-show-duration -int 0
defaults write com.apple.dock springboard-hide-duration -int 0

echo "Showing full POSIX path in Finder header..."
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "Installing erkbsn zsh theme..."
curl -Lo $HOME/.oh-my-zsh/themes/erkbsn.zsh-theme "https://raw.github.com/ErikBoesen/erkbsn/master/erkbsn.zsh-theme"

echo "Done with configuration! Beginning independent installs."

echo "Making unlocked System Preferences app..."
cp -r /Applications/System\ Preferences.app $app_target
rm $app_target/System\ Preferences.app/Contents/Resources/NSPrefPaneGroups.xml

echo "Installing GIMP with Homebrew..."
brew cask install gimp --appdir=$app_target
#echo "Opening GIMP download page..."
## TODO: Auto-download
#open "https://www.gimp.org/downloads/"

echo "Making \$GOPATH..."
mkdir -p /usr/local/go

install_zip "Atom" "https://atom.io/download/mac" "atom-mac.zip"

echo "Installing Atom packages (bg)..."
while read package; do
    if [[ ! -d "$HOME/.atom/packages/$package" ]]; then
        apm install $package &
    fi
done < res/packages_apm.txt

install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "googlechrome.dmg"
install_zip "Install Spotify" "https://download.scdn.co/SpotifyInstaller.zip" "SpotifyInstaller.zip"

echo "Recreating source directory from backup..."
echo "Copying from server..."
scp juno:"dump-*/{src.tar,repos.txt}" /tmp/ &&
echo "Extracting..." &&
tar -xkf /tmp/src.tar -C ~/src

while read repo; do
    git clone "$repo" ~/src/$repo
done < /tmp/repos.txt

echo "Showing hidden files..."
defaults write com.apple.finder AppleShowAllFiles YES

echo "Showing all file extensions..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

wait
echo "Done!"

end=$(date +%s)
osascript -e "display notification \"Finished in $((end-start))s.\" with title \"Setup complete\!\" sound name \"\""
