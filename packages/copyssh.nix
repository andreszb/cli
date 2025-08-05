{ pkgs }:
let
  # Platform-specific clipboard utilities
  clipboardUtils =
    with pkgs;
    [
      xclip
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      wl-clipboard
    ];
in
pkgs.writeScriptBin "copyssh" ''
  #!/usr/bin/env zsh

  copyssh() {
    # Handle --help option
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      echo "copyssh - Generate SSH key and configure GitHub authentication"
      echo ""
      echo "DESCRIPTION:"
      echo "  Automates the complete SSH key setup process for GitHub, including:"
      echo "  • Generates Ed25519 SSH key if it doesn't exist"
      echo "  • Starts SSH agent and adds the key"
      echo "  • Copies public key to clipboard"
      echo "  • Configures commit signing with SSH"
      echo "  • Provides step-by-step GitHub setup instructions"
      echo ""
      echo "USAGE:"
      echo "  copyssh           # Run the SSH setup process"
      echo "  copyssh --help    # Show this help message"
      echo ""
      echo "REQUIREMENTS:"
      echo "  • ssh-keygen (for key generation)"
      echo "  • ssh-agent (for key management)"
      echo "  • pbcopy (macOS) or xclip (Linux) for clipboard access"
      echo "  • git (for commit signing configuration)"
      echo ""
      echo "FILES CREATED:"
      echo "  ~/.ssh/id_ed25519         # Private SSH key"
      echo "  ~/.ssh/id_ed25519.pub     # Public SSH key"
      echo "  ~/.ssh/allowed_signers    # Git commit signing configuration"
      echo ""
      echo "NEXT STEPS:"
      echo "  After running copyssh, visit https://github.com/settings/keys"
      echo "  to add your SSH key to GitHub."
      return 0
    fi

    local email="$(${pkgs.git}/bin/git config --global user.email)"
    local ssh_key_path="$HOME/.ssh/id_ed25519"
    local pub_key_path="$ssh_key_path.pub"
    
    # Validate email is set
    if [[ -z "$email" ]]; then
      echo "❌ Error: No email configured in git. Please run:"
      echo "   git config --global user.email \"your-email@example.com\""
      return 1
    fi
    
    echo "🔐 Setting up SSH key for GitHub..."
    echo "📧 Using email: $email"
    echo ""
    
    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Step 1: Generate SSH key if it doesn't exist
    if [[ ! -f "$ssh_key_path" ]]; then
      echo "1️⃣  Generating SSH key..."
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""
      echo "✅ SSH key generated"
    else
      echo "1️⃣  SSH key already exists at $ssh_key_path"
    fi
    
    # Step 2: Start SSH agent
    echo "2️⃣  Starting SSH agent..."
    eval "$(${pkgs.openssh}/bin/ssh-agent -s)"
    
    # Step 3: Add key to agent
    echo "3️⃣  Adding key to SSH agent..."
    ${pkgs.openssh}/bin/ssh-add "$ssh_key_path"
    if [[ $? -eq 0 ]]; then
      echo "✅ Key added to SSH agent"
      echo "📋 Keys in agent:"
      ${pkgs.openssh}/bin/ssh-add -l
    else
      echo "❌ Failed to add key to SSH agent"
      return 1
    fi
    echo ""
    
    # Step 4: Copy public key to clipboard
    echo "4️⃣  Copying public key to clipboard..."
    if [[ ! -f "$pub_key_path" ]]; then
      echo "❌ Error: Public key not found at $pub_key_path"
      return 1
    fi
    
    echo "📄 Public key content:"
    cat "$pub_key_path"
    echo ""
    
    local copied=false
    if command -v pbcopy >/dev/null 2>&1; then
      if cat "$pub_key_path" | pbcopy; then
        echo "✅ Public key copied to clipboard (macOS)"
        copied=true
      else
        echo "❌ Failed to copy to clipboard (macOS)"
      fi
    elif command -v ${pkgs.xclip}/bin/xclip >/dev/null 2>&1; then
      if cat "$pub_key_path" | ${pkgs.xclip}/bin/xclip -selection clipboard; then
        echo "✅ Public key copied to clipboard (Linux - xclip)"
        copied=true
      else
        echo "❌ Failed to copy to clipboard (Linux - xclip)"
      fi${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        elif command -v ${pkgs.wl-clipboard}/bin/wl-copy >/dev/null 2>&1; then
          if cat "$pub_key_path" | ${pkgs.wl-clipboard}/bin/wl-copy; then
            echo "✅ Public key copied to clipboard (Wayland)"
            copied=true
          else
            echo "❌ Failed to copy to clipboard (Wayland)"
          fi''}
    fi
    
    if [[ "$copied" == false ]]; then
      echo "⚠️  No clipboard utility found or copy failed"
      echo "💡 You can manually copy the public key shown above"
    fi
    echo ""
    
    # Step 5: Create allowed_signers file for commit verification
    echo "5️⃣  Setting up commit signing..."
    echo "$email $(cat "$pub_key_path")" > ~/.ssh/allowed_signers
    chmod 644 ~/.ssh/allowed_signers
    ${pkgs.git}/bin/git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
    echo "✅ Commit signing configured"
    echo ""
    
    # Instructions
    echo "🎯 Next steps:"
    echo "   1. Visit: https://github.com/settings/keys"
    echo "   2. Click 'New SSH key'"
    echo "   3. Paste the key from clipboard"
    echo "   4. Set key type to 'Authentication Key' and optionally 'Signing Key'"
    echo "   5. Test connection: ssh -T git@github.com"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "   • View public key: cat \"$pub_key_path\""
    echo "   • Test GitHub connection: ssh -T git@github.com"
    echo "   • Check SSH agent: ssh-add -l"
  }

  # Execute the function
  copyssh "$@"
''
