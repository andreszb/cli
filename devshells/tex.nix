{ pkgs, self, ... }:
pkgs.mkShell {
  packages = with pkgs; [
    # LaTeX full distribution
    texlive.combined.scheme-full
    
    # Text editors and viewers
    neovim
    
    # PDF tools
    poppler_utils  # pdfinfo, pdftotext, etc.
    
    # Bibliography management
    biber
    
    # Document conversion
    pandoc
    
    # Spell checking
    hunspell
    hunspellDicts.en_US
    
    # Custom blueprint packages
    self.copyssh
    self.mkcd
    self.shell-switcher
    self.cli-help
  ];

  env = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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