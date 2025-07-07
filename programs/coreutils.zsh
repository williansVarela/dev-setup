if [ $IS_MACOS = true ]; then
    # macOS specific coreutils installation
    ensure_package coreutils -s
fi