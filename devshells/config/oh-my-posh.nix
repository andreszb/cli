{ pkgs }:
''
  # === OH-MY-POSH ===
  eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config $OMP_CONFIG)"

  # === ZOXIDE ===
  eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"

  # === DIRENV ===
  # Disabled - direnv is handled externally via .envrc

  echo "💡 Available commands:"
  echo "   • copyssh   - Set up SSH keys for GitHub"
  echo "   • mkcd      - Create directory and cd into it"
  echo "   • shell     - Switch development environments"
  echo "   • cli-help  - Show detailed help for all commands"
  echo "   • yy        - Enhanced yazi file manager"
  echo ""
''
