class Ccap < Formula
  desc "High-performance cross-platform camera capture library with hardware-accelerated pixel format conversion and complete C++/C APIs"
  homepage "https://github.com/wysaid/CameraCapture"
  url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "e617fd973c27f6f9a9f5ec831e4440430d5ae5fd2ab3a959b3a2ca7be031162e"
  license "MIT"
  head "https://github.com/wysaid/CameraCapture.git", branch: "main"

  depends_on "cmake" => :build

  # Platform-specific system dependencies
  # Note: ccap uses system frameworks/libraries, no additional brew packages needed
  on_macos do
    # macOS: Uses AVFoundation framework (linked automatically by CMake)
    # Frameworks: Foundation, AVFoundation, CoreVideo, CoreMedia, Accelerate
  end

  on_linux do
    # Linux: Uses V4L2 for camera capture (part of kernel)
    # pthread is linked automatically by CMake
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DCMAKE_INSTALL_PREFIX=#{prefix}",
           "-DCCAP_BUILD_EXAMPLES=OFF",
           "-DCCAP_BUILD_TESTS=OFF",
           "-DCCAP_INSTALL=ON",
           "-DCCAP_BUILD_CLI=ON",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Test the library API
    (testpath/"test.cpp").write <<~EOS
      #include <ccap.h>
      #include <iostream>
      #include <string>

      int main() {
          // Set error callback with std::string_view parameter (v1.3.2 API)
          ccap::setErrorCallback([](ccap::ErrorCode errorCode, std::string_view description) {
              std::cerr << "Camera Error - Code: 0x" << std::hex << static_cast<int>(errorCode) 
                        << ", Description: " << description << std::endl;
          });
          
          // Create provider and enumerate devices
          ccap::Provider provider;
          auto devices = provider.findDeviceNames();
          std::cout << "Found " << devices.size() << " camera device(s)" << std::endl;
          
          // List all available devices
          for (size_t i = 0; i < devices.size(); ++i) {
              std::cout << "  [" << i << "] " << devices[i] << std::endl;
          }
          
          return 0;
      }
    EOS

    # Platform-specific compilation flags
    if OS.mac?
      system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lccap",
             "-framework", "Foundation",
             "-framework", "AVFoundation",
             "-framework", "CoreVideo",
             "-framework", "CoreMedia",
             "-framework", "Accelerate",
             "-o", "test"
    elsif OS.linux?
      system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lccap",
             "-pthread",
             "-o", "test"
    end
    
    system "./test"
    
    # Test the CLI tool
    assert_match "ccap version", shell_output("#{bin}/ccap --version")
    assert_match "Usage:", shell_output("#{bin}/ccap --help")
  end
end
