class Dgtal < Formula
  desc "Digital Geometry Tools and Algorithms"
  homepage "https://dgtal.org/"
  url "https://github.com/DGtal-team/DGtal/archive/1.0.tar.gz"
  sha256 "8a30974631e235b243f2063754c6deb56d56e2b1bcbb1c4dc9a8afadba23d2bc"
  revision 1
  head "https://github.com/DGtal-team/DGtal.git"

  bottle :disable, "needs to be rebuilt with latest boost"

  option "with-test", "Build the unitary tests"
  option "without-examples", "Don't build the examples"

  deprecated_option "with-eigen@3.2" => "with-eigen"
  deprecated_option "with-eigen32" => "with-eigen"
  deprecated_option "with-magick" => "with-graphicsmagick"

  depends_on "cmake" => :build
  boost_args = []
  boost_args << "c++11" if MacOS.version < "10.9"
  depends_on "boost" => boost_args
  depends_on "eigen" => :optional
  depends_on "gmp" => :optional
  depends_on "cairo" => :optional
  depends_on "graphicsmagick" => :optional
  depends_on "cgal" => [:optional, "with-eigen"]

  # GCC 4 works, and according to upstream issue, GCC <= 5.2.1 may also be fine
  ["5", "6"].each do |n|
    fails_with :gcc => n do
      cause "testClone2 fails: https://github.com/DGtal-team/DGtal/issues/1203"
    end
  end

  def install
    ENV.cxx11
    args = std_cmake_args
    args << "-DBUILD_TESTING=ON" if build.with? "test"
    args << "-DBUILD_EXAMPLES=OFF" if build.without? "examples"
    args << "-DWITH_EIGEN=true" if build.with? "eigen"
    args << "-DWITH_GMP=true" if build.with? "gmp"
    args << "-DWITH_CAIRO=true" if build.with? "cairo"
    args << "-DWITH_MAGICK=true" if build.with? "graphicsmagick"

    if build.with? "cgal"
      args << "-DWITH_EIGEN=true" << "-DWITH_GMP=true" << "-DWITH_CGAL=true"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.with? "test"
      system "make", "install"
    end
    pkgshare.install "examples"
  end

  test do
    (testpath/"helloworld.cpp").write <<-EOS.undent
      #include "DGtal/base/Common.h"
      #include "DGtal/helpers/StdDefs.h"
      using namespace std;
      using namespace DGtal;
      int main() {
        typedef double Ring;
        Z2i::Point a(0,0), b(10,10);
        Z2i::Domain dom(a,b);
        if (dom.isInside(Point(2,3)))
         {
           std::cout <<"All good."<<std::endl;
           return 0;
         }
        else 
         return 1;
      }
    EOS
    system ENV.cxx, "helloworld.cpp", "-o", "helloworld", "-lDGtal", "-L#{lib}"
    output = shell_output("./helloworld").chomp
    assert_equal "All good.", output
  end
end
