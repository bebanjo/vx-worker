Source: %SOURCE_NAME%
Section: ruby
Priority: optional
Maintainer: Dmitry Galinsky <me@vexor.io>
Build-Depends: debhelper (>= 9.0), %RUBY%, %BUNDLER%, git-core, libxml2-dev
Standards-Version: 3.9.3

Package: %PACKAGE_NAME%
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, %RUBY%
Description: Vexor worker
