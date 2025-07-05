#!/bin/bash
#
# Install Dotfiles Script
# This script creates symlinks from ~/dotfiles to your home directory
# Perfect for setting up dotfiles on a new machine
#

# --- Configuration ---
HOME_DIR=~
DOTFILES_DIR="$HOME_DIR/dotfiles"
BACKUP_DIR="$HOME_DIR/dotfiles_backup"

# VS Code configuration directory path (macOS specific)
# For Linux, this would be: VSCODE_USER_DIR="$HOME/.config/Code/User"
VSCODE_USER_DIR="$HOME_DIR/Library/Application Support/Code/User"

# --- Files to Manage (same as setup script) ---
files_to_manage=(
    # --- Files ---
    ".gitconfig"
    ".vimrc"
    ".zprofile"
    ".zshenv"
    ".zshrc"
    ".zshrc.pre-oh-my-zsh"

    # --- Directories ---
    ".config"
    ".oh-my-zsh/custom"
    ".vim"

    # --- Powerlevel10k config ---
    ".p10k.zsh"
)

# --- Command Line Options ---
DRY_RUN=false
VERBOSE=false
INSTALL_VSCODE_EXTENSIONS=false

show_help() {
    cat << EOF
Install Dotfiles Script

Usage: $0 [OPTIONS]

OPTIONS:
    -d, --dry-run          Show what would be done without making changes
    -v, --verbose          Show detailed output
    -e, --extensions       Install VS Code extensions from extensions.txt
    -h, --help            Show this help message

EXAMPLES:
    $0                     Install dotfiles
    $0 --dry-run          Preview what would be installed
    $0 -v -e              Verbose install with VS Code extensions

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -e|--extensions)
            INSTALL_VSCODE_EXTENSIONS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# --- Helper Functions ---
log() {
    if [[ "$VERBOSE" == true ]]; then
        echo "-> $1"
    fi
}

error() {
    echo "❌ ERROR: $1" >&2
}

warning() {
    echo "⚠️  WARNING: $1"
}

success() {
    echo "✅ $1"
}

info() {
    echo "ℹ️  $1"
}

backup_file() {
    local file_path="$1"
    local backup_path="$BACKUP_DIR/$(basename "$file_path")"

    if [[ "$DRY_RUN" == true ]]; then
        echo "Would backup '$file_path' to '$backup_path'"
        return
    fi

    mkdir -p "$BACKUP_DIR"
    mv "$file_path" "$backup_path"
    success "Backed up '$file_path' to '$backup_path'"
}

create_symlink() {
    local target="$1"
    local link_name="$2"

    if [[ "$DRY_RUN" == true ]]; then
        echo "Would create symlink: '$link_name' -> '$target'"
        return
    fi

    ln -s "$target" "$link_name"
    log "Created symlink: '$link_name' -> '$target'"
}

# --- Pre-flight Checks ---
echo "🚀 Starting dotfiles installation..."

if [[ "$DRY_RUN" == true ]]; then
    info "DRY RUN MODE - No changes will be made"
fi

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory not found at '$DOTFILES_DIR'"
    echo "Please clone or copy your dotfiles to '$DOTFILES_DIR' first."
    exit 1
fi

success "Found dotfiles directory at '$DOTFILES_DIR'"

# --- Standard Dotfile Installation ---
echo ""
echo "📁 Installing standard dotfiles..."

installed_count=0
skipped_count=0
backed_up_count=0

for item in "${files_to_manage[@]}"; do
    dotfile_path="$DOTFILES_DIR/$item"
    target_path="$HOME_DIR/$item"

    echo ""
    echo "--- Processing '$item' ---"

    # Check if dotfile exists in dotfiles directory
    if [ ! -e "$dotfile_path" ]; then
        warning "'$dotfile_path' not found in dotfiles directory. Skipping."
        ((skipped_count++))
        continue
    fi

    # Create parent directory if needed
    if [[ "$item" == */* ]] && [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$(dirname "$target_path")"
    fi

    # Check if target already exists
    if [ -L "$target_path" ]; then
        # It's already a symlink - check if it points to the right place
        current_target=$(readlink "$target_path")
        if [ "$current_target" = "$dotfile_path" ]; then
            log "'$item' is already correctly linked. Skipping."
            ((skipped_count++))
            continue
        else
            warning "'$item' is a symlink but points to '$current_target' instead of '$dotfile_path'"
            if [[ "$DRY_RUN" == false ]]; then
                rm "$target_path"
            fi
        fi
    elif [ -e "$target_path" ]; then
        # File/directory exists but is not a symlink - back it up
        warning "'$target_path' exists and is not a symlink. Backing up..."
        backup_file "$target_path"
        ((backed_up_count++))
    fi

    # Create the symlink
    create_symlink "$dotfile_path" "$target_path"
    success "Installed '$item'"
    ((installed_count++))
done

# --- VS Code Configuration ---
echo ""
echo "🔧 Installing VS Code configuration..."

if [ ! -d "$DOTFILES_DIR/vscode" ]; then
    warning "VS Code dotfiles not found at '$DOTFILES_DIR/vscode'. Skipping VS Code setup."
else
    # Ensure VS Code user directory exists
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$VSCODE_USER_DIR"
    fi

    vscode_configs=("settings.json" "keybindings.json" "snippets")

    for config_item in "${vscode_configs[@]}"; do
        vscode_dotfile="$DOTFILES_DIR/vscode/$config_item"
        vscode_target="$VSCODE_USER_DIR/$config_item"

        if [ ! -e "$vscode_dotfile" ]; then
            log "VS Code '$config_item' not found in dotfiles. Skipping."
            continue
        fi

        echo "--- Processing VS Code '$config_item' ---"

        if [ -L "$vscode_target" ]; then
            current_target=$(readlink "$vscode_target")
            if [ "$current_target" = "$vscode_dotfile" ]; then
                log "VS Code '$config_item' is already correctly linked. Skipping."
                continue
            else
                if [[ "$DRY_RUN" == false ]]; then
                    rm "$vscode_target"
                fi
            fi
        elif [ -e "$vscode_target" ]; then
            warning "VS Code '$config_item' exists. Backing up..."
            backup_file "$vscode_target"
        fi

        create_symlink "$vscode_dotfile" "$vscode_target"
        success "Installed VS Code '$config_item'"
    done

    # Install VS Code extensions if requested
    if [[ "$INSTALL_VSCODE_EXTENSIONS" == true ]]; then
        extensions_file="$DOTFILES_DIR/vscode/extensions.txt"
        if [ -f "$extensions_file" ]; then
            echo ""
            echo "📦 Installing VS Code extensions..."
            if [[ "$DRY_RUN" == true ]]; then
                echo "Would install VS Code extensions from '$extensions_file'"
            else
                if command -v code &> /dev/null; then
                    while IFS= read -r extension; do
                        if [ -n "$extension" ]; then
                            echo "Installing extension: $extension"
                            code --install-extension "$extension"
                        fi
                    done < "$extensions_file"
                    success "VS Code extensions installation complete"
                else
                    warning "VS Code CLI not found. Please install VS Code and try again with --extensions"
                fi
            fi
        else
            warning "Extensions file not found at '$extensions_file'"
        fi
    fi
fi

# --- Summary ---
echo ""
echo "🎉 Installation Summary"
echo "======================="
echo "✅ Installed: $installed_count files"
echo "⏭️  Skipped: $skipped_count files (already correct)"
if [ $backed_up_count -gt 0 ]; then
    echo "💾 Backed up: $backed_up_count files to '$BACKUP_DIR'"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    info "This was a dry run. Run without --dry-run to make actual changes."
else
    echo ""
    success "Dotfiles installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your shell or run 'source ~/.zshrc'"
    if [[ "$INSTALL_VSCODE_EXTENSIONS" == false ]] && [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
        echo "2. Install VS Code extensions: $0 --extensions"
    fi
    echo "3. Verify everything works as expected"
fi
