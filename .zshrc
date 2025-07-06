# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
if [[ "$AGENT_MODE" != "true" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME=""
fi
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

if [[ "$AGENT_MODE" != "true" ]]; then
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # # More vibrant Aura Dracula Spirit colors
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
  # zstyle :prompt:pure:prompt:success color 13            # Hot magenta/pink for success arrow
  # zstyle :prompt:pure:prompt:error color 196             # Bright red for error arrow
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
