{ pkgs }:
''
  # === Custom Functions ===

  # === YAZI Function ===
  function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }

  # === Git Configuration ===
  # Configure git settings with error handling
  configure_git() {
    local configs=(
      "user.name 'Andres Zambrano'"
      "user.email 'andreszb@me.com'"
      "user.signingkey ~/.ssh/id_ed25519.pub"
      "init.defaultBranch main"
      "pull.rebase true"
      "push.autoSetupRemote true"
      "core.editor nvim"
      "merge.tool nvim"
      "diff.colorMoved default"
      "gpg.format ssh"
      "gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers"
      "commit.gpgsign true"
      "tag.gpgsign true"
      "alias.co checkout"
      "alias.ci commit"
      "alias.st status"
      "alias.br branch"
      "alias.lg 'log --oneline --graph --decorate'"
      "alias.undo 'reset --soft HEAD^'"
    )
    
    local failed_configs=0
    for config in "''${configs[@]}"; do
      if ! git config --global $config 2>/dev/null; then
        ((failed_configs++))
      fi
    done
    
    if [[ $failed_configs -gt 0 ]]; then
      echo "⚠️  Warning: Could not set $failed_configs git config settings (permission issues)" >&2
    fi
  }

  # Only configure git if we can write to the config file
  if [[ -w ~/.gitconfig ]] || [[ ! -f ~/.gitconfig ]]; then
    configure_git
  elif [[ -w ~/.config/git/config ]] || [[ ! -f ~/.config/git/config ]]; then
    mkdir -p ~/.config/git
    configure_git
  else
    echo "⚠️  Warning: Cannot write to git config files. Git configuration skipped." >&2
  fi
''
