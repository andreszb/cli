{
  inputs,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "formatter";

  runtimeInputs = [
    pkgs.deadnix  
    pkgs.nixfmt-rfc-style
  ];

  text = ''
    set -euo pipefail

    # If no arguments are passed, default to formatting the whole project
    if [[ $# = 0 ]]; then
      prj_root=$(git rev-parse --show-toplevel 2>/dev/null || echo .)
      set -- "$prj_root"
    fi

    set -x

    deadnix --no-lambda-pattern-names --edit "$@"

    # Use git to traverse since nixfmt doesn't have good traversal
    git ls-files -z "$@" | grep --null '\.nix$' | xargs --null --no-run-if-empty nixfmt
  '';

  meta = {
    description = "format your project";
  };
}