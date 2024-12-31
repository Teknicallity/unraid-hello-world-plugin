#!/bin/bash

# Default values
developer_dir=$(dirname $(pwd -P))
plugin_name=$(printf '%q\n' "${PWD##*/}")
version_suffix=""
plg_file=$(realpath $(find -name *.plg))
force_flag=false

# Function to display usage/help
usage() {
  echo "Usage: $0 [-d developer-dir] [-v version-suffix] [-h] [-n plugin-name] [-f]"
  echo
  echo "Options:"
  echo "  -d    Specify the developer directory (default: current parent directory)"
  echo "  -n    Specify plugin name to use (default: current directory)"
  echo "  -v    Specify the version suffix (e.g., v1.0)"
  echo "  -p    Specify the .plg file to use. This will replace the md5 hash"
  echo "  -f    Force mode: skip confirmation"
  echo "  -h    Display this help message"
  echo
  echo "Example:"
  echo "  $0 -d /path/to/dev/dir -v beta -p /path/to/plugin.plg -f"
}

# Parse command-line options
while getopts ":d:n:v:p:fh" opt; do
  case ${opt} in
    d)
      developer_dir=$(realpath "$OPTARG")
      ;;
    n)
      plugin_name="$OPTARG"
      ;;
    v)
      version_suffix="$OPTARG"
      ;;
    p)
      plg_file=$(realpath "$OPTARG")
      ;;
    f)
      force_flag=true
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done

# Shift to remove the parsed options
shift $((OPTIND - 1))

# Skip confirmation if force flag is enabled
if [[ "$force_flag" == false ]]; then
  # Display configuration
  echo "Dev directory: '$developer_dir'"
  echo "Plugin name: '$plugin_name'"
  echo "Version suffix: '$version_suffix'"
  echo "Plg file: '$plg_file'"

  read -p "Are these correct? (y/Y to proceed): " user_input
  if [[ "$user_input" != "y" && "$user_input" != "Y" ]]; then
    echo "Exiting."
    exit 1
  fi
else
  echo "Force mode enabled. Skipping confirmation."
fi
echo "Proceeding..."

# Set paths based on the plugin name and developer directory
src_dir="$developer_dir/$plugin_name/source"
archive_dir="$developer_dir/$plugin_name/archive"

# Generate a unique temporary directory
tmpdir="$developer_dir/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))"

# Generate the version string
version_date=$(date +"%Y.%m.%d")
if [[ -n "$version_suffix" ]]; then
  version=$ver_date-$version_suffix
else
  version=$version_date
fi

# Create necessary directories
mkdir -p "$tmpdir/usr/local/emhttp/plugins/$plugin_name"
mkdir -p "$archive_dir"

# Navigate to the source directory
cd "$src_dir" || { echo "Source directory $src_dir does not exist."; exit 1; }

# Ensure permissions and copy files to the temporary directory
chmod 0755 -R .
cp --parents -f $(find . -type f ! \( -iname "pkg_build.sh" -o -iname "sftp-config.json" \) ) \
    "$tmpdir/usr/local/emhttp/plugins/$plugin_name/"

# Create the package
cd "$tmpdir" || { echo "Temporary directory $tmpdir does not exist."; exit 1; }
makepkg -l y -c y "$archive_dir/$plugin_name-${version}.txz"

# Output the MD5 checksum of the package
echo "MD5:"
hash=$(md5sum "$archive_dir/$plugin_name-${version}.txz" | awk '{print $1}')
echo "$hash"

# Replace hash and suffix in .plg file if specified
if [[ ! -z "$plg_file" ]]; then
  if [[ -w "$plg_file" ]]; then
    sed -i "s|<!ENTITY md5        \".*\">|<!ENTITY md5        \"$hash\">|" "$plg_file"
    sed -i "s|<!ENTITY version    \".*\">|<!ENTITY version    \"$version_date\">|" "$plg_file"

    if [[ -n "$version_suffix" ]]; then
      sed -i "s|<!ENTITY suffix     \".*\">|<!ENTITY suffix     \"-$version_suffix\">|" "$plg_file"
    fi
  fi
fi

# Optional: Uncomment to clean up the temporary directory
# rm -rf "$tmpdir"
