{pkgs}:
pkgs.writeScriptBin "mkcd" ''
  #!/usr/bin/env zsh

  mkcd() {
    # Handle --help option
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      echo "mkcd - Create directory and change into it"
      echo ""
      echo "DESCRIPTION:"
      echo "  Creates a directory (including parent directories if needed) and"
      echo "  immediately changes into it. This combines the common pattern of"
      echo "  'mkdir -p <dir> && cd <dir>' into a single command."
      echo ""
      echo "USAGE:"
      echo "  mkcd <directory>   # Create directory and cd into it"
      echo "  mkcd --help       # Show this help message"
      echo ""
      echo "EXAMPLES:"
      echo "  mkcd my-project              # Create and enter 'my-project'"
      echo "  mkcd path/to/deep/folder     # Create nested path and enter it"
      echo "  mkcd \"folder with spaces\"    # Create directory with spaces"
      echo ""
      echo "OPTIONS:"
      echo "  The directory path supports all mkdir -p functionality:"
      echo "  • Creates parent directories as needed"
      echo "  • No error if directory already exists"
      echo "  • Supports relative and absolute paths"
      echo ""
      echo "NOTES:"
      echo "  • Uses 'mkdir -p' internally for safe directory creation"
      echo "  • Only changes directory if mkdir succeeds"
      echo "  • Directory name is required (no default behavior)"
      return 0
    fi

    # Check if directory argument is provided
    if [[ -z "$1" ]]; then
      echo "Error: Directory name required"
      echo "Usage: mkcd <directory>"
      echo "Use 'mkcd --help' for more information"
      return 1
    fi

    # Create directory and change into it
    mkdir -p "$1" && cd "$1"
  }

  # Execute the function
  mkcd "$@"
''
