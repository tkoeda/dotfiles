zmodload zsh/zprof

# Agent detection - only activate minimal mode for actual agents
if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
  export AGENT_MODE=true
else
  export AGENT_MODE=false
fi

# Agent-specific configuration (no Powerlevel10k stuff needed)
if [[ "$AGENT_MODE" == "true" ]]; then
  # Ensure non-interactive mode
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/dotfiles/custom"

# Hide username when you're the default user (BEFORE sourcing Oh My Zsh)
export DEFAULT_USER=$USER

# Set Oh My Zsh theme conditionally (BEFORE sourcing Oh My Zsh)
ZSH_THEME=""

plugins=(
zsh-shift-select
zsh-autosuggestions
zsh-you-should-use
)

# Source Oh My Zsh (theme and plugins get loaded here)
source $ZSH/oh-my-zsh.sh

# Post Oh My Zsh configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

alias g=git
alias v='nvim'

# Oh My Posh configuration (only for interactive sessions)
if [[ "$AGENT_MODE" != "true" ]]; then
  # Initialize Oh My Posh with custom Pure theme (no username, transient prompt enabled)
  eval "$(oh-my-posh init zsh --config $HOME/dotfiles/custom/pure.omp.json)"
else
  # Agent-specific minimal prompt
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  unsetopt CORRECT
  unsetopt CORRECT_ALL
  setopt NO_BEEP
  setopt NO_HIST_BEEP
  setopt NO_LIST_BEEP

  # Agent-friendly aliases to avoid interactive prompts
  alias rm='rm -f'
  alias cp='cp -f'
  alias mv='mv -f'
  alias npm='npm --no-fund --no-audit'
  alias yarn='yarn --non-interactive'
  alias pip='pip --quiet'
  alias git='git -c advice.detachedHead=false'
fi

# Source zsh-syntax-highlighting after Oh My Zsh (required for proper highlighting)
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
