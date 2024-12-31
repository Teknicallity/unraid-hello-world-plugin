#!/bin/bash

if [ $# -gt 1 ]; then
  echo "Usage: $0 [version-suffix]"
  exit 1
fi

version_suffix=$1

plugin_dir=$(dirname $(realpath basic_build.sh))
plugin_name=$(printf '%q\n' "${plugin_dir##*/}")

# Set paths based on the plugin name
src_dir="$plugin_dir/source"
archive_dir="$plugin_dir/archive"

# Generate a unique temporary directory
tmpdir=$plugin_dir/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))

# Generate the version string
version=$(date +"%Y.%m.%d")$version_suffix

# Create necessary directories
mkdir -p "$tmpdir/usr/local/emhttp/plugins/$plugin_name"
mkdir -p "$archive_dir"

# Basic manual package build process...
# Navigate to the source directory
cd "$src_dir" || { echo "Source directory $src_dir does not exist."; exit 1; }

# Copy files to the temporary directory
chmod 0755 -R .
cp --parents -f $(find . -type f ! \( -iname "pkg_build.sh" -o -iname "sftp-config.json" \) ) \
    "$tmpdir/usr/local/emhttp/plugins/$plugin_name/"

# Create the package with `makepkg <tarball filepath>`
cd "$tmpdir" || { echo "Temporary directory $tmpdir does not exist."; exit 1; }
makepkg -l y -c y "$archive_dir/$plugin_name-${version}.txz"
echo "makepackage archive directory: $archive_dir/$plugin_name-${version}.txz"

# Output the MD5 checksum of the package
echo "MD5:"
md5sum "$archive_dir/$plugin_name-${version}.txz" | awk '{print $1}'

# Optional: Uncomment to clean up the temporary directory
# rm -rf "$tmpdir"