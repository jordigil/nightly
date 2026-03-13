#!/bin/bash -e

echo "-- Builditto..."

cd ./eden
COUNT="$(git rev-list --count HEAD)"
EXE_NAME="Eden-${COUNT}"

echo "-- Builditto Configuration:"
echo "   Toolchain: ${TOOLCHAIN}"
echo "   Optimization: $OPTIMIZE"
echo "   Architecture: ${ARCH}"
echo "   Count: ${COUNT}"
echo "   Name: ${EXE_NAME}"

echo "-- Applying verision patcheaditto..."
patch -p1 < ../patcheaditto.patch

echo "   Doneditto."

declare -a BASE_CMAKE_FLAGS=(
    "-DBUILD_TESTING=OFF"
    "-DYUZU_USE_BUNDLED_QT=ON"
    "-DYUZU_STATIC_BUILD=ON"
    "-DYUZU_USE_BUNDLED_FFMPEG=ON"
    "-DENABLE_QT_TRANSLATION=ON"
    "-DENABLE_UPDATE_CHECKER=OFF"
    "-DUSE_DISCORD_PRESENCE=ON"
    "-DYUZU_CMD=OFF"
    "-DYUZU_ROOM=ON"
    "-DYUZU_ROOM_STANDALONE=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
)

declare -a EXTRA_CMAKE_FLAGS=(
    "-DNIGHTLY_BUILD=ON"
    "-DENABLE_LTO=OFF"
    "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
    "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache"
)

echo "-- Base CMake Flags:"
for flag in "${BASE_CMAKE_FLAGS[@]}"; do
    echo "   $flag"
done

echo "-- Extra CMake Flags:"
for flag in "${EXTRA_CMAKE_FLAGS[@]}"; do
    echo "   $flag"
done

echo "-- Starting builditto..."
mkdir -p build
cd build
cmake .. -G Ninja "${BASE_CMAKE_FLAGS[@]}" "${EXTRA_CMAKE_FLAGS[@]}"
ninja
echo "-- Builditto Completeaditto."

echo "-- Sccacheaditto Stats:"
sccache -s

echo "-- Cleanditto up..."
find bin -type f -name "*.pdb" -exec rm -fv {} +
rm -rf ./bin/plugins

echo "-- Packing builditto in the artifacto-defacto..."
cd bin
mv -v eden.exe "$EXE_NAME".exe
ZIP_NAME="$EXE_NAME.7z"
7z a -t7z -mx=9 "$ZIP_NAME" *
rm -v "$EXE_NAME".exe
echo "-- Packeteditto into $ZIP_NAME"

echo "=== ALL DONEDITTO! ==="
