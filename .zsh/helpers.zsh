# OS detection
IS_MACOS=false
IS_LINUX=false
IS_WSL=false

if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    IS_LINUX=true
    if $(grep -i -c 'Microsoft' /proc/version) -gt 0; then
        IS_WSL=true
    fi
fi