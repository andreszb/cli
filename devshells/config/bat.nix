{pkgs}: ''
    # === BAT Configuration ===
    cat > "$CONFIG_DIR/bat/config" << 'EOF'
  --pager='less -FR'
  --theme=TwoDark
  --style=numbers,changes,header,grid
  --color=always
  EOF
    export BAT_CONFIG_PATH="$CONFIG_DIR/bat/config"
''
