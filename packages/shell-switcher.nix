{ pkgs }:
pkgs.writeScriptBin "shell" ''
  #!/usr/bin/env bash

  # Shell switcher script for different development environments
  # Usage: shell <environment>
  # Available environments: web, python, tex, base

  shell() {
      local env="$1"
      local current_dir="$(pwd)"
      
      # Find cli directory using fd
      local config_dir=$(${pkgs.fd}/bin/fd -t d -H "cli" "$HOME/Dev" 2>/dev/null | while read dir; do
          if [[ -f "$dir/flake.nix" && -d "$dir/devshells" ]]; then
              echo "$dir"
              break
          fi
      done)
      
      if [[ -z "$config_dir" ]]; then
          echo "Error: Could not find cli directory with flake.nix"
          return 1
      fi
      
      case "$env" in
          "web")
              echo "🌐 Switching to web development shell..."
              ${pkgs.nix}/bin/nix develop "$config_dir#web"
              ;;
          "python")
              echo "🐍 Switching to Python development shell..."
              ${pkgs.nix}/bin/nix develop "$config_dir#python"
              ;;
          "tex")
              echo "📖 Switching to TeX development shell..."
              ${pkgs.nix}/bin/nix develop "$config_dir#tex"
              ;;
          "base"|"default")
              echo "⚡ Switching to base development shell..."
              ${pkgs.nix}/bin/nix develop "$config_dir"
              ;;
          "")
              echo "shell - Switch between development environments"
              echo ""
              echo "Usage: shell <environment>"
              echo ""
              echo "Available environments:"
              echo "  web     - Web development environment (Node.js, npm, TypeScript)"
              echo "  python  - Python development environment (Python 3, pip, pytest)"
              echo "  tex     - TeX/LaTeX development environment (texlive, pandoc)"
              echo "  base    - Base development environment (CLI tools only)"
              echo ""
              echo "Examples:"
              echo "  shell web      # Switch to web development"
              echo "  shell python   # Switch to Python development"
              echo "  shell tex      # Switch to LaTeX environment"
              echo "  shell base     # Switch to base CLI environment"
              ;;
          *)
              echo "Unknown environment: $env"
              echo "Available environments: web, python, tex, base"
              return 1
              ;;
      esac
  }

  # Execute the function
  shell "$@"
''
