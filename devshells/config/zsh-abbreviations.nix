{pkgs}: ''
  # === ZSH ABBREVIATIONS ===
  # Add common abbreviations (expand on space/enter) - suppress duplicate warnings

  # Git abbreviations
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
''
