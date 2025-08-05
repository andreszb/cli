{ pkgs }:
''
  # === ZSH Completion Configuration ===
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
''
