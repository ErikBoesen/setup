#!/usr/bin/env bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

start=$(date +%s)

app_target="$HOME/Applications"

function task {
    echo "$1..."
}

function install_dmg {
    # Parameters:
    #   install_dmg 1(App name) 2(Download URL) 3(DMG filename)
    if [ -d "$app_target/$1.app" ]; then
        echo "$1 is already installed."
        return
    fi
    task "Installing $1"
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
    task "Installing $1"
    curl -Lo /tmp/$3 $2
    unzip -q /tmp/$3 -d /tmp/
    mv /tmp/$1.app $app_target/
    open $app_target/$1.app
}

if xcode-select -p &> /dev/null; then
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

task "Installing & updating Homebrew packages (bg)"
(cat res/packages_brew.txt | xargs brew install && brew update) >/dev/null &

task "Installing crontab"
crontab res/crontab

open "https://github.com/login"
read -p "Please sign into GitHub before running. Press enter to continue." _

task "Cloning bin"
git clone -q https://github.com/ErikBoesen/macbin ~/.bin &
(task "Cloning dotfiles"
git clone -q https://github.com/ErikBoesen/.files ~/.files

task "Bootstrapping dotfiles"
~/.files/bootstrap.sh) &

brew tap homebrew/cask-versions  # For Nightly
brew cask install firefox-nightly keybase

wait
echo "Please login to Keybase:"
keybase login

keybase pgp export | gpg --import
keybase pgp export --secret --unencrypted | gpg --allow-secret-key-import --import

echo "Keybase git commit signing setup complete!"

task "Installing Source Code Pro font"
brew tap caskroom/fonts && brew cask install font-source-code-pro

echo "Opening Unsplash page with a search for 'parrot' so you can find a desktop background."
open "https://unsplash.com/search/parrot"

task "Showing battery percentage"
defaults write com.apple.menuextra.battery ShowPercent -bool true

task "Disabling space rearranging based on recent use"
defaults write com.apple.dock mru-spaces -bool false

task "Disable opening Photos on plug"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

task "Changing graphics settings for speed"
# https://www.defaults-write.com/10-terminal-commands-to-speed-up-macos-sierra-on-your-mac/
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.finder DisableAllAnimations -bool true

task "Disabling mission control and spaces"
# https://www.defaults-write.com/mac-os-x-disable-mission-control-and-spaces/
#defaults write com.apple.dock mcx-expose-disabled -bool TRUE

task "Disabling Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool TRUE

echo "Removing Launchpad animations.."
# TODO: Totally disable Launchpad
# https://www.defaults-write.com/disable-launchpad-fade-effects/
defaults write com.apple.dock springboard-show-duration -int 0
defaults write com.apple.dock springboard-hide-duration -int 0

task "Showing full POSIX path in Finder header"
# https://www.defaults-write.com/display-full-posix-path-in-os-x-finder-title-bar/
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

task "Disabling two-finger swipe in Chrome"
# https://www.defaults-write.com/disable-the-two-finger-swipe-gesture-in-chrome/
defaults write com.google.Chrome.plist AppleEnableSwipeNavigateWithScrolls -bool FALSE

task "Disabling .DS_Store files"
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

echo "Done with configuration! Beginning independent installs."

task "Making unlocked System Preferences app"
cp -r /Applications/System\ Preferences.app $app_target
rm $app_target/System\ Preferences.app/Contents/Resources/NSPrefPaneGroups.xml

task "Installing Vundle"
mkdir -p $HOME/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
task "Installing tpm"
mkdir -p $HOME/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

task "Installing GIMP"
brew cask install gimp --appdir=$app_target

task "Making \$GOPATH"
mkdir -p /usr/local/go

task "Installing Chrome"
brew cask install google-chrome --appdir=$app_target
task "Installing Spotify"
brew cask install spotify --appdir=$app_target

task "Recreating source directory from backup"
task "Copying from server"
scp juno:"dump-*/{src.tar,repos.txt}" /tmp/ &&
task "Extracting" &&
tar -xkf /tmp/src.tar -C ~/src

while read repo; do
    git clone "$repo" ~/src/$repo
done < /tmp/repos.txt

task "Showing hidden files"
defaults write com.apple.finder AppleShowAllFiles YES

task "Showing all file extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

wait
echo "Done!"

end=$(date +%s)
osascript -e "display notification \"Finished in $((end-start))s.\" with title \"Setup complete\!\" sound name \"\""
