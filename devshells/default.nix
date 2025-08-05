{
  inputs,
  pkgs,
  perSystem,
  ...
}:
pkgs.mkShell {
  packages = with pkgs;
    [
      # Core utilities
      git
      inputs.nvim-config.packages.${pkgs.system}.default
      zsh
      coreutils

      # CLI tools
      claude-code

      # Custom blueprint packages
      perSystem.self.copyssh
      perSystem.self.mkcd
      perSystem.self.shell-switcher
      perSystem.self.cli-help

      # File management
      bat
      eza
      fd
      ripgrep
      fzf
      yazi

      # System tools
      btop
      procs
      zoxide

      # Network tools
      httpie
      openssh

      # Development tools
      jq
      delta

      # Documentation
      tldr
      neofetch

      # Archive tools
      zip
      unzip

      # Shell plugins
      zsh-syntax-highlighting
      zsh-autosuggestions
      zsh-autocomplete
      zsh-fzf-tab
      zsh-abbr

      # Prompt
      oh-my-posh

      # Platform-specific
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      xclip
      wl-clipboard
    ];

  env = {
    EDITOR = "nixCats";
    VISUAL = "nixCats";
    PAGER = "bat";
  };

  shellHook = let
    # Import configuration modules
    environmentConfig = import ./config/environment.nix {inherit pkgs;};
    batConfig = import ./config/bat.nix {inherit pkgs;};
    zshPluginsConfig = import ./config/zsh-plugins.nix {inherit pkgs;};
    zshCompletionConfig = import ./config/zsh-completion.nix {inherit pkgs;};
    fzfConfig = import ./config/fzf.nix {inherit pkgs;};
    zshAbbreviationsConfig = import ./config/zsh-abbreviations.nix {inherit pkgs;};
    zshFunctionsConfig = import ./config/zsh-functions.nix {inherit pkgs;};
    ohMyPoshConfig = import ./config/oh-my-posh.nix {inherit pkgs;};
  in ''
          echo "🚀 Blueprint CLI environment loaded!"
          echo "📦 All tools configured and ready!"
          echo ""

          ${environmentConfig}
          ${batConfig}

          # === ZSH Configuration ===
          cat > "$CONFIG_DIR/zsh/.zshrc" << 'EOF'
    ${zshPluginsConfig}

    ${zshCompletionConfig}

    ${fzfConfig}

    ${zshAbbreviationsConfig}

    ${zshFunctionsConfig}

    ${ohMyPoshConfig}
    EOF

          # Initialize oh-my-posh before starting zsh
          echo "🎨 Initializing oh-my-posh theme..."

          # Verify theme file exists
          if [[ -f "$OMP_CONFIG" ]]; then
            echo "✅ Theme file found: $OMP_CONFIG"
          else
            echo "❌ Theme file not found: $OMP_CONFIG"
            echo "📁 Available themes:"
            ls -la ${../themes/oh-my-posh}/ || echo "No themes directory found"
          fi

          # Load the zsh configuration and start zsh
          exec ${pkgs.zsh}/bin/zsh
  '';
}
