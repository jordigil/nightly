#!/bin/bash -e

echo "-- Building..."

cd ./eden
COUNT="$(git rev-list --count HEAD)"
EXE_NAME="Eden-${COUNT}"

echo "-- Build Configuration:"
echo "   ${EXE_NAME} ${TOOLCHAIN} ${ARCH} ${OPTIMIZE}"

echo "-- Applying version patch..."
patch -p1 < ../version.patch

echo "   Done."

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

echo "-- Base CMake Flags:"
for flag in "${BASE_CMAKE_FLAGS[@]}"; do
    echo "   $flag"
done

declare -a EXTRA_CMAKE_FLAGS=(
    "-DNIGHTLY_BUILD=ON"
    "-DENABLE_LTO=OFF"
    "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
    "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache"
)

echo "-- Extra CMake Flags:"
for flag in "${EXTRA_CMAKE_FLAGS[@]}"; do
    echo "   $flag"
done

echo "-- Starting build..."
mkdir -p build
cd build
cmake .. -G Ninja "${BASE_CMAKE_FLAGS[@]}" "${EXTRA_CMAKE_FLAGS[@]}"
ninja
echo "-- Build Completed."

echo "-- Sccache Stats:"
sccache -s

echo "-- Cleaning up..."
find bin -type f -name "*.pdb" -exec rm -fv {} +
rm -rf ./bin/plugins

echo "-- Packing build..."
cd bin
mv -v eden.exe "$EXE_NAME".exe
ZIP_NAME="$EXE_NAME.7z"
7z a -t7z -mx=9 "$ZIP_NAME" *
rm -v "$EXE_NAME".exe
echo "-- Packeted into $ZIP_NAME"

echo "=== ALL DONE! ==="
