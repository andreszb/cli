{
  pkgs,
  perSystem,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    # LaTeX and document processing packages (assumes default shell already sourced)
    texlive.combined.scheme-full

    # PDF tools
    poppler_utils # pdfinfo, pdftotext, etc.

    # Bibliography management
    biber

    # Document conversion
    pandoc

    # Spell checking
    hunspell
    hunspellDicts.en_US
  ];

  shellHook = ''
    echo "📖 TeX/LaTeX development environment loaded!"
    echo "📦 Available tools:"
    echo "   • texlive (full scheme)"
    echo "   • pandoc (document conversion)"
    echo "   • biber (bibliography management)"
    echo "   • hunspell (spell checking)"
    echo ""
    echo "💡 Common commands:"
    echo "   • pdflatex document.tex"
    echo "   • biber document"
    echo "   • pandoc -o output.pdf input.md"
    echo ""
  '';
}
