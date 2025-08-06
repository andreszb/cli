{pkgs}: ''
  # === ZSH Basic Configuration ===
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
  # Temporarily disabled due to shell abort issues: source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
  source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
  source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh

  # Autosuggestion configuration
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
''
