#!/bin/bash

DOTS="$HOME/dotfiles"
CONFIG="$HOME/.config"

apps=("hypr" "waybar")

for app in "${apps[@]}"; do
    if [ -d "$DOTS/$app" ]; then
        mkdir -p "$CONFIG/$app"

        for file in "$DOTS/$app"/*; do
            if [ -e "$file" ]; then
                # Fix: Removed spaces around the '=' assignment operator
                filename=$(basename "$file")
                
                # Fix: Quoted variables to prevent breakage on files with spaces
                rm -rf "$CONFIG/$app/$filename"
                ln -sf "$file" "$CONFIG/$app/$filename"
            fi
        done
    else
        echo "Source directory $DOTS/$app does not exist."
    fi
done

PROFILE_NAME=$(ls "$HOME/.config/mozilla/firefox" | grep default | head -n 1)
FF_PROFILE_PATH="$HOME/.config/mozilla/firefox/$PROFILE_NAME"

if [ -n "$PROFILE_NAME" ]; then
    echo "doing $PROFILE_NAME"
    mkdir -p "$FF_PROFILE_PATH/chrome"
    ln -sfn "$HOME/dotfiles/firefox/chrome/userChrome.css" "$FF_PROFILE_PATH/chrome/userChrome.css"
    ln -sfn "$HOME/dotfiles/firefox/chrome/userContent.css" "$FF_PROFILE_PATH/chrome/userContent.css"
else
    echo "couldnt find firefox profile"
fi
