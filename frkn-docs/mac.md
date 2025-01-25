pip install aqtinstall
aqt install-qt mac desktop 6.8 clang_64 -m qtremoteobjects qt5compat qtshadertools

Build the project:
```
git submodule update --init --recursive
mkdir build
cd build/
cmake .. -DQt6_DIR=~/Documents/6.8.1/macos/lib/cmake/Qt6 -DQt6QmlTools_DIR=~/Documents/6.8.1/macos/lib/cmake/Qt6QmlTools -G Ninja
ninja
```