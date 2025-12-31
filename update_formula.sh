#!/usr/bin/env bash

#
# Homebrew ccap Formula Auto-Update Script
#
# This script automatically updates the ccap formula to the latest version
# from the upstream CameraCapture repository.
#
# Usage:
#   ./update_formula.sh [options]
#
# Options:
#   --check-only        Only check for updates without applying them
#   --version VERSION   Update to a specific version instead of latest
#   --help              Show this help message
#
# Examples:
#   ./update_formula.sh                    # Update to latest version
#   ./update_formula.sh --check-only       # Just check if update is available
#   ./update_formula.sh --version 1.4.0    # Update to specific version
#

set -euo pipefail

# Configuration
UPSTREAM_REPO="wysaid/CameraCapture"
FORMULA_FILE="ccap.rb"
TEMP_DIR=$(mktemp -d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

show_help() {
    sed -n '3,22p' "$0" | sed 's/^# \?//'
    exit 0
}

# Get current version from formula
get_current_version() {
    if [[ ! -f "$FORMULA_FILE" ]]; then
        log_error "Formula file '$FORMULA_FILE' not found"
        exit 1
    fi

    local version
    version=$(grep -o 'url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v[0-9][0-9.a-zA-Z-]*\.tar\.gz"' "$FORMULA_FILE" | sed -E 's|.*v([0-9]+\.[0-9]+\.[0-9]+[0-9a-zA-Z.-]*)\.tar\.gz"$|\1|' || true)

    if [[ -z "$version" ]]; then
        log_error "Could not extract current version from $FORMULA_FILE"
        exit 1
    fi

    echo "$version"
}

# Get latest release version from GitHub
get_latest_version() {
    log_info "Fetching latest release from upstream..." >&2

    local response
    if command -v gh >/dev/null 2>&1; then
        # Use GitHub CLI if available
        response=$(gh api "repos/$UPSTREAM_REPO/releases/latest" 2>/dev/null || echo "")
    else
        # Fallback to curl
        response=$(curl -sSfL "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" 2>/dev/null || echo "")
    fi

    if [[ -z "$response" ]]; then
        log_error "Failed to fetch latest release from GitHub"
        exit 1
    fi

    local tag_name
    tag_name=$(echo "$response" | grep -o '"tag_name"[^"]*"[^"]*"' | head -1 | sed -E 's/.*"tag_name"[^"]*"([^"]*)"$/\1/' || true)

    if [[ -z "$tag_name" ]]; then
        log_error "Could not parse tag name from GitHub API response"
        exit 1
    fi

    # Remove 'v' prefix if present
    echo "${tag_name#v}"
}

# Download tarball and calculate SHA256
get_sha256() {
    local version=$1
    local url="https://github.com/$UPSTREAM_REPO/archive/refs/tags/v${version}.tar.gz"
    local tarball="$TEMP_DIR/ccap-${version}.tar.gz"

    log_info "Downloading tarball from $url..." >&2

    if ! curl -sSfL "$url" -o "$tarball"; then
        log_error "Failed to download tarball"
        exit 1
    fi

    log_info "Calculating SHA256 checksum..." >&2

    local sha256
    if command -v sha256sum >/dev/null 2>&1; then
        sha256=$(sha256sum "$tarball" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        sha256=$(shasum -a 256 "$tarball" | awk '{print $1}')
    else
        log_error "Neither sha256sum nor shasum found"
        exit 1
    fi

    if ! echo "$sha256" | grep -qE '^[a-f0-9]{64}$'; then
        log_error "Invalid SHA256 format: $sha256"
        exit 1
    fi

    echo "$sha256"
}

# Get release notes from GitHub
get_release_notes() {
    local version=$1
    local response

    if command -v gh >/dev/null 2>&1; then
        response=$(gh api "repos/$UPSTREAM_REPO/releases/tags/v${version}" --jq '.body' 2>/dev/null || echo "")
    else
        response=$(curl -sSfL "https://api.github.com/repos/$UPSTREAM_REPO/releases/tags/v${version}" 2>/dev/null | grep -o '"body"[^"]*"[^"]*"' | sed -E 's/.*"body"[^"]*"([^"]*)"$/\1/' || echo "")
    fi

    if [[ -n "$response" ]]; then
        # Decode escaped characters and show first 5 lines
        echo "$response" | head -5
    fi
}

# Update formula file
update_formula() {
    local new_version=$1
    local new_sha256=$2

    log_info "Updating $FORMULA_FILE..."

    # Create backup
    cp "$FORMULA_FILE" "${FORMULA_FILE}.backup"

    # Update version in URL
    if ! sed -i.tmp -E "s|url \"https://github.com/wysaid/CameraCapture/archive/refs/tags/v[0-9]+\.[0-9]+\.[0-9]+[0-9a-zA-Z.-]*\.tar\.gz\"|url \"https://github.com/wysaid/CameraCapture/archive/refs/tags/v${new_version}.tar.gz\"|" "$FORMULA_FILE"; then
        log_error "Failed to update version in formula"
        mv "${FORMULA_FILE}.backup" "$FORMULA_FILE"
        exit 1
    fi

    # Update SHA256
    if ! sed -i.tmp -E "s|sha256 \"[a-f0-9]{64}\"|sha256 \"${new_sha256}\"|" "$FORMULA_FILE"; then
        log_error "Failed to update SHA256 in formula"
        mv "${FORMULA_FILE}.backup" "$FORMULA_FILE"
        exit 1
    fi

    # Remove temp files
    rm -f "${FORMULA_FILE}.tmp"

    # Validate changes
    if ! grep -q "v${new_version}" "$FORMULA_FILE"; then
        log_error "Version validation failed"
        mv "${FORMULA_FILE}.backup" "$FORMULA_FILE"
        exit 1
    fi

    if ! grep -q "${new_sha256}" "$FORMULA_FILE"; then
        log_error "SHA256 validation failed"
        mv "${FORMULA_FILE}.backup" "$FORMULA_FILE"
        exit 1
    fi

    # Remove backup on success
    rm -f "${FORMULA_FILE}.backup"

    log_success "Formula updated successfully"
}

# Test formula
test_formula() {
    log_info "Testing formula syntax..."

    if command -v brew >/dev/null 2>&1; then
        if brew audit --strict "$FORMULA_FILE" 2>/dev/null; then
            log_success "Formula syntax is valid"
            return 0
        else
            log_warning "Formula audit found some issues (this may be OK if formula is not installed)"
        fi
    else
        log_warning "Homebrew not found, skipping formula validation"
    fi
}

# Show diff
show_diff() {
    if [[ -f "${FORMULA_FILE}.backup" ]]; then
        log_info "Changes made to $FORMULA_FILE:"
        diff -u "${FORMULA_FILE}.backup" "$FORMULA_FILE" || true
    fi
}

# Main function
main() {
    local check_only=false
    local target_version=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --check-only)
            check_only=true
            shift
            ;;
        --version)
            target_version="$2"
            shift 2
            ;;
        --help | -h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        esac
    done

    echo "═══════════════════════════════════════════════════════════"
    echo "  Homebrew ccap Formula Auto-Update Script"
    echo "═══════════════════════════════════════════════════════════"
    echo

    # Get current version
    local current_version
    current_version=$(get_current_version)
    log_info "Current version: v${current_version}"

    # Get target version
    local new_version
    if [[ -n "$target_version" ]]; then
        new_version="$target_version"
        log_info "Target version: v${new_version} (manually specified)"
    else
        new_version=$(get_latest_version)
        log_info "Latest upstream version: v${new_version}"
    fi

    # Compare versions
    if [[ "$current_version" == "$new_version" ]]; then
        log_success "Formula is already up to date (v${current_version})"
        exit 0
    fi

    echo
    log_warning "Update available: v${current_version} → v${new_version}"
    echo

    # Show release notes
    log_info "Release notes for v${new_version}:"
    echo "───────────────────────────────────────────────────────────"
    get_release_notes "$new_version"
    echo "───────────────────────────────────────────────────────────"
    echo

    # Exit if check-only mode
    if [[ "$check_only" == true ]]; then
        log_info "Check-only mode: exiting without making changes"
        exit 0
    fi

    # Calculate new SHA256
    local new_sha256
    new_sha256=$(get_sha256 "$new_version")
    log_success "SHA256: $new_sha256"
    echo

    # Update formula
    update_formula "$new_version" "$new_sha256"
    echo

    # Show diff
    show_diff
    echo

    # Test formula
    test_formula
    echo

    log_success "Update completed successfully!"
    echo
    echo "Next steps:"
    echo "  1. Review the changes: git diff $FORMULA_FILE"
    echo "  2. Test the formula: brew install --build-from-source ./$FORMULA_FILE"
    echo "  3. Commit changes: git add $FORMULA_FILE && git commit -m 'Update ccap to v${new_version}'"
    echo "  4. Push to repository: git push"
    echo
}

# Run main function
main "$@"
