#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <plugin-name> [version-suffix]"
  exit 1
fi

plugin_name=$1
version_suffix=$2

# Set paths based on the plugin name
src_dir="/mnt/user/unraid_development/$plugin_name/source"
archive_dir="/mnt/user/unraid_development/$plugin_name/archive"

# Generate a unique temporary directory
tmpdir=/mnt/user/unraid_development/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))

# Generate the version string
version=$(date +"%Y.%m.%d")$version_suffix

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
md5sum "$archive_dir/$plugin_name-${version}.txz" | awk '{print $1}'

# Optional: Uncomment to clean up the temporary directory
# rm -rf "$tmpdir"
