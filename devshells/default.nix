{ inputs, pkgs, perSystem, ... }:
pkgs.mkShell {
  packages =
    with pkgs;
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

  shellHook = ''
        echo "🚀 Blueprint CLI environment loaded!"
        echo "📦 All tools configured and ready!"
        echo ""
        
        # Set up temporary config directory
        export CONFIG_DIR="$HOME/.config/cli-shell-temp"
        mkdir -p "$CONFIG_DIR/bat" "$CONFIG_DIR/zsh"
        
        # === BAT Configuration ===
        cat > "$CONFIG_DIR/bat/config" << 'EOF'
    --pager='less -FR'
    --theme=TwoDark
    --style=numbers,changes,header,grid
    --color=always
    EOF
        export BAT_CONFIG_PATH="$CONFIG_DIR/bat/config"
        
        # === Environment Variables ===
        export ZDOTDIR="$CONFIG_DIR/zsh"
        export OMP_CONFIG="$(pwd)/themes/oh-my-posh/theme.json"
        
        # === ZSH Configuration ===
        cat > "$CONFIG_DIR/zsh/.zshrc" << 'EOF'
    # History configuration
    HISTSIZE=10000
    SAVEHIST=10000
    HISTFILE="$CONFIG_DIR/zsh/.zsh_history"
    setopt HIST_FCNTL_LOCK
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt SHARE_HISTORY
    setopt HIST_FIND_NO_DUPS
    setopt autocd
    setopt globdots

    # Load zsh plugins
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh

    # Autosuggestion configuration
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

    # zsh-autocomplete configuration
    zstyle ':autocomplete:*' min-input 1
    zstyle ':autocomplete:*' delay 0.1
    zstyle ':autocomplete:*' async yes
    zstyle ':autocomplete:*' list-lines 10
    zstyle ':autocomplete:*' recent-dirs cdr
    zstyle ':autocomplete:*' add-space executables
    zstyle ':autocomplete:*' default-context ""
    zstyle ':autocomplete:*' completion-word-wrap yes

    # Tab completion configuration
    zstyle ':autocomplete:tab:*' insert-unambiguous yes
    zstyle ':autocomplete:tab:*' widget-style menu-select
    zstyle ':autocomplete:tab:*' fzf-completion yes

    # fzf-tab configuration
    zstyle ':fzf-tab:complete:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:zi:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath 2>/dev/null'
    zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
    zstyle ':fzf-tab:*' switch-group ',' '.'

    # zoxide integration with zsh-autocomplete
    zstyle ':autocomplete:*' ignored-input 'z ##'
    zstyle ':autocomplete:*' ignored-input 'zi ##'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath 2>/dev/null'


    # === FZF Configuration ===
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --ansi --multi --preview-window=right:60% --preview="bat --color=always --style=numbers --line-range=:500 {}" --bind=ctrl-u:preview-page-up --bind=ctrl-d:preview-page-down --bind=ctrl-f:preview-page-down --bind=ctrl-b:preview-page-up --color=fg:#d0d0d0,bg:#121212,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

    # Load fzf keybindings and completion
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    source ${pkgs.fzf}/share/fzf/completion.zsh

    # === OH-MY-POSH ===
    eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config $OMP_CONFIG)"

    # === ZOXIDE ===
    eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"

    # === DIRENV ===
    # Disabled - direnv is handled externally via .envrc

    # === ZSH ABBREVIATIONS ===
    # Add common abbreviations (expand on space/enter) - suppress duplicate warnings
    abbr add "g=git" 2>/dev/null
    abbr add "gs=git status" 2>/dev/null
    abbr add "ga=git add" 2>/dev/null
    abbr add "gc=git commit" 2>/dev/null
    abbr add "gp=git push" 2>/dev/null
    abbr add "gl=git pull" 2>/dev/null
    abbr add "gd=git diff" 2>/dev/null
    abbr add "gco=git checkout" 2>/dev/null
    abbr add "gb=git branch" 2>/dev/null
    abbr add "glog=git log --oneline --graph --decorate" 2>/dev/null

    # Docker abbreviations
    abbr add "d=docker" 2>/dev/null
    abbr add "dc=docker compose" 2>/dev/null
    abbr add "dps=docker ps" 2>/dev/null
    abbr add "di=docker images" 2>/dev/null

    # System abbreviations
    abbr add "ls=eza --icons" 2>/dev/null
    abbr add "ll=eza -la --icons --git" 2>/dev/null
    abbr add "la=eza -a --icons" 2>/dev/null
    abbr add "lt=eza --tree --icons" 2>/dev/null
    abbr add "cls=clear" 2>/dev/null
    abbr add "..=cd .." 2>/dev/null
    abbr add "...=cd ../.." 2>/dev/null

    # Editor abbreviations
    abbr add "v=nixCats" 2>/dev/null
    abbr add "vi=nixCats" 2>/dev/null
    abbr add "vim=nixCats" 2>/dev/null
    abbr add "nvim=nixCats" 2>/dev/null

    # Tool abbreviations
    abbr add "cat=bat" 2>/dev/null
    abbr add "grep=rg" 2>/dev/null
    abbr add "find=fd" 2>/dev/null

    # Development abbreviations
    abbr add "nd=nix develop" 2>/dev/null
    abbr add "nb=nix build" 2>/dev/null
    abbr add "nf=nix flake" 2>/dev/null
    abbr add "nfc=nix flake check" 2>/dev/null
    abbr add "nfu=nix flake update" 2>/dev/null


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

    echo "💡 Available commands:"
    echo "   • copyssh   - Set up SSH keys for GitHub"
    echo "   • mkcd      - Create directory and cd into it"
    echo "   • shell     - Switch development environments"
    echo "   • cli-help  - Show detailed help for all commands"
    echo "   • yy        - Enhanced yazi file manager"
    echo ""
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
