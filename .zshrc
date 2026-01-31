# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

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
# Agent Mode Detection
# -----------------------------------------------------------------------------
# Detect if running in agent/CI mode for minimal configuration
if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
  export AGENT_MODE=true
else
  export AGENT_MODE=false
fi

# Agent-specific non-interactive settings
if [[ "$AGENT_MODE" == "true" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
fi

# -----------------------------------------------------------------------------
# Oh My Zsh Configuration
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/custom"
export DEFAULT_USER=$USER

# Theme selection based on mode
if [[ "$AGENT_MODE" != "true" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME=""
fi

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

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# General aliases
alias g='git'
alias v='nvim'

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
fi

# macOS-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  # CloudFastener Dev Commands
  alias cf-connect='/Users/csc-r169/Documents/code/repos/cf/cloudfastener-dev-tools/cf-connect/cf-connect'
fi

# -----------------------------------------------------------------------------
# Mode-Specific Configuration
# -----------------------------------------------------------------------------
if [[ "$AGENT_MODE" != "true" ]]; then
  # Interactive mode - Load Powerlevel10k config
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # Custom color scheme (commented out - uncomment to use)
  # zstyle :prompt:pure:path color 183                    # Brighter purple for paths
  # zstyle :prompt:pure:git:branch color 13               # Hot magenta for branches
  # zstyle :prompt:pure:git:branch:cached color 54        # Deep purple for cached
  # zstyle :prompt:pure:git:action color 208              # Bright orange for actions
  # zstyle :prompt:pure:git:dirty color 13                # Hot pink for dirty status
  # zstyle :prompt:pure:host color 51                     # Electric cyan for host
  # zstyle :prompt:pure:user color 141                    # Vibrant purple for user
  # zstyle :prompt:pure:user:root color 196               # Bright red for root
  # zstyle :prompt:pure:virtualenv color 226              # Bright yellow for virtualenv
  # zstyle :prompt:pure:execution_time color 176          # Soft pink for timing
  # zstyle :prompt:pure:prompt:success color 13           # Hot magenta/pink for success arrow
  # zstyle :prompt:pure:prompt:error color 196            # Bright red for error arrow

else
  # Agent mode - Minimal configuration
  PROMPT='%n@%m:%~%# '
  RPROMPT=''

  # Disable corrections and beeps
  unsetopt CORRECT
  unsetopt CORRECT_ALL
  setopt NO_BEEP
  setopt NO_HIST_BEEP
  setopt NO_LIST_BEEP

  # Agent-friendly aliases (non-interactive)
  alias rm='rm -f'
  alias cp='cp -f'
  alias mv='mv -f'
  alias npm='npm --no-fund --no-audit'
  alias yarn='yarn --non-interactive'
  alias pip='pip --quiet'
  alias git='git -c advice.detachedHead=false'
fi


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
