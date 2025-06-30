# Homebrew Tap for ccap

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Homebrew](https://img.shields.io/badge/Homebrew-ccap-blue.svg)](https://github.com/wysaid/homebrew-ccap)

A [Homebrew](https://brew.sh/) tap for [ccap](https://github.com/wysaid/CameraCapture) - a high-performance, lightweight cross-platform C++ camera capture library.

## What is ccap?

ccap (CameraCapture) is a cross-platform C++ library that provides:

- **High Performance**: Hardware-accelerated pixel format conversion with up to 10x speedup
- **Lightweight**: Zero external dependencies - uses only system frameworks  
- **Cross Platform**: Windows (DirectShow), macOS/iOS (AVFoundation)
- **Multiple Formats**: RGB, BGR, YUV (NV12/I420) with automatic conversion
- **Production Ready**: Comprehensive test suite with 95%+ accuracy validation
- **Virtual Camera Support**: Compatible with OBS Virtual Camera and similar tools

## Installation

### Install via Homebrew

```bash
# Add this tap to your Homebrew
brew tap wysaid/ccap

# Install ccap
brew install ccap
```

### One-liner Installation

```bash
# Install directly without adding the tap first
brew install wysaid/ccap/ccap
```

## Usage

After installation, you can use ccap in your C++ projects:

### CMake Integration

```cmake
cmake_minimum_required(VERSION 3.14)
project(my_project)

set(CMAKE_CXX_STANDARD 17)

# Find ccap package
find_package(ccap REQUIRED)

add_executable(my_app main.cpp)
target_link_libraries(my_app ccap::ccap)

# macOS requires additional system frameworks
if(APPLE)
    target_link_libraries(my_app 
        "-framework Foundation"
        "-framework AVFoundation" 
        "-framework CoreVideo"
        "-framework CoreMedia"
        "-framework Accelerate"
    )
endif()
```

### pkg-config Integration

```bash
# Set PKG_CONFIG_PATH (if needed)
export PKG_CONFIG_PATH="$(brew --prefix)/lib/pkgconfig:$PKG_CONFIG_PATH"

# Compile your project
g++ -std=c++17 main.cpp $(pkg-config --cflags --libs ccap) -o my_app
```

### Manual Compilation

```bash
# Find installation path
CCAP_PREFIX=$(brew --prefix ccap)

# Compile directly
g++ -std=c++17 main.cpp \
    -I"$CCAP_PREFIX/include" \
    -L"$CCAP_PREFIX/lib" -lccap \
    -framework Foundation \
    -framework AVFoundation \
    -framework CoreVideo \
    -framework CoreMedia \
    -framework Accelerate \
    -o my_app
```

### Basic Usage Example

```cpp
#include <ccap.h>

int main() {
    ccap::Provider provider;
    
    // List available cameras
    auto devices = provider.findDeviceNames();
    for (size_t i = 0; i < devices.size(); ++i) {
        printf("[%zu] %s\n", i, devices[i].c_str());
    }
    
    // Open and start camera
    if (provider.open("", true)) {  // Empty string = default camera
        auto frame = provider.grab(3000);  // 3 second timeout
        if (frame) {
            printf("Captured: %dx%d, %s format\n", 
                   frame->width, frame->height,
                   ccap::pixelFormatToString(frame->pixelFormat).data());
        }
    }
    return 0;
}
```

## System Requirements

| Platform | Requirements |
|----------|-------------|
| **macOS** | macOS 10.13+ (High Sierra) |
| **Compiler** | Xcode Command Line Tools or Clang with C++17 support |
| **Dependencies** | None (uses system frameworks only) |

## Available Versions

This tap tracks the releases from the main [ccap repository](https://github.com/wysaid/CameraCapture).

- Latest stable: v1.0.1
- Development: Use `brew install --HEAD ccap` for latest development version

## Formula Information

- **Formula**: `ccap.rb`
- **Homepage**: <https://github.com/wysaid/CameraCapture>
- **License**: MIT
- **Dependencies**: cmake (build-time only)

## Verification

After installation, verify ccap is working correctly:

```bash
# Check installation
brew list ccap

# View installation info
brew info ccap

# Test the installation (if you have a camera)
ccap-test-program  # If available from examples
```

## Troubleshooting

### Common Issues

1. **Formula not found**

   ```bash
   # Make sure you've added the tap
   brew tap wysaid/ccap
   ```

2. **Build failures**

   ```bash
   # Update Homebrew and try again
   brew update
   brew install ccap
   ```

3. **Camera permissions on macOS**
   - Grant camera permissions in System Preferences > Security & Privacy > Camera

### Getting Help

- **ccap Issues**: [Report bugs](https://github.com/wysaid/CameraCapture/issues) in the main repository
- **Homebrew Formula Issues**: [Report here](https://github.com/wysaid/homebrew-ccap/issues)
- **Documentation**: [ccap Documentation](https://github.com/wysaid/CameraCapture#readme)

## Development

### Local Testing

To test the formula locally:

```bash
# Clone this repository
git clone https://github.com/wysaid/homebrew-ccap.git
cd homebrew-ccap

# Test the formula
brew install --build-from-source ./Formula/ccap.rb
brew test ccap
brew audit --strict --online ./Formula/ccap.rb
```

### Contributing

1. Fork this repository
2. Create a new branch for your changes
3. Test your changes thoroughly
4. Submit a pull request

## Related Links

- **Main Repository**: [CameraCapture](https://github.com/wysaid/CameraCapture)
- **Documentation**: [Build and Install Guide](https://github.com/wysaid/CameraCapture/blob/main/BUILD_AND_INSTALL.md)
- **Examples**: [Usage Examples](https://github.com/wysaid/CameraCapture/tree/main/examples)
- **Issues**: [Bug Reports](https://github.com/wysaid/CameraCapture/issues)

## License

This Homebrew tap is distributed under the MIT License, same as the ccap library.

---

**Note**: This is an unofficial tap maintained by the ccap project authors. For the most up-to-date information, please refer to the [main ccap repository](https://github.com/wysaid/CameraCapture).
