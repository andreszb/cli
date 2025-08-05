{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          # Nix formatters and linters (matching numtide/nits priorities)
          deadnix = {
            enable = true;
            priority = 1;
          };
          statix = {
            enable = true;
            priority = 2;
          };
          alejandra = {
            enable = true;
            priority = 3;
          };
          # Multi-language formatter for JSON, Markdown, etc.
          prettier.enable = true;
        };
        settings = {
          global = {
            excludes = [
              # Build outputs and generated files
              "*.lock"
              "result*"
              ".direnv/"

              # Version control
              ".git/"

              # Temporary and cache files
              "*.tmp"
              "*.temp"

              # OS-specific files
              ".DS_Store"
              "Thumbs.db"
            ];
          };
          # Configure prettier to only handle specific file types
          formatter.prettier = {
            includes = [
              "*.json"
              "*.md"
              "*.yaml"
              "*.yml"
            ];
          };
        };
      };
    };
}
