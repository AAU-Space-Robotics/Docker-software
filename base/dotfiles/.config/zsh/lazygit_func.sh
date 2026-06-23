#!/bin/bash

# gitl function
gitl_func() {
    # Start ssh-agent if not running
    if ! pgrep -u "$(id -un)" ssh-agent >/dev/null; then
        eval "$(ssh-agent -s)" >/dev/null
    fi

    # Find all private key files in ~/.ssh
    for key in "$HOME/.ssh/"*(N); do
        # Skip non-files and known non-private key files
        if [[ ! -f "$key" ]] || [[ "$key" == *.pub ]] || [[ "$key" == *known_hosts* ]] || [[ "$key" == *config* ]] || [[ "$key" == *authorized_keys* ]]; then
            continue
        fi

        # Check if it looks like a private key by reading the first line
        if head -n 1 "$key" | grep -q "PRIVATE KEY"; then
            # Only add if not already loaded
            if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')"; then
                ssh-add "$key" >/dev/null
            fi
        fi
    done

    # Run lazygit and handle directory switching
    export LAZYGIT_NEW_DIR_FILE="$HOME/.lazygit/newdir"
    lazygit "$@"
    if [ -f "$LAZYGIT_NEW_DIR_FILE" ]; then
        cd "$(cat "$LAZYGIT_NEW_DIR_FILE")" || return
        rm -f "$LAZYGIT_NEW_DIR_FILE"
    fi
}

# Alias so you can just type gitl
alias gitl='gitl_func'
