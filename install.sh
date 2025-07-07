# Exit on error
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo or switch to the root user."
  exit 1
fi

trap 'echo "An error occurred. Exiting..."; exit 1' ERR

# Load Helpers
[[ -f ~/.zsh/helpers.zsh ]] && source ~/.zsh/helpers.zsh

# Update and upgrade the system
apt-get update && apt-get upgrade -y

# Build tools
apt-get install build-essential procps curl file git
