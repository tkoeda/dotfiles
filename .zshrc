# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Non-interactive early exit (industry standard)
# -----------------------------------------------------------------------------
# Scripts, CI, and agent tools (Claude Code, etc.) run non-interactive shells.
# Nothing below this point is needed — exit before Oh My Zsh and plugins load.
# PATH and pyenv are set here first so non-interactive callers can find Python.
if [[ "$-" != *i* ]]; then
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
  # PATH setup for non-interactive callers
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv &> /dev/null; then
      eval "$(pyenv init - zsh)"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv &> /dev/null; then
      eval "$(pyenv init - zsh)"
    fi
  fi
  return
fi

# -----------------------------------------------------------------------------
# Powerlevel10k Instant Prompt
# -----------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# Performance & Debugging
# -----------------------------------------------------------------------------
# zmodload zsh/zprof  # Uncomment to profile startup time

# -----------------------------------------------------------------------------
# Oh My Zsh Configuration
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/custom"
export DEFAULT_USER=$USER

ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  zsh-shift-select
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-you-should-use
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# Environment Variables & PATH
# -----------------------------------------------------------------------------
# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  # Homebrew - detect architecture
  if [[ $(uname -m) == "arm64" ]]; then
    # M2/M3 Mac
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
    export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
  else
    # Intel Mac
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  fi

  # Python (pyenv)
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux / WSL
  # Add .local/bin for user-installed tools (zoxide, eza, etc.)
  export PATH="$HOME/.local/bin:$PATH"

  # Python (pyenv)
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
fi

# -----------------------------------------------------------------------------
# Tool Initialization
# -----------------------------------------------------------------------------
# Initialize tools if available
if command -v pyenv &> /dev/null; then
  eval "$(pyenv init - zsh)"
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# General aliases
alias c='claude'
alias g='git'
alias v='nvim'
git-pull-all() {
    # If you don't provide a number, it defaults to 3
    local depth="${1:-3}"

    find . -maxdepth "$depth" -name ".git" -type d -execdir bash -c 'echo -e "\033[0;32m--- Updating $(basename "$PWD") ---\033[0m"; git pull' \;
}


# Conditional aliases based on tool availability
if command -v zoxide &> /dev/null; then
  alias cd='z'
  alias zz='z -'
fi

# File listing (eza) - only if available
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
  alias lt='eza --tree'
  alias lg='eza -l --git'
  alias lh='eza -l --header'
  alias lm='eza -l --sort=modified'
  alias lsize='eza -l --sort=size'
  alias lga='eza -la --git'
  alias ltr='eza -l --sort=modified --reverse'

  # Tree views
  alias tree='eza --tree'
  alias tree2='eza --tree --level=2'
  alias tree3='eza --tree --level=3'

  # More detailed views
  alias llg='eza -l --group'
  alias lla='eza -l --all --group'
  alias llf='eza -l --group --git --header'
  alias lll='eza -l --group --links'
  alias llt='eza -l --group --time-style=long-iso'
  alias llx='eza -l --group --extended'
  alias l='eza -lh --git --group-directories-first'
fi

# macOS-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  # CloudFastener Dev Commands
  alias cf-connect='/Users/csc-r169/Documents/code/repos/cf/tools/cloudfastener-dev-tools/cf-connect/cf-connect'
fi

# -----------------------------------------------------------------------------
# Powerlevel10k Configuration
# -----------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# -----------------------------------------------------------------------------
# NVM Configuration (cross-platform, lazy-loaded)
# -----------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"

# Lazy load NVM to speed up shell startup
_load_nvm() {
  unset -f nvm node npm npx pnpm yarn _load_nvm

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (Homebrew-installed NVM) - M1/M2/M3
    if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
      \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    # Intel Mac fallback
    elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
      \. "/usr/local/opt/nvm/nvm.sh"
      [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
    fi
  else
    # Linux/WSL (manual install)
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  fi
}

nvm() { _load_nvm && nvm "$@"; }
node() { _load_nvm && node "$@"; }
npm() { _load_nvm && npm "$@"; }
npx() { _load_nvm && npx "$@"; }
pnpm() { _load_nvm && pnpm "$@"; }
yarn() { _load_nvm && yarn "$@"; }

# -----------------------------------------------------------------------------
# Local Configuration (optional)
# -----------------------------------------------------------------------------
# Load local configuration if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Zoxide must be initialized last
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
