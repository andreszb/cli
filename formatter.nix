{
  pname,
  pkgs,
  flake,
}: let
  formatter = pkgs.writeShellApplication {
    name = pname;

    runtimeInputs = [
      pkgs.deadnix
      pkgs.statix
      pkgs.alejandra
      pkgs.nodePackages.prettier
    ];

    text = ''
      set -euo pipefail

      # If no arguments are passed, default to formatting the whole project
      if [[ $# = 0 ]]; then
        prj_root=$(git rev-parse --show-toplevel 2>/dev/null || echo .)
        set -- "$prj_root"
      fi

      echo "🔍 Checking Nix files for formatting issues..."

      # Track files that were actually changed
      files_changed=0
      total_files=0

      # Format Nix files with priority pipeline: deadnix -> statix -> alejandra
      # Use process substitution to avoid subshell issues
      while IFS= read -r -d "" file; do
        total_files=$((total_files + 1))

        # Create backup to detect changes
        cp "$file" "$file.backup"

        # 1. Remove dead code first (priority 1)
        deadnix_output=$(deadnix --no-lambda-pattern-names --edit "$file" 2>&1 || true)

        # 2. Fix linting issues (priority 2)
        statix fix "$file" >/dev/null 2>&1 || true

        # 3. Format the file (priority 3) - suppress success messages
        alejandra "$file" >/dev/null 2>&1

        # Check if file was actually changed
        if ! diff -q "$file" "$file.backup" >/dev/null 2>&1; then
          files_changed=$((files_changed + 1))
          echo "✏️  Formatted: $file"

          # Show deadnix warnings if any unused code was found
          if echo "$deadnix_output" | grep -q "Warning:"; then
            echo "$deadnix_output" | grep -A 10 "Warning:" || true
          fi
        fi

        # Clean up backup
        rm -f "$file.backup"
      done < <(git ls-files -z "$@" | grep -z '\.nix$')

      # Format other supported files with prettier (only show if changes made)
      echo "🔍 Checking other files (JSON, Markdown, YAML)..."
      prettier_output=$(prettier --write \
        "**/*.{json,md,yaml,yml}" \
        --ignore-path /dev/null \
        --log-level warn 2>&1 || true)

      # Show prettier output only if files were changed
      if echo "$prettier_output" | grep -q "\."; then
        echo "✏️  Prettier formatted files:"
        echo "$prettier_output" | grep -E "\.(json|md|yaml|yml)$" || true
      fi

      # Summary
      echo ""
      if [ "$files_changed" -gt 0 ]; then
        echo "✅ Formatting complete! Modified $files_changed out of $total_files Nix files."
      else
        echo "✅ All files already properly formatted! Checked $total_files Nix files."
      fi
    '';

    meta = {
      description = "Format project files with deadnix, statix, alejandra, and prettier";
    };
  };

  check =
    pkgs.runCommand "format-check"
    {
      nativeBuildInputs = [
        formatter
        pkgs.git
        pkgs.delta
      ];
    }
    ''
      export HOME=$NIX_BUILD_TOP/home

      # keep timestamps so that treefmt is able to detect mtime changes
      cp --no-preserve=mode --preserve=timestamps -r ${flake} source
      cd source
      git init --quiet
      git add .

      # Run formatter on the entire project (matches our formatter behavior)
      ${pname}

      if ! git diff --exit-code --quiet; then
        echo ""
        echo "❌ Format check failed: Files need formatting"
        echo ""
        echo "📊 Changes that would be made:"
        echo "================================"

        # Configure delta for better formatting diffs
        export DELTA_FEATURES="+side-by-side +line-numbers +decorations"
        export DELTA_SIDE_BY_SIDE=true
        export DELTA_LINE_NUMBERS=true
        export DELTA_DECORATIONS=true

        # Show beautiful diff with delta
        git diff | delta --width=120 --max-line-length=0 || git diff

        echo ""
        echo "================================"
        echo "🔧 To fix: run 'nix fmt' in your project"
        echo "❌ Aborting due to formatting issues"
        exit 1
      fi
      touch $out
    '';
in
  formatter
  // {
    passthru =
      formatter.passthru
      // {
        tests = {
          inherit check;
        };
      };
  }
