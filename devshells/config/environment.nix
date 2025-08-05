{ pkgs }:
''
  # === Environment Variables ===
  export CONFIG_DIR="$HOME/.config/cli-shell-temp"
  export ZDOTDIR="$CONFIG_DIR/zsh"
  export OMP_CONFIG="$(pwd)/themes/oh-my-posh/theme.json"

  # Set up temporary config directory
  mkdir -p "$CONFIG_DIR/bat" "$CONFIG_DIR/zsh"
''
