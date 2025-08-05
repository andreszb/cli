{ pkgs, perSystem, ... }:
let
  # Python with essential packages for development
  pythonWithPackages = pkgs.python3.withPackages (
    ps: with ps; [
      # Core development tools
      pip
      setuptools
      wheel
      virtualenv

      # Code quality and formatting
      black
      isort
      flake8
      mypy
      pylint

      # Testing
      pytest
      pytest-cov

      # Popular libraries
      requests
      pyyaml
      click
      rich

      # Development utilities
      ipython

      # Package management
      pipx
    ]
  );
in
pkgs.mkShell {
  packages = with pkgs; [
    # Python environment (assumes default shell already sourced)
    pythonWithPackages
    python3Packages.pip-tools # pip-compile, pip-sync
    ruff # Fast Python linter and formatter
    pyright # Python language server
    uv # Fast Python package installer and resolver
  ];

  env = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "bat";
  };

  shellHook = ''
    echo "🐍 Python development environment loaded!"
    echo "📦 Available tools:"
    echo "   • Python 3 with essential packages"
    echo "   • ruff (fast linter/formatter)"
    echo "   • pyright (language server)"
    echo "   • uv (fast package installer)"
    echo "   • pip-tools (pip-compile, pip-sync)"
    echo ""
    echo "💡 Common commands:"
    echo "   • python -m venv venv"
    echo "   • pip install -r requirements.txt"
    echo "   • ruff check ."
    echo "   • black ."
    echo "   • pytest"
    echo ""
  '';
}
