class Libqglviewer < Formula
  desc "C++ Qt library to create OpenGL 3D viewers"
  homepage "http://www.libqglviewer.com/"
  url "http://www.libqglviewer.com/src/libQGLViewer-2.7.2.tar.gz"
  sha256 "e2d2799dec5cff74548e951556a1fa06a11d9bcde2ce6593f9c27a17543b7c08"

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
