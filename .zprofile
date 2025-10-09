# Homebrew setup - works on both Intel and Silicon Macs
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  # Intel
  eval "$(/usr/local/bin/brew shellenv)"
fi
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"



# Created by `pipx` on 2025-08-12 05:10:40
export PATH="$PATH:/Users/csc-r169/.local/bin"

# Created by `pipx` on 2025-10-03 14:42:06
export PATH="$PATH:/Users/taikoeda/.local/bin"
