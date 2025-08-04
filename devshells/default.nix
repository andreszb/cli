{ pkgs, self, ... }:
pkgs.mkShell {
  packages = with pkgs; [
    # Core utilities
    git
    neovim
    zsh
    coreutils
    
    # Nix tools
    alejandra
    
    # CLI tools
    claude-code
    
    # Custom blueprint packages
    self.copyssh
    self.mkcd
    self.shell-switcher
    self.cli-help
    
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
    # direnv (removed - conflicts with external direnv)
    
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
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    xclip
    wl-clipboard
  ];

  env = {
    EDITOR = "nvim";
    VISUAL = "nvim";
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

# === ALIASES ===
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias cat='bat'
alias grep='rg'
alias find='fd'

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
# Add common abbreviations (expand on space/enter)
abbr add g git
abbr add gs 'git status'
abbr add ga 'git add'
abbr add gc 'git commit'
abbr add gp 'git push'
abbr add gl 'git pull'
abbr add gd 'git diff'
abbr add gco 'git checkout'
abbr add gb 'git branch'
abbr add glog 'git log --oneline --graph --decorate'

# Docker abbreviations
abbr add d docker
abbr add dc 'docker compose'
abbr add dps 'docker ps'
abbr add di 'docker images'

# System abbreviations
abbr add ll 'eza -la --icons --git'
abbr add la 'eza -a --icons'
abbr add lt 'eza --tree --icons'
abbr add cls clear
abbr add .. 'cd ..'
abbr add ... 'cd ../..'

# Development abbreviations
abbr add nd 'nix develop'
abbr add nb 'nix build'
abbr add nf 'nix flake'
abbr add nfc 'nix flake check'
abbr add nfu 'nix flake update'

# === Auto-list files after cd ===
_list_files_after_cd() {
  local file_count=$(ls -1 2>/dev/null | wc -l)
  if [ $file_count -le 20 ]; then
    eza --icons --group-directories-first -t modified 2>/dev/null
  else
    eza --icons --group-directories-first -t modified 2>/dev/null | head -20
  fi
}

chpwd() {
  _list_files_after_cd
}

# === YAZI Function ===
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# === SSH Setup Function ===
copyssh() {
  local email="andreszb@me.com"
  local ssh_key_path="$HOME/.ssh/id_ed25519"
  local pub_key_path="$ssh_key_path.pub"

  echo "🔐 Setting up SSH key for GitHub..."
  echo "📧 Using email: $email"
  echo ""

  # Generate SSH key if it doesn't exist
  if [[ ! -f "$ssh_key_path" ]]; then
    echo "1️⃣  Generating SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path"
    echo "✅ SSH key generated"
  else
    echo "1️⃣  SSH key already exists at $ssh_key_path"
  fi

  # Start SSH agent
  echo "2️⃣  Starting SSH agent..."
  eval "$(ssh-agent -s)"

  # Add key to agent
  echo "3️⃣  Adding key to SSH agent..."
  ssh-add "$ssh_key_path"
  echo "📋 Keys in agent:"
  ssh-add -l
  echo ""

  # Copy public key to clipboard
  echo "4️⃣  Copying public key to clipboard..."
  if command -v pbcopy >/dev/null 2>&1; then
    cat "$pub_key_path" | pbcopy
    echo "✅ Public key copied to clipboard (macOS)"
  elif command -v xclip >/dev/null 2>&1; then
    cat "$pub_key_path" | xclip -selection clipboard
    echo "✅ Public key copied to clipboard (Linux)"
  else
    echo "📄 Public key content:"
    cat "$pub_key_path"
  fi
  echo ""

  # Set up commit signing
  echo "5️⃣  Setting up commit signing..."
  echo "$email $(cat $pub_key_path)" > ~/.ssh/allowed_signers
  git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
  echo "✅ Commit signing configured"
  echo ""

  # Instructions
  echo "🎯 Next steps:"
  echo "   1. Visit: https://github.com/settings/keys"
  echo "   2. Click 'New SSH key'"
  echo "   3. Paste the key from clipboard"
  echo "   4. Set key type to 'Authentication Key' and optionally 'Signing Key'"
  echo "   5. Test connection: ssh -T git@github.com"
}

# === Git Configuration ===
git config --global user.name "Andres Zambrano"
git config --global user.email "andreszb@me.com"
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global core.editor nvim
git config --global merge.tool nvim
git config --global diff.colorMoved default
git config --global gpg.format ssh
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Git aliases
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.lg "log --oneline --graph --decorate"
git config --global alias.undo "reset --soft HEAD^"

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