{ pkgs, perSystem, ... }:
pkgs.mkShell {
  packages = with pkgs; [
    # Node.js and web development packages (assumes default shell already sourced)
    nodejs_20
    corepack
    
    # Package managers
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    
    # Code quality and formatting
    nodePackages.eslint
    nodePackages.prettier
    
    # TypeScript
    nodePackages.typescript
    nodePackages.typescript-language-server
    
    # Build tools and bundlers
    nodePackages.webpack
    nodePackages.webpack-cli
    
    # Development utilities
    nodePackages.nodemon
    nodePackages.concurrently
    
    # Package management
    nodePackages.npm-check-updates
    
    # Development servers
    nodePackages.serve
    nodePackages.http-server
  ];

  env = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "bat";
  };

  shellHook = ''
    echo "🌐 Web development environment loaded!"
    echo "📦 Available tools:"
    echo "   • Node.js 20 LTS"
    echo "   • npm, yarn, pnpm"
    echo "   • TypeScript + language server"
    echo "   • ESLint + Prettier"
    echo "   • Webpack + dev tools"
    echo ""
    echo "💡 Common commands:"
    echo "   • npm init"
    echo "   • npm install"
    echo "   • npm run dev"
    echo "   • npx create-react-app myapp"
    echo "   • yarn create next-app"
    echo ""
  '';
}