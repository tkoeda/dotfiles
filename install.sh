#!/bin/bash
#
# Dotfiles Installation Script (Cross-platform: macOS & Linux/WSL)
# Creates symlinks from this repo to your home directory
#

set -e  # Exit on error

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    VSCODE_USER_DIR="$HOME/.config/Code/User"
else
    PLATFORM="unknown"
fi

echo "========================================="
echo "  Dotfiles Installation"
echo "========================================="
echo "Platform: $PLATFORM"
echo "Installing from: $DOTFILES_DIR"
echo ""

# Initialize git submodules if needed
if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
    echo "Initializing git submodules..."
    cd "$DOTFILES_DIR"
    git submodule update --init --recursive
    echo ""
fi

# Files to symlink
FILES=(
    ".gitconfig"
    ".p10k.zsh"
    ".zshrc"
)

# macOS-specific files
if [[ "$PLATFORM" == "macos" ]]; then
    FILES+=(
        ".vimrc"
        ".zprofile"
        ".zshenv"
        ".vim"
        ".config"
    )
fi

# Function to backup existing files
backup_file() {
    local file="$1"
    if [[ -e "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        echo "  Backing up existing $file"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
}

# Function to create symlink
create_symlink() {
    local file="$1"
    local source="$DOTFILES_DIR/$file"
    local target="$HOME/$file"

    # Skip if file doesn't exist in dotfiles
    if [[ ! -e "$source" ]]; then
        echo "  Skipping $file (not found in dotfiles)"
        return
    fi

    # Remove existing symlink if it points somewhere else
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -sf "$source" "$target"
    echo "  ✓ Linked $file"
}

# Install dotfiles
echo "Installing dotfiles..."
for file in "${FILES[@]}"; do
    backup_file "$file"
    create_symlink "$file"
done

# Link oh-my-zsh custom directory
if [[ -d ~/.oh-my-zsh ]]; then
    echo ""
    echo "Linking oh-my-zsh custom plugins and themes..."

    # Create custom directories if they don't exist
    mkdir -p ~/.oh-my-zsh/custom/plugins
    mkdir -p ~/.oh-my-zsh/custom/themes

    # Link plugins
    if [[ -d "$DOTFILES_DIR/custom/plugins" ]]; then
        for plugin in "$DOTFILES_DIR/custom/plugins"/*; do
            if [[ -d "$plugin" ]]; then
                plugin_name=$(basename "$plugin")
                target="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"

                # Remove existing symlink
                [[ -L "$target" ]] && rm "$target"

                ln -sf "$plugin" "$target"
                echo "  ✓ Linked plugin: $plugin_name"
            fi
        done
    fi

    # Link themes
    if [[ -d "$DOTFILES_DIR/custom/themes" ]]; then
        for theme in "$DOTFILES_DIR/custom/themes"/*; do
            if [[ -d "$theme" ]]; then
                theme_name=$(basename "$theme")
                target="$HOME/.oh-my-zsh/custom/themes/$theme_name"

                # Remove existing symlink
                [[ -L "$target" ]] && rm "$target"

                ln -sf "$theme" "$target"
                echo "  ✓ Linked theme: $theme_name"
            fi
        done
    fi
fi

# Create .gitconfig.local if it doesn't exist
if [[ ! -f ~/.gitconfig.local ]]; then
    echo ""
    echo "Creating ~/.gitconfig.local from template..."
    if [[ -f "$DOTFILES_DIR/.gitconfig.local.example" ]]; then
        cp "$DOTFILES_DIR/.gitconfig.local.example" ~/.gitconfig.local
        echo "  ✓ Created ~/.gitconfig.local"
        echo "  ⚠️  Please edit ~/.gitconfig.local to add your name, email, and credentials"
    fi
fi

# VS Code setup (optional)
if [[ -d "$DOTFILES_DIR/vscode" ]] && command -v code &> /dev/null; then
    echo ""
    read -p "Install VS Code configuration? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$VSCODE_USER_DIR"

        for item in settings.json keybindings.json snippets; do
            if [[ -e "$DOTFILES_DIR/vscode/$item" ]]; then
                backup_file "Library/Application Support/Code/User/$item" 2>/dev/null || true
                backup_file ".config/Code/User/$item" 2>/dev/null || true

                [[ -L "$VSCODE_USER_DIR/$item" ]] && rm "$VSCODE_USER_DIR/$item"
                ln -sf "$DOTFILES_DIR/vscode/$item" "$VSCODE_USER_DIR/$item"
                echo "  ✓ Linked VS Code $item"
            fi
        done
    fi
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="

if [[ -d "$BACKUP_DIR" ]]; then
    echo "Original files backed up to: $BACKUP_DIR"
fi

echo ""
echo "Next steps:"
echo "1. Edit ~/.gitconfig.local with your name and email"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Verify everything works correctly"
echo ""
