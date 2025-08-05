{pkgs}:
pkgs.writeScriptBin "cli-help" ''
  #!/usr/bin/env bash

  # CLI Config Help Script
  # Shows available commands in the blueprint CLI environment

  cli-help() {
      echo "Blueprint CLI Environment - Available Commands"
      echo "============================================="

      # Get terminal width, default to 80 if not available
      local term_width=''${COLUMNS:-$(${pkgs.ncurses}/bin/tput cols 2>/dev/null || echo 80)}

      # Calculate column widths dynamically
      local min_cmd_width=12
      local min_desc_width=20
      local min_example_width=15
      local padding=6  # 2 spaces between each column

      # Available width for content (excluding padding)
      local available_width=$((term_width - padding))

      # Calculate optimal column widths (proportional allocation)
      local cmd_width=$((available_width * 25 / 100))    # 25% for command
      local desc_width=$((available_width * 50 / 100))   # 50% for description
      local example_width=$((available_width * 25 / 100)) # 25% for example

      # Ensure minimum widths
      cmd_width=$((cmd_width < min_cmd_width ? min_cmd_width : cmd_width))
      desc_width=$((desc_width < min_desc_width ? min_desc_width : desc_width))
      example_width=$((example_width < min_example_width ? min_example_width : example_width))

      # Adjust if total width exceeds terminal width
      local total_width=$((cmd_width + desc_width + example_width + padding))
      if [[ $total_width -gt $term_width ]]; then
          # Reduce description width first, then example width
          local excess=$((total_width - term_width))
          if [[ $excess -le $((desc_width - min_desc_width)) ]]; then
              desc_width=$((desc_width - excess))
          else
              desc_width=$min_desc_width
              example_width=$((example_width - (excess - (desc_width - min_desc_width))))
              example_width=$((example_width < min_example_width ? min_example_width : example_width))
          fi
      fi

      # Create format strings
      local header_format="%-''${cmd_width}s  %-''${desc_width}s  %-''${example_width}s\n"
      local row_format="%-''${cmd_width}s  %-''${desc_width}.''${desc_width}s  %-''${example_width}.''${example_width}s\n"

      # Print table header
      printf "$header_format" "COMMAND" "DESCRIPTION" "EXAMPLE"
      printf "$header_format" "$(printf '%*s' $cmd_width | tr ' ' '-')" "$(printf '%*s' $desc_width | tr ' ' '-')" "$(printf '%*s' $example_width | tr ' ' '-')"

      # Define commands and their info
      printf "$row_format" "copyssh" "Setup SSH keys for GitHub" "copyssh"
      printf "$row_format" "mkcd" "Create directory and cd into it" "mkcd my-project"
      printf "$row_format" "shell" "Switch development environments" "shell python"
      printf "$row_format" "yy" "Enhanced yazi file manager" "yy /path/to/dir"
      printf "$row_format" "abbr" "Manage zsh abbreviations" "abbr list"
      printf "$row_format" "cli-help" "Show this help message" "cli-help"

      echo ""
      echo "Development Environment Switching:"
      echo "  shell web      - Node.js/TypeScript development"
      echo "  shell python   - Python development with tools"
      echo "  shell tex      - LaTeX/document preparation"
      echo "  shell base     - Basic CLI tools only"
      echo ""
      echo "Abbreviations (type + space to expand):"
      echo "  gs → git status    gp → git push     nd → nix develop"
      echo "  ga → git add       gl → git pull     nb → nix build"
      echo "  gc → git commit    d → docker        nf → nix flake"
      echo ""
      echo "Usage: Run any command name from anywhere in your system"
      echo "For detailed help on any command, use: <command> --help"
  }

  # Execute the function
  cli-help "$@"
''
