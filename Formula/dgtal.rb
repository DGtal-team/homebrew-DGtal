class Dgtal < Formula
  desc "Digital Geometry Tools and Algorithms"
  homepage "https://dgtal.org/"
  url "https://github.com/DGtal-team/DGtal/archive/1.1.tar.gz"
  sha256 "6dd99833c24f25ac4ed4aa489a5803f7f2dd6713d6ba86c6cc69b252f7399c84"
  revision 1
  head "https://github.com/DGtal-team/DGtal.git"

  bottle :disable, "needs to be rebuilt with latest boost"

  option "with-test", "Build the unitary tests"
  option "with-examples", "Build the examples"

  deprecated_option "with-eigen@3.2" => "with-eigen"
  deprecated_option "with-eigen32" => "with-eigen"
  deprecated_option "with-magick" => "with-graphicsmagick"

  depends_on "cmake" => :build
  boost_args = []
  boost_args << "c++11" if MacOS.version < "10.9"
  depends_on "boost" => boost_args
  depends_on "cairo" => :optional
  depends_on "cgal" => :optional
  depends_on "eigen" => :optional
  depends_on "gmp" => :optional
  depends_on "graphicsmagick" => :optional

  # GCC 4 works, and according to upstream issue, GCC <= 5.2.1 may also be fine
  ["5", "6"].each do |n|
    fails_with gcc: n do
      cause "testClone2 fails: https://github.com/DGtal-team/DGtal/issues/1203"
    end
  end

  def install
    ENV.cxx11
    args = std_cmake_args
    args << "-DBUILD_EXAMPLES=OFF"
    args << "-DBUILD_TESTING=ON" if build.with? "test"
    args << "-DBUILD_EXAMPLES=ON" if build.with? "examples"
    args << "-DWITH_EIGEN=true" if build.with? "eigen"
    args << "-DWITH_GMP=true" if build.with? "gmp"
    args << "-DWITH_CAIRO=true" if build.with? "cairo"
    args << "-DWITH_MAGICK=true" if build.with? "graphicsmagick"
    args << "-DWITH_EIGEN=true" << "-DWITH_GMP=true" << "-DWITH_CGAL=true" if build.with? "cgal"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.with? "test"
      system "make", "install"
    end
    pkgshare.install "examples"
  end

  test do
    (testpath/"helloworld.cpp").write <<~EOS
      #include <iostream>
      #include <DGtal/base/Common.h>
      #include <DGtal/helpers/StdDefs.h>
      using namespace std;
      using namespace DGtal;
      int main() {
        typedef double Ring;
        Z2i::Point a(0,0), b(10,10);
        Z2i::Domain dom(a,b);
        if (dom.isInside(Z2i::Point(2,3))) {
          std::cout <<"All good."<<std::endl;
          return 0;
        }
        else
          return 1;
      }
    EOS
    system ENV.cxx, "helloworld.cpp", "-std=c++11", "-o", "helloworld", "-lDGtal", "-L#{lib}"
    output = shell_output("./helloworld").chomp
    assert_equal "All good.", output
  end
end
