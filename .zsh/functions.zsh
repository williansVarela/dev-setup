# Function to check if a program exists
if_exists() {
    command -v "$1" >/dev/null 2>&1
}

if_installed() {
    if_exists brew && brew list --formula | grep "^$1\$" >/dev/null 2>&1
}

# Function to check if a file exists
if_file_exists() {
    [[ -f "$1" ]]
}

# Function to check if a directory exists
if_dir_exists() {
    [[ -d "$1" ]]
}

# Function to check if a package is installed
if_package_installed() {
    dpkg -l | grep -q "^ii\s\+$1\s"
}

ensure_package() {
  SILENT=false
  SUPPRESS=false
  package_name=""
  binary_name=""
  package_manager=""
  FLAGS=""

  # Help message function
  show_help() {
    echo "Usage: ensure_package [OPTIONS] PACKAGE"
    echo ""
    echo "Ensure a package is installed, installing it if necessary"
    echo ""
    echo "Arguments:"
    echo "  PACKAGE          Name of the package to ensure"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -s, --silent    Suppress all output"
    echo "  -su, --suppress Suppress only 'already installed' messages"
    echo "  -b, --binary    Specify binary name (defaults to package name)"
    echo "  -p, --package-manager  Package manager to use (defaults to auto-detect)"
    echo ""
    echo "Examples:"
    echo "  ensure_package bat"
    echo "  ensure_package -s bat"
    echo "  ensure_package python-pip -b pip -p apt"
  }

  if [[ "$ENSURE_PACKAGES" == "false" ]]; then
    return 0
  fi

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help)
      show_help
      return 0
      ;;
    -s | --silent)
      SILENT=true
      FLAGS="$FLAGS -s"
      ;;
    -su | --suppress)
      SUPPRESS=true
      FLAGS="$FLAGS -su"
      ;;
    -b | --binary)
      shift
      binary_name=$1
      ;;
    -p | --package-manager)
      shift
      package_manager=$1
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Try 'ensure_package --help' for more information."
      return 1
      ;;
    *)
      if [ -z "$package_name" ]; then
        package_name=$1
      else
        echo "Error: Unexpected argument: $1"
        echo "Try 'ensure_package --help' for more information."
        return 1
      fi
      ;;
    esac
    shift
  done

  # Validate required parameters
  if [ -z "$package_name" ]; then
    echo "Error: Package name is required"
    echo "Try 'ensure_package --help' for more information."
    return 1
  fi

  # Set binary name to package name if not specified
  if [ -z "$binary_name" ]; then
    binary_name=$package_name
  fi

  # First check if the command already exists
  if command -v "$binary_name" >/dev/null 2>&1; then
    [ "$SILENT" = false ] && [ "$SUPPRESS" = false ] && echo "Package $package_name is already installed"
    return 0
  fi

  # Auto-detect package manager if not specified
  if [ -z "$package_manager" ]; then
    if command -v brew >/dev/null 2>&1; then
      package_manager="brew"
      return 0
    elif command -v apt >/dev/null 2>&1; then
      package_manager="apt"
      return 0
    elif command -v pacman >/dev/null 2>&1; then
      package_manager="pacman"
      return 0
    elif command -v dnf >/dev/null 2>&1; then
      package_manager="dnf"
      return 0
    else
      echo "Error: Could not detect package manager"
      return 1
    fi
  fi

  # Only install if the command doesn't exist
  install $FLAGS "$package_name" "$binary_name" "$package_manager"
}