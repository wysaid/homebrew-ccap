class Ccap < Formula
  desc "High-performance cross-platform camera capture library with hardware-accelerated pixel format conversion and complete C++/C APIs"
  homepage "https://github.com/wysaid/CameraCapture"
  url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "81ee07fbada74ae338fb3b04b562851d37b9cd68071edc909ed8220b5d69d481"
  license "MIT"
  head "https://github.com/wysaid/CameraCapture.git", branch: "main"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCCAP_BUILD_EXAMPLES=OFF",
           "-DCCAP_BUILD_TESTS=OFF",
           "-DCCAP_INSTALL=ON",
           "-DCCAP_BUILD_CLI=ON",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <ccap.h>
      #include <iostream>

      int main() {
          ccap::Provider provider;
          auto devices = provider.findDeviceNames();
          std::cout << "Found " << devices.size() << " camera device(s)" << std::endl;
          return 0;
      }
    EOS

    if OS.mac?
      system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lccap",
             "-framework", "Foundation",
             "-framework", "AVFoundation",
             "-framework", "CoreVideo",
             "-framework", "CoreMedia",
             "-framework", "Accelerate",
             "-o", "test"
    else
      system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lccap",
             "-pthread",
             "-o", "test"
    end
    system "./test"

    assert_match version.to_s, shell_output("#{bin}/ccap --version")
  end
end
