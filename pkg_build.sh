#!/bin/bash

# Default values
version_suffix=""
plugin_dir="$(dirname "$(realpath "$0")")"
plg_filepath=$(find "$plugin_dir" -name "*.plg" -exec realpath {} \;)
plugin_name=$(printf '%q\n' "${plugin_dir##*/}") # takes the name from root directory
plugin_name="${plugin_name//-/\.}" # replaces dashes with dots
accept_flag=false
dry_run=false

# Function to display usage/help
usage() {
  echo "Usage: $0 [-d] [-v version-suffix] [-h] [-n plugin-name] [-y]"
  echo
  echo "The .plg file should have the same name as its parent directory."
  echo
  echo "Options:"
  echo "  -v    Specify the version suffix (e.g., v1.0)"
  echo "  -p    Specify the .plg file to use. This will replace the md5 hash"
  echo "  -d    Dry Run: don not write any changes to files"
  echo "  -y    Accept mode: skip confirmation"
  echo "  -h    Display this help message"
  echo
  echo "Example:"
  echo "  $0 -v beta -p /path/to/plugin.plg -f"
}

# Parse command-line options
while getopts ":v:p:dyh" opt; do
  case ${opt} in
    v)
      version_suffix="$OPTARG"
      ;;
    p)
      plg_filepath=$(realpath "$OPTARG")
      ;;
    d)
      dry_run=true
      ;;
    y)
      accept_flag=true
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
if [[ "$accept_flag" == false ]]; then
  # Display configuration
  echo -e "Plg filepath: \t'$plg_filepath'"
  echo -e "Plugin name: \t'$plugin_name'"
  echo -e "Version suffix: '$version_suffix'"

  read -p "Are these correct? (y/Y to proceed): " user_input
  if [[ "$user_input" != "y" && "$user_input" != "Y" ]]; then
    echo "Exiting."
    exit 1
  fi
else
  echo "Accept mode enabled. Skipping confirmation."
fi
echo "Proceeding..."
echo

# Set paths based on the plugin name and developer directory
src_dir="$plugin_dir/source"
archive_dir="$plugin_dir/archive"

# Generate a unique temporary directory
tmpdir="$plugin_dir/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))"
trap "rm -rf $tmpdir" EXIT

# Generate the version string
version_date=$(date +"%Y.%m.%d")
if [[ -n "$version_suffix" ]]; then
  version=$version_date-$version_suffix
else
  version=$version_date
fi

# Create necessary directories
mkdir -p "$tmpdir/usr/local/emhttp/plugins/$plugin_name"
mkdir -p "$archive_dir"

# Navigate to the source directory
cd "$src_dir" || { echo "Source directory $src_dir does not exist."; exit 1; }

# Ensure permissions and copy files to the temporary directory
chmod 0755 -R "$src_dir"
cp --parents -f $(find . -type f ! \( -iname "pkg_build.sh" -o -iname "sftp-config.json" \) ) \
    "$tmpdir/usr/local/emhttp/plugins/$plugin_name/"
chmod 0755 -R "$tmpdir"
chown root:root -R "$tmpdir"
chmod 0755 "$plugin_dir"

# If dry run, only create archive package in tmp directory
if [[ "$dry_run" == true ]]; then
  archive_file="$plugin_dir/tmp/$plugin_name-${version}.txz"
else
  archive_file="$archive_dir/$plugin_name-${version}.txz"
fi
echo "Archive File:"
echo "$archive_file"
echo

# Create the package
cd "$tmpdir" || { echo "Temporary directory $tmpdir does not exist."; exit 1; }
if ! makepkg -l y -c n "$archive_file" ; then
  echo "Failed to make package. Exiting."
  exit 1
fi

# Output the MD5 checksum of the package
hash=$(md5sum "$archive_file" | awk '{print $1}')
# echo "MD5:"
# echo "$hash"

# Replace hash and suffix in .plg file if specified
if [[ -n "$plg_filepath" && "$dry_run" == false ]]; then
  if [[ -w "$plg_filepath" ]]; then
    sed -i "s|<!ENTITY md5        \".*\">|<!ENTITY md5        \"$hash\">|" "$plg_filepath"
    sed -i "s|<!ENTITY version    \".*\">|<!ENTITY version    \"$version_date\">|" "$plg_filepath"

    if [[ -n "$version_suffix" ]]; then
      sed -i "s|<!ENTITY suffix     \".*\">|<!ENTITY suffix     \"-$version_suffix\">|" "$plg_filepath"
    fi
  fi
fi

echo "<!ENTITY md5        \"$hash\">"
echo "<!ENTITY version    \"$version_date\">"
if [[ -n "$version_suffix" ]]; then
  echo "<!ENTITY suffix     \"-$version_suffix\">"
fi
