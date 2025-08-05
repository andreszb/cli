# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a blueprint-based Nix flake that provides a comprehensive CLI development environment with multiple specialized shells. The architecture migrated from a dual nix development shell + home-manager configuration to a pure blueprint-only setup.

The flake integrates custom CLI tools as blueprint packages and provides a consistent development experience across multiple platforms (Linux x86_64/aarch64, macOS x86_64/aarch64).

## Architecture

### Blueprint Structure

The project follows numtide/blueprint conventions with a flat, modular structure:

- `flake.nix` - Minimal blueprint configuration with unfree packages enabled
- `devshells/` - Development environment definitions (maps to `devShells.*` outputs)
- `packages/` - Custom CLI utilities as blueprint packages (maps to `packages.*` outputs)
- `themes/` - Configuration files (oh-my-posh theme)

### Development Environments

Four specialized development shells are available:

- **default** (`nix develop`) - Full CLI environment with 35+ tools, zsh configuration, oh-my-posh theme, abbreviations
- **python** (`nix develop .#python`) - Python development with extensive package ecosystem
- **web** (`nix develop .#web`) - Node.js/TypeScript development environment
- **tex** (`nix develop .#tex`) - LaTeX/document preparation environment

### Custom Packages Architecture

Custom CLI utilities are implemented as blueprint packages using `pkgs.writeScriptBin`:

- `packages/copyssh/` - SSH key generation and GitHub setup automation
- `packages/mkcd/` - Directory creation and navigation utility
- `packages/shell-switcher/` - Development environment switching tool
- `packages/cli-help/` - Comprehensive help system

Each package is self-contained with proper Nix store path references and comprehensive help documentation.

### Shell Configuration Strategy

Instead of home-manager, all tool configurations are embedded directly in the devshell's `shellHook` using a temporary configuration approach:

- Configurations written to `$HOME/.config/cli-shell-temp/`
- Tools configured via environment variables and temporary config files
- Zsh configuration includes plugins, abbreviations, functions, and git setup
- Oh-my-posh theme integration with custom theme file

## Common Commands

### Development Shell Usage

```bash
nix develop                    # Enter default CLI environment
nix develop .#python          # Enter Python development environment
nix develop .#web             # Enter web development environment
nix develop .#tex             # Enter LaTeX environment
```

### Package Management

```bash
nix build .#copyssh           # Build individual package
nix run .#mkcd -- my-folder   # Run package directly
nix flake show                # List all available outputs
nix flake check               # Validate flake configuration
```

### Code Formatting

```bash
nix fmt                       # Format all files (deadnix → statix → alejandra → prettier)
nix fmt file.nix             # Format specific file
nix flake check              # Validate configuration (includes formatting check)
```

### Custom CLI Tools (Available in all devshells)

```bash
copyssh                       # Setup SSH keys for GitHub
mkcd project-name             # Create directory and cd into it
shell python                  # Switch to Python development shell
cli-help                      # Show comprehensive help for all tools
```

### Abbreviations (Auto-expand in zsh)

```bash
gs → git status     gp → git push      nd → nix develop
ga → git add        gl → git pull      nb → nix build
gc → git commit     d → docker         nf → nix flake
```

## Configuration Management

### Adding New Packages to Devshells

Packages are added directly to the `packages` list in each devshell file:

```nix
packages = with pkgs; [
  # Add new package here
  new-package
];
```

### Creating New Blueprint Packages

1. Create directory: `packages/package-name/`
2. Add `default.nix` with `pkgs.writeScriptBin` pattern
3. Include package in devshells: `(import ../packages/package-name { inherit pkgs; })`

### Modifying Shell Configuration

Shell configurations are embedded in the `shellHook` heredoc within each devshell's `.zshrc` section. Key areas:

- Plugin loading and configuration
- Abbreviation definitions (`abbr add` commands)
- Tool-specific environment variables and initialization
- Custom functions (yy, copyssh, etc.)

### Theme Customization

Oh-my-posh theme is configured in `themes/oh-my-posh/theme.json` and referenced by all devshells via `OMP_CONFIG` environment variable.

## Important Implementation Details

### Direnv Integration

The project uses external direnv (via `.envrc`) to auto-load the development shell. Internal direnv is disabled in devshells to prevent infinite loops.

### Unfree Package Support

The flake is configured to allow unfree packages (`nixpkgs.config.allowUnfree = true`) to support packages like `zsh-abbr`.

### Cross-Platform Compatibility

Platform-specific packages are conditionally included using `pkgs.lib.optionals pkgs.stdenv.isLinux` for Linux-only tools like `xclip`.

### Package Path Resolution

All custom packages use proper Nix store paths (e.g., `${pkgs.git}/bin/git`) rather than hardcoded system paths to ensure reproducibility.

### Shell Plugin Architecture

Zsh plugins are loaded directly from Nix store paths with proper configuration for:

- `zsh-syntax-highlighting` - Syntax highlighting
- `zsh-autosuggestions` - Command suggestions
- `zsh-autocomplete` - Live completion
- `zsh-fzf-tab` - Enhanced tab completion with fzf
- `zsh-abbr` - Shell abbreviations (unfree package)

The configuration ensures plugins work together without conflicts and provides extensive customization for completion behavior, styling, and integration.

## Code Formatting and Quality

### Formatter Architecture

The project uses a custom Blueprint-compatible formatter that orchestrates multiple formatting tools in a priority-based pipeline. The formatter is implemented as a `writeShellApplication` in `formatter.nix` and integrates seamlessly with Blueprint's automatic discovery system.

### Formatting Tools Pipeline

The formatter runs tools in a specific priority order for optimal results:

1. **deadnix** (Priority 1) - Removes unused Nix code and variables
2. **statix** (Priority 2) - Nix linter that detects antipatterns and enforces best practices
3. **alejandra** (Priority 3) - Nix code formatter for consistent style
4. **prettier** - Multi-language formatter for JSON, Markdown, and YAML files

### Custom Formatter Implementation

```nix
# formatter.nix - Custom Blueprint-compatible formatter
{
  inputs,
  pkgs,
  ...
}: let
  formatter = pkgs.writeShellApplication {
    name = "formatter";
    runtimeInputs = [
      pkgs.deadnix
      pkgs.statix
      pkgs.alejandra
      pkgs.nodePackages.prettier
    ];
    text = ''
      # Priority-based formatting pipeline with intelligent output
      # Only shows messages for files that actually changed
      while IFS= read -r -d "" file; do
        # Create backup to detect changes
        cp "$file" "$file.backup"

        # Apply formatting tools in priority order
        deadnix --no-lambda-pattern-names --edit "$file" 2>&1 || true
        statix fix "$file" >/dev/null 2>&1 || true
        alejandra "$file" >/dev/null 2>&1

        # Show output only for changed files
        if ! diff -q "$file" "$file.backup" >/dev/null 2>&1; then
          echo "✏️  Formatted: $file"
        fi
        rm -f "$file.backup"
      done < <(git ls-files -z "$@" | grep -z '\.nix$')
    '';
  };
```

### Formatting Commands

```bash
nix fmt                       # Format entire project (all tools)
nix fmt path/to/file.nix     # Format specific file
nix flake check              # Includes formatting validation
```

### Tool-Specific Benefits

**deadnix**:

- Removes unused variables, functions, and imports
- Cleans up legacy code automatically
- Prevents code bloat and improves maintainability

**statix**:

- Detects ~11 Nix antipatterns and code smells
- Enforces Nix community best practices
- Suggests more efficient or readable code patterns
- Examples: unused bindings, inefficient operations, deprecated syntax

**alejandra**:

- Consistent Nix code formatting
- Community-preferred alternative to nixfmt
- Handles complex nested attribute sets cleanly

**prettier**:

- Formats configuration files (JSON, YAML)
- Ensures consistent documentation formatting (Markdown)
- Handles oh-my-posh theme files and other JSON configs

### Format Check Integration

The formatter includes a comprehensive format check that integrates with `nix flake check`:

```nix
check = pkgs.runCommand "format-check" {
  nativeBuildInputs = [ formatter pkgs.git pkgs.delta ];
} ''
  # Run formatter on project copy
  cp --preserve=timestamps -r ${inputs.self} source
  cd source && git init --quiet && git add .

  formatter  # Run our custom formatter

  # Check for changes with beautiful delta diff output
  if ! git diff --exit-code --quiet; then
    echo "❌ Format check failed: Files need formatting"
    git diff | delta --side-by-side --line-numbers
    echo "🔧 To fix: run 'nix fmt' in your project"
    exit 1
  fi
'';
```

### Integration with Blueprint

The formatter leverages Blueprint's automatic flake output wiring:

- `formatter.nix` is automatically detected and integrated
- Custom `writeShellApplication` provides the formatting framework
- Works seamlessly with `nix fmt` command
- Format check integrates into `nix flake check` for CI/CD validation
- Cross-platform compatibility (works on Linux and macOS)

### Key Features

1. **Intelligent Output**: Only shows messages for files that actually changed
2. **Priority-based Pipeline**: Tools run in optimal order (deadnix → statix → alejandra → prettier)
3. **Blueprint Compatibility**: Works with Blueprint's automatic discovery system
4. **Cross-Platform Support**: Functions identically on Linux and macOS
5. **CI/CD Integration**: Format check fails builds when formatting is needed
6. **Delta Integration**: Beautiful side-by-side diffs for format violations
7. **Change Detection**: Uses git diff to identify actual modifications
