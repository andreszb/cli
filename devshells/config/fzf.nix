{pkgs}: ''
  # === FZF Configuration ===
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --ansi --multi --preview-window=right:60% --preview="bat --color=always --style=numbers --line-range=:500 {}" --bind=ctrl-u:preview-page-up --bind=ctrl-d:preview-page-down --bind=ctrl-f:preview-page-down --bind=ctrl-b:preview-page-up --color=fg:#d0d0d0,bg:#121212,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

  # Load fzf keybindings and completion
  source ${pkgs.fzf}/share/fzf/key-bindings.zsh
  source ${pkgs.fzf}/share/fzf/completion.zsh
''
