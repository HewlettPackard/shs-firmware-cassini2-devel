#!/bin/bash

set -Eeuo pipefail

# Determine the directory of the script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)


# Get the version from a spec file
# Arguments:
#   1. Path to the spec file
# Returns:
#   The version defined in the spec file
get_specfile_version() {
    local spec_file=$1

    if [[ ! -f "$spec_file" ]]; then
        log_error "Spec file not found: $spec_file"
    fi

    local version
    version=$(grep -E '^Version:' "$spec_file" | awk '{print $2}')
    
    if [[ -z "$version" ]]; then
        log_error "Failed to extract version from spec file: $spec_file"
    fi

    echo "$version"
}

# Variables
SPEC_FILE="$SCRIPT_DIR/cassini2-firmware-devel.spec"
INCLUDE_DIR="$SCRIPT_DIR/include"
BUILD_DIR="$SCRIPT_DIR/build"
VERSION=$(get_specfile_version "$SPEC_FILE")
TARBALL_NAME="cassini2-firmware-devel-$VERSION.tar.gz"
RPMBUILD_DIR="$BUILD_DIR/rpmbuild"

# Ensure required tools are installed
for cmd in rpmbuild tar; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it to proceed."
        exit 1
    fi
done

# Prepare the build environment
prepare_build_env() {
    echo "Preparing build environment..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    echo "Build environment prepared."
}

# Create the tarball
create_tarball() {
    echo "Creating tarball from include directory..."
    tar --exclude="$TARBALL_NAME" \
        -czf "$RPMBUILD_DIR/SOURCES/$TARBALL_NAME" --transform "s,^,cassini2-firmware-devel-$VERSION/," ./lib $SPEC_FILE
    echo "Tarball created: $RPMBUILD_DIR/SOURCES/$TARBALL_NAME"
}

# Copy the spec file
copy_spec_file() {
    echo "Copying spec file..."
    cp "$SPEC_FILE" "$RPMBUILD_DIR/SPECS/"
    sed -i -e "s|Release:.*|Release:        1%{?dist}|g" "$RPMBUILD_DIR/SPECS/$(basename "$SPEC_FILE")"
    echo "Spec file copied to $RPMBUILD_DIR/SPECS/"
}

# Build the RPM
build_rpm() {
    echo "Building RPM..."
    rpmbuild --define "_topdir $RPMBUILD_DIR" -ba "$RPMBUILD_DIR/SPECS/$(basename "$SPEC_FILE")"
    echo "RPM build completed. RPMs are located in $RPMBUILD_DIR/RPMS/"
}

# Clean up the build directory
cleanup() {
    echo "Cleaning up build directory..."
    rm -rf "$BUILD_DIR"
    echo "Build directory cleaned up."
}

# Main function
main() {
    prepare_build_env
    create_tarball
    copy_spec_file
    build_rpm
}

# Execute main function
main "$@"
