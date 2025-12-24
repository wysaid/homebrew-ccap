# Quick Start: Updating the Formula

This guide shows you how to update the ccap formula when a new upstream version is released.

## Method 1: Using the Auto-Update Script (Recommended)

### Basic Update

```bash
# Navigate to the tap directory
cd homebrew-ccap

# Run the update script
./update_formula.sh

# Review the changes
git diff ccap.rb

# Commit and push
git add ccap.rb
git commit -m "Update ccap to v$(grep -oP 'v\K[0-9.]+' ccap.rb | head -1)"
git push
```

### Check Before Updating

```bash
# Check if an update is available without making changes
./update_formula.sh --check-only
```

### Update to Specific Version

```bash
# Update to a specific version (e.g., v1.5.0)
./update_formula.sh --version 1.5.0
```

## Method 2: Manual Update

If you prefer to update manually:

```bash
# 1. Check upstream for latest version
NEW_VERSION="1.4.0"

# 2. Download and calculate SHA256
curl -sSfL "https://github.com/wysaid/CameraCapture/archive/refs/tags/v${NEW_VERSION}.tar.gz" -o /tmp/ccap.tar.gz
SHA256=$(sha256sum /tmp/ccap.tar.gz | awk '{print $1}')

# 3. Update ccap.rb manually
# - Change url line to new version
# - Change sha256 line to new checksum

# 4. Verify and commit
git diff ccap.rb
git add ccap.rb
git commit -m "Update ccap to v${NEW_VERSION}"
git push
```

## Method 3: Wait for GitHub Actions

The repository has an automated workflow that:
- Runs daily at midnight UTC
- Checks for new upstream releases
- Automatically creates a PR when updates are found

You just need to:
1. Wait for the PR to be created
2. Review the changes
3. Merge the PR

## Testing Your Update

After updating the formula:

```bash
# Test installation
brew install --build-from-source ./ccap.rb

# Run formula tests
brew test ccap

# Test the library
cat > test.cpp << 'EOF'
#include <ccap.h>
#include <iostream>
int main() {
    ccap::Provider provider;
    auto devices = provider.findDeviceNames();
    std::cout << "Found " << devices.size() << " cameras\n";
    return 0;
}
EOF

# Compile and run (macOS)
clang++ -std=c++17 test.cpp -I$(brew --prefix ccap)/include -L$(brew --prefix ccap)/lib -lccap \
    -framework Foundation -framework AVFoundation -framework CoreVideo -framework CoreMedia -framework Accelerate \
    -o test && ./test

# Test CLI tool
ccap --version
ccap --list-devices
```

## Troubleshooting

### Update Script Fails

```bash
# Make sure the script is executable
chmod +x update_formula.sh

# Check if curl is available
which curl

# Check if sha256sum is available (or use shasum on macOS)
which sha256sum || which shasum
```

### Formula Validation Fails

```bash
# Run Homebrew audit
brew audit --strict ccap.rb

# Check formula syntax
ruby -c ccap.rb
```

### Build Fails

```bash
# Clean previous builds
rm -rf ~/Library/Caches/Homebrew/ccap--*

# Try building again
brew install --build-from-source --verbose ./ccap.rb
```

## Best Practices

1. **Always test locally first**
   - Install from the updated formula
   - Run `brew test ccap`
   - Test both library and CLI

2. **Review release notes**
   - Check what changed upstream
   - Look for breaking changes
   - Update README if needed

3. **Update documentation**
   - Update version in README.md
   - Add entry to CHANGELOG.md
   - Note any breaking changes

4. **Use descriptive commits**
   ```bash
   # Good
   git commit -m "Update ccap to v1.4.0 - adds CLI tool"
   
   # Also good
   git commit -m "Update ccap to v1.4.0

   - Added CLI tool support
   - Fixed timeout handling
   - Updated dependencies"
   ```

## Automation Tips

### Set up notifications

Watch the upstream repository for releases:
- Go to https://github.com/wysaid/CameraCapture
- Click "Watch" → "Custom" → Check "Releases"

### Local cron job

Add a daily check to your crontab:
```bash
# Check daily at 9 AM for updates
0 9 * * * cd /path/to/homebrew-ccap && ./update_formula.sh --check-only | mail -s "ccap update check" you@example.com
```

## Reference

- **Upstream Repository**: https://github.com/wysaid/CameraCapture
- **Homebrew Formula Cookbook**: https://docs.brew.sh/Formula-Cookbook
- **This Tap**: https://github.com/wysaid/homebrew-ccap
