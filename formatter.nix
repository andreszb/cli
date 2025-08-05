{
  inputs,
  pkgs,
  ...
}: let
  pname = "formatter";
  # Use inputs.self for the flake reference
  flake = inputs.self or ./.;

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

      set -x

      echo "Formatting Nix files..."

      # Format Nix files with priority pipeline: deadnix -> statix -> alejandra
      # Use process substitution to avoid subshell issues
      while IFS= read -r -d "" file; do
        echo "Processing: $file"
        # 1. Remove dead code first (priority 1)
        deadnix --no-lambda-pattern-names --edit "$file" || true
        # 2. Fix linting issues (priority 2)
        statix fix "$file" || true
        # 3. Format the file (priority 3)
        alejandra "$file"
      done < <(git ls-files -z "$@" | grep -z '\.nix$')

      echo "Formatting other files (JSON, Markdown, YAML)..."

      # Format other supported files with prettier
      prettier --write \
        "**/*.{json,md,yaml,yml}" \
        --ignore-path /dev/null \
        --log-level warn || true

      echo "Formatting complete!"
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
