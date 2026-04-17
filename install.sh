#!/bin/bash

DOTS="$HOME/dotfiles"
CONFIG="$HOME/.config"

apps=("hypr" "kitty" "waybar" "tofi" "discord")

for app in "${apps[@]}"; do
    if [ -d "$HOME/dotfiles/$app" ]; then
        ln -sfn "$HOME/dotfiles/$app" "$HOME/.config/$app"
    else
        echo "$DOTS/$app doesnt exist"
    fi
done

PROFILE_NAME=$(ls "$HOME/.config/mozilla/firefox" | grep default | head -n 1)
FF_PROFILE_PATH="$HOME/.config/mozilla/firefox/$PROFILE_NAME"

if [ -n "$PROFILE_NAME" ]; then
    mkdir -p "$FF_PROFILE_PATH/chrome"
    ln -sfn "$HOME/dotfiles/firefox/chrome/userChrome.css" "$FF_PROFILE_PATH/chrome/userChrome.css"
    ln -sfn "$HOME/dotfiles/firefox/chrome/userContent.css" "$FF_PROFILE_PATH/chrome/userContent.css"
else
    echo "couldnt find firefox profile"
fi