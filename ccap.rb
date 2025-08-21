class Ccap < Formula
  desc "High-performance cross-platform camera capture library with hardware-accelerated pixel format conversion and complete C++/C APIs"
  homepage "https://github.com/wysaid/CameraCapture"
  url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "5a07e6e8c4e6e37e0444025f9ca02223738b133c0529cb34a27c6668632b361f"
  license "MIT"
  head "https://github.com/wysaid/CameraCapture.git", branch: "main"

  depends_on "cmake" => :build
  # Linux is not supported yet
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

      int main() {
          // Set error callback (available since v1.2.0)
          ccap::setErrorCallback([](ccap::ErrorCode errorCode, const std::string& description) {
              std::cerr << "Camera Error - Code: " << static_cast<int>(errorCode) 
                        << ", Description: " << description << std::endl;
          });
          
          ccap::Provider provider;
          auto devices = provider.findDeviceNames();
          std::cout << "Found " << devices.size() << " camera device(s)" << std::endl;
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
