class Libqglviewer < Formula
  desc "C++ Qt library to create OpenGL 3D viewers"
  homepage "http://www.libqglviewer.com/"
  url "http://www.libqglviewer.com/src/libQGLViewer-2.7.2.tar.gz"
  sha256 "be611b87bdb8ba794a4d18eaed87f22491ebe198d664359829233c4ea69f4d02"

  head "https://github.com/GillesDebunne/libQGLViewer.git"

  depends_on "qt5"

  def install
    args = %W[
      PREFIX=#{prefix}
      DOC_DIR=#{doc}
    ]
    cd "QGLViewer" do
      system "qmake", *args
      system "make", "install"
    end
  end
end
