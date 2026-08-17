class Gmeng < Formula
  desc "DevKit & Source for Gmeng - the game engine"
  homepage "https://gmeng.org"

  url "https://github.com/catriverr/gmeng-sdk.git",
    tag:      "12.0.0",
    revision: "35b8ec093d7f9971a70ec1b3579a31bcba82557e"
  version "12.0.0"
  license "Zlib"

  depends_on "curl"
  depends_on "ncurses"
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "sdl2_ttf"
  depends_on "lua@5.4"

  def install
    (include/"gmeng").install "lib"
    (include/"gmeng").install "include"
    (include/"gmeng").install "envs"
    (include/"gmeng").install "assets"
    (include/"gmeng").install "scripts"
    (include/"gmeng").install "makefile"
    engine_cflags = "Wno-literal-suffix -Wno-switch-bool -Wno-literal-suffix -Wno-writable-strings -Wno-format-security -Wno-deprecated-declarations --std=c++2a -pthread -L#{prefix}/include -I#{prefix}/include -L#{prefix}/include/asio -I#{prefix}/include/asio -fpermissive"

    (buildpath/"gmeng.pc").write <<~EOS
      prefix=#{prefix}

      Name: gmeng
      Description: Gmeng Game Engine
      Version: #{version}
      Requires: sdl2, sdl2_ttf, sdl2_image, ncursesw, lua-5.4, libcurl
      Libs: -L${prefix} -L${prefix}/lib/bin
      Cflags: -framework ApplicationServices -framework AudioUnit -framework CoreAudio -framework AudioToolbox I${prefix} -I${prefix}/lib/bin #{engine_cflags}
    EOS

    (lib/"pkgconfig").install "gmeng.pc"
  end

  test do
    system "pkg-config", "--exists", "gmeng"

    assert_match "--std=c++2a", shell_output("pkg-config --cflags --libs gmeng")

    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <gmeng/gmeng.h>

      int main(int argc, char** argv) {
        std::cout << "gmeng.h header imports no error" << std::endl;
        std::cout << "gmeng.h passes brew test" << std::endl;
        return 0;
      };
    EOS

    flags = shell_output("pkg-config --cflags --libs gmeng").strip.split
    system ENV.cxx, "test.cpp", *flags, "-o", "test"
    system "./test"
  end
end
