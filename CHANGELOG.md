# Changelog

All notable changes to this Homebrew tap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2026-03-28

### Changed
- Updated ccap to upstream version v1.7.0

### Upstream Changes (v1.7.0)
- 📦 Added JSON output support to CLI (`--json` flag for structured output)
- 🧩 Added publishable ClawHub/OpenClaw skill bundle (`skills/ccap/`)
- 🔒 Tightened CLI JSON contract and test parser (RFC 8259 compliance)
- 🐧 Improved Linux JSON error handling for video file commands

## [1.6.0] - 2026-03-21

### Changed
- Updated ccap to upstream version v1.6.0

### Upstream Changes (v1.6.0)
- 🪟 Added MSMF (Media Foundation) backend on Windows with DirectShow fallback
- 🤝 DirectShow remains the default for strong virtual-camera compatibility
- 🔁 Auto mode merges device lists from both Windows backends
- 🛠️ Fixed NEON precision bug, improved Windows build toolchain

## [1.5.0] - 2025-12-30

### Added
- **Video File Playback**: Added file playback support on Windows (Media Foundation) and macOS (AVFoundation)

### Changed
- Updated ccap to upstream version v1.5.0
- Added MSVC 2026 and MinGW workflow support (upstream)
- Optimized CI workflows with caching strategies (upstream)

### Upstream Changes (v1.5.0)
- 🎥 Added video file playback support for Windows and macOS
- 🧰 Added MSVC 2026 and MinGW workflow support
- ⚡ Optimized GitHub Actions workflows with caching strategies

## [1.4.0] - 2025-12-24

### Added
- **CLI Tool Support**: Formula now installs `ccap` command-line tool alongside the library
  - Users can now use `ccap --list-devices` to list cameras
  - Quick frame capture with `ccap --output frame.bmp`
  - Useful for testing, scripting, and debugging
- **Auto-Update Script**: Added `update_formula.sh` for automated formula updates
  - Check for updates: `./update_formula.sh --check-only`
  - Auto-update to latest: `./update_formula.sh`
  - Update to specific version: `./update_formula.sh --version X.Y.Z`
- **Enhanced Documentation**: Updated README with CLI usage examples and update script instructions

### Changed
- Updated ccap to upstream version v1.4.0
- Formula now builds with `-DBUILD_CCAP_CLI=ON` flag
- Enhanced formula test to verify both library and CLI tool
- Improved GitHub Actions workflow to include release notes in auto-update PRs

### Upstream Changes (v1.4.0)
- 🛠️ New CLI tool for camera capture operations
- 🐛 Fixed ProviderImp::grab timeout to respect values < 1000ms
- ✨ Enhanced camera operations with standalone CLI interface

## [1.3.4] - 2025-12-14

### Changed
- Updated ccap to upstream version v1.3.4

### Upstream Changes (v1.3.4)
- 🐛 Fixed RGB24/BGR24 pixel format conversion issues and AVX2 instruction crashes
- 🪟 Improved frame orientation detection on Windows for all pixel formats
- ⚙️ Added `CCAP_WIN_NO_DEVICE_VERIFY` CMake option for Windows device verification control
- 📖 Enhanced web documentation with improved design
- 🌐 Improved internationalization in code comments and documentation

## [1.3.2] - 2025-12-XX

### Changed
- Initial public release of Homebrew tap
- Formula for ccap (CameraCapture) library

[1.7.0]: https://github.com/wysaid/homebrew-ccap/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/wysaid/homebrew-ccap/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/wysaid/homebrew-ccap/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/wysaid/homebrew-ccap/compare/v1.3.4...v1.4.0
[1.3.4]: https://github.com/wysaid/homebrew-ccap/releases/tag/v1.3.4
[1.3.2]: https://github.com/wysaid/homebrew-ccap/releases/tag/v1.3.2
