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
    engine_cflags = "-Wno-writable-strings -Wno-format-security -Wno-deprecated-declarations --std=c++2a -pthread -L#{prefix}/include -I#{prefix}/include -L#{prefix}/include/asio -I#{prefix}/include/asio -fpermissive"

# 1. Temporarily expose the hidden keg-only .pc files to the build environment
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["ncurses"].opt_lib/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["curl"].opt_lib/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["lua@5.4"].opt_lib/"pkgconfig"

    # 2. Now pkg-config can read them perfectly without crashing
    ncurses_cflags = Utils.safe_popen_read("pkg-config", "--cflags", "ncursesw").chomp
    ncurses_libs   = Utils.safe_popen_read("pkg-config", "--libs", "ncursesw").chomp

    lua_cflags     = Utils.safe_popen_read("pkg-config", "--cflags", "lua-5.4").chomp
    lua_libs       = Utils.safe_popen_read("pkg-config", "--libs", "lua-5.4").chomp

    curl_cflags    = Utils.safe_popen_read("pkg-config", "--cflags", "libcurl").chomp
    curl_libs      = Utils.safe_popen_read("pkg-config", "--libs", "libcurl").chomp

    (buildpath/"gmeng.pc").write <<~EOS
      prefix=#{prefix}

      Name: gmeng
      Description: Gmeng Game Engine
      Version: #{version}
      Requires: sdl2, sdl2_ttf, sdl2_image
      Libs: -L${prefix} -L${prefix}/lib/bin #{ncurses_libs} #{lua_libs} #{curl_libs}
      Cflags: -I${prefix} -I${prefix}/lib/bin #{ncurses_cflags} #{lua_cflags} #{curl_cflags} #{engine_cflags}
    EOS

    (lib/"pkgconfig").install "gmeng.pc"
  end

  test do
    system "pkg-config", "--exists", "gmeng"

    assert_match "--std=c++2a", shell_output("pkg-config --cflags --libs gmeng")

    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <gmeng.h>

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
