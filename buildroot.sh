#!/bin/zsh

BUILDROOT_OUTPUT="$(realpath ../car-thing-buildroot/output)"
TARGET_DIR="$BUILDROOT_OUTPUT/target"
HOST_DIR="$BUILDROOT_OUTPUT/host"
HOST_BIN_DIR="$HOST_DIR/bin"
BR_GCC_BASE="$HOST_BIN_DIR/arm-buildroot-linux-gnueabihf"
export SYSROOT="$HOST_DIR/arm-buildroot-linux-gnueabihf/sysroot"

echo $SYSROOT

export AR="$BR_GCC_BASE-gcc-ar"
export AS="$BR_GCC_BASE-as"
export LD="$BR_GCC_BASE-ld"
export NM="$BR_GCC_BASE-gcc-nm"
export CC="$BR_GCC_BASE-gcc"
export GCC="$CC"
export CXX="$BR_GCC_BASE-g++"
export CPP="$BR_GCC_BASE-cpp"
export FC="$BR_GCC_BASE-gfortran"
export F77="$FC"
export RANLIB="$BR_GCC_BASE-gcc-ranlib"
export READELF="$BR_GCC_BASE-readelf"
export OBJCOPY="$BR_GCC_BASE-objcopy"
export OBJDUMP="$BR_GCC_BASE-objdump"
export PKG_CONFIG="$HOST_BIN_DIR/pkg-config"

export LIBS="-L"${SYSROOT}"/usr/lib"
export CFLAGS="-I"${SYSROOT}"/usr/include"
export COMPILER=gcc

make TARGET_CT=1 -j4 || exit 1

adb shell supervisorctl stop superbird

DEPLOY_ROOT="/debian-root/sm64ex/build/us_pc/sm64"

adb shell rm -rf "$DEPLOY_ROOT" || exit 1
adb shell mkdir -p "$DEPLOY_ROOT" || exit 1
adb push build/us_pc/sm64 "$DEPLOY_ROOT/" || exit 1
adb shell chmod +wx "$DEPLOY_ROOT/sm64"

#adb push "$TARGET_DIR/usr/lib/libSDL2-2.0.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libSDL2_gfx-1.0.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libSDL2_image-2.0.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libGLESv2.so.2" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libglapi.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libX11.so.6" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libxcb.so.1" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libXau.so.6" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libXdmcp.so.6" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libEGL.so.1" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libgbm.so.1" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libwayland-client.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libwayland-server.so.0" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libffi.so.8" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libdrm.so.2" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libGLESv2.so.2" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libdirectfb.so" "$DEPLOY_ROOT/"
#adb push "$TARGET_DIR/usr/lib/libdirectfb-1.7.so.7" "$DEPLOY_ROOT/"

#read -r -d '' EXEC_SCRIPT << 'EOF'
##!/bin/sh
#cd "/sm64ex"
#
##sleep 5s
##/etc/init.d/S95supervisord stop
##sleep 5s
#
#export LD_LIBRARY_PATH="$(realpath .)"
#
#PS_RESULT="$(ps)"
#for pid in $(echo "$PS_RESULT" | grep '\./sm64' | cut -d' ' -f 1); do
#  echo "Killing old process: $pid"
#  kill $pid
#done
#
#echo 1 > /sys/class/graphics/fb0/osd_clear
#
#./sm64 "$@"
#EOF
#
#adb push =(echo "$EXEC_SCRIPT") "$DEPLOY_ROOT/exec.sh"
#adb push =(echo "$EXEC_SCRIPT") "/etc/init.d/S90sm64"
#adb shell chmod +x "$DEPLOY_ROOT/exec.sh"
#adb shell chmod +x "/etc/init.d/S90sm64"

#adb shell "$DEPLOY_ROOT/exec.sh"
