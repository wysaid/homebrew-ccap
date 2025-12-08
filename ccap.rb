class Ccap < Formula
  desc "High-performance cross-platform camera capture library with hardware-accelerated pixel format conversion and complete C++/C APIs"
  homepage "https://github.com/wysaid/CameraCapture"
  url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "891afda9a6c2d47654e9cbd76c971a0e15ff3ab29b30078d89546a3a595f649c"
  license "MIT"
  head "https://github.com/wysaid/CameraCapture.git", branch: "main"

  depends_on "cmake" => :build
  depends_on :macos

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DCMAKE_INSTALL_PREFIX=#{prefix}",
           "-DCCAP_BUILD_EXAMPLES=OFF",
           "-DCCAP_BUILD_TESTS=OFF",
           "-DCCAP_INSTALL=ON",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
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

    system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lccap",
           "-framework", "Foundation",
           "-framework", "AVFoundation",
           "-framework", "CoreVideo",
           "-framework", "CoreMedia",
           "-framework", "Accelerate",
           "-o", "test"
    system "./test"
  end
end
