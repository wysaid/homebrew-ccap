# typed: strict
# frozen_string_literal: true

# Formula for ccap camera capture library
class Ccap < Formula
  desc "High-performance, lightweight cross-platform C++ camera capture library"
  homepage "https://github.com/wysaid/CameraCapture"
  url "https://github.com/wysaid/CameraCapture/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "f0c5e3e6144414df531394286ab2e7632f345d97b4cc561eb0ffea6476c5035f"
  license "MIT"
  head "https://github.com/wysaid/CameraCapture.git", branch: "main"

  depends_on "cmake" => :build
  depends_on macos: :high_sierra # macOS 10.13+

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
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
