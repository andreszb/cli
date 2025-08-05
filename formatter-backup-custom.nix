{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      formatter = pkgs.writeShellApplication {
        name = "formatter";

        runtimeInputs = [
          pkgs.deadnix
          pkgs.statix
          pkgs.alejandra
          pkgs.nodePackages.prettier
          pkgs.git
        ];

        text = ''
          set -euo pipefail

          # If no arguments are passed, default to formatting the whole project
          if [[ $# = 0 ]]; then
            prj_root=$(git rev-parse --show-toplevel 2>/dev/null || echo .)
            set -- "$prj_root"
          fi

          echo "Formatting Nix files..."

          # Format Nix files with the pipeline: deadnix -> statix -> alejandra
          git ls-files -z "$@" | grep --null '\.nix$' | while IFS= read -r -d "" file; do
            echo "Processing: $file"
            # Remove dead code first
            deadnix --no-lambda-pattern-names --edit "$file" || true
            # Fix linting issues  
            statix fix "$file" || true
            # Format the file
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
    in
    {
      formatter = formatter;
    };
}
