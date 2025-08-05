{
  inputs,
  pkgs,
  ...
}:
let
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
      git ls-files -z "$@" | grep --null '\.nix$' | while IFS= read -r -d "" file; do
        echo "Processing: $file"
        # 1. Remove dead code first (priority 1)
        deadnix --no-lambda-pattern-names --edit "$file" || true
        # 2. Fix linting issues (priority 2)  
        statix fix "$file" || true
        # 3. Format the file (priority 3)
        alejandra "$file"
      done
      
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
        
        if ! git diff --exit-code; then
          echo "-------------------------------"
          echo "aborting due to above changes ^"
          exit 1
        fi
        touch $out
      '';
in
formatter
// {
  passthru = formatter.passthru // {
    tests = {
      check = check;
    };
  };
}