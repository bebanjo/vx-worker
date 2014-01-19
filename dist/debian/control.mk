Source: vx-worker
Section: ruby
Priority: optional
Maintainer: Dmitry Galinsky <dima.exe@gmail.com>
Build-Depends: debhelper (>= 9.0), vx-embeded-ruby, vx-embeded-bundler, git-core
Standards-Version: 3.9.3
Homepage: http://www.ruby-lang.org/

Package: %PACKAGE_NAME%
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, vx-embeded-ruby, vx-embeded-bundler, adduser
Description: Vexor worker.
