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
