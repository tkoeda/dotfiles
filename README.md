# Dotfiles

Cross-platform dotfiles for macOS and Linux/WSL.

## Features

- **Cross-platform support**: Works on macOS (Intel & Apple Silicon) and Linux/WSL
- **Zsh configuration** with [Oh My Zsh](https://ohmyz.sh/)
- **Powerlevel10k** theme for a beautiful terminal
- **Useful plugins**: autosuggestions, syntax highlighting, shift-select
- **Modern CLI tools**: eza (better ls), zoxide (smarter cd)
- **Git aliases** for faster workflow
- **Platform-specific configurations** handled automatically

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/tkoeda/dotfiles.git ~/dotfiles
```

### 2. Run the installer

```bash
cd ~/dotfiles
./install.sh
```

The installer will:
- Initialize git submodules (plugins & theme)
- Create symlinks to your home directory
- Set up platform-specific configurations
- Create a `.gitconfig.local` template for your personal settings

### 3. Configure your Git identity

Edit `~/.gitconfig.local` with your name and email:

```bash
vim ~/.gitconfig.local
```

### 4. Restart your shell

```bash
exec zsh
```

## What Gets Installed

### Common (both platforms)
- `.zshrc` - Main zsh configuration
- `.gitconfig` - Git aliases and settings
- `.p10k.zsh` - Powerlevel10k theme configuration
- Oh My Zsh custom plugins & themes

### macOS only
- `.vimrc`, `.vim/` - Vim configuration
- `.config/` - Application configs
- `.zprofile`, `.zshenv` - Additional zsh configs

## Platform-Specific Features

### macOS
- Homebrew PATH configuration (supports both Intel and Apple Silicon)
- pyenv for Python version management
- macOS-specific aliases and tools

### Linux/WSL
- User-local bin directory (`~/.local/bin`) in PATH
- Windows Git Credential Manager integration (WSL)
- Linux-optimized configurations

## Required Tools

### Prerequisites (install first)
- Git
- Zsh
- [Oh My Zsh](https://ohmyz.sh/)

### Recommended
- [eza](https://github.com/eza-community/eza) - Modern ls replacement
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter cd command
- [nvim](https://neovim.io/) - Modern vim

### macOS specific
- [Homebrew](https://brew.sh/)
- [pyenv](https://github.com/pyenv/pyenv)

## Directory Structure

```
dotfiles/
├── .gitconfig                  # Shared git configuration
├── .gitconfig.local.example    # Template for user-specific settings
├── .zshrc                      # Main zsh config (cross-platform)
├── .p10k.zsh                   # Powerlevel10k theme
├── .vimrc, .vim/              # Vim configuration
├── .config/                    # Application configs
├── custom/                     # Oh My Zsh customizations
│   ├── plugins/               # Zsh plugins (as git submodules)
│   └── themes/                # Zsh themes (as git submodules)
├── install.sh                  # Cross-platform installer
└── README.md                   # This file
```

## Customization

### Local overrides

Create `~/.zshrc.local` for machine-specific configurations:

```bash
# Example: Add local aliases
alias myproject='cd ~/code/my-project'

# Example: Add to PATH
export PATH="$HOME/custom-tools:$PATH"
```

This file is sourced at the end of `.zshrc` and won't be tracked by git.

### Git configuration

User-specific git settings go in `~/.gitconfig.local`:
- User name and email
- Credential helpers
- Platform-specific settings

## Updating

Pull the latest changes:

```bash
cd ~/dotfiles
git pull
git submodule update --init --recursive
```

## Troubleshooting

### Plugins not found

If oh-my-zsh can't find plugins, initialize the submodules:

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

### Powerlevel10k not working

Run the configuration wizard:

```bash
p10k configure
```

## License

MIT

## Credits

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
