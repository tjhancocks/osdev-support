#!/bin/sh
# The MIT License (MIT)
# 
# Copyright (c) 2015 Tom Hancocks
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Options
PREFIX="$HOME/opt/cross"
TARGET="i686-elf"
DEST="/tmp/NovaOS"

SHOW_HELP="no"
FORCE_INSTALL="no"
PURGE="no"
for opt do
    case "$opt" in
    --prefix=*) prefix=`echo $opt | cut -d '=' -f 2`
    ;;
    --target=*) target=`echo $opt | cut -d '=' -f 2`
    ;;
    --force) force_install="yes"
    ;;
    --download) DEST=`echo $opt | cut -d '=' -f 2`
    ;;
    --purge) purge="yes"
    ;;
    --help) show_help="yes"
    ;;
    esac
done

if [[ ${SHOW_HELP} == "yes" ]]; then
cat <<EOF

Usage: ./toolchain/prepare [options]
Options: [defaults in brackets after descriptions]

In order for this tool to run correctly, you will need bash, homebrew and 
a working version of clang or gcc.

EOF
echo "Standard Options"
echo "--help        Display script options"
echo "--target      The architecture the toolchain should target [${TARGET}]"
echo "--prefix      Where the toolchain should placed [${PREFIX}]"
echo "--download    Where any required packages should be downloaded to"
echo "              [${DEST}]"
echo "--force       Forces the script to proceed even if the tools are already"
echo "              installed."
echo "--purge       Purges all previously downloaded packages."
exit 1
fi

# Test for the existance of homebrew. We need it!
BREW=`which brew`
if [[ -z "${BREW}" ]]; then
    echo "You require homebrew to proceed with this installation!"
    exit 1
fi

# Test for the existance of the tools we're making. Check if the user wants to
# proceed (if the prefix is different.)
COMPILER_PATH=`which ${TARG }-gcc`
if [[ ! -z "${COMPILER_PATH}" && ${FORCE_INSTALL} == "no" ]]; then
    echo "You already have the tools installed!"
    exit 1
fi


# Add to the path, and add it to the bash profile
export PATH="$PREFIX/bin:$PATH"

# Prepare the environment
export CC=gcc-4.9
export CXX=g++-4.9
export CPP=cpp-4.9
export LD=gcc-4.9

# Brew
if brew list -1 | grep -q "^gcc49\$"; then
    echo "\033[1;32mgcc49 already installed\033[0m"
else
    echo "\033[1;31mgcc49 not present... installing\033[0m"
    brew tap homebrew/versions
    brew install --enable-cxx  gcc49
fi

echo "\033[1;33mChecking for required libraries...\033[0m"
for PKG in mpfr gmp libmpc; do
    if brew list -1 | grep -q "^${PKG}\$"; then
        echo "\033[1;32m${PKG} already installed\033[0m"
    else
        echo "\033[1;31m${PKG} not present... installing\033[0m"
        brew install ${PKG}
    fi
done

# Download the sources
GCC_4_9_SOURCE="https://ftp.gnu.org/gnu/gcc/gcc-4.9.0/gcc-4.9.0.tar.gz"
BINUTILS_2_24_SOURCE="https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz"
GCC_ARCHIVE=${DEST}/gcc49.tar.gz
BIN_UTILS_ARCHIVE=${DEST}/binutils.tar.gz

# Ensure the destination folder exists
if [[ ${PURGE} == "yes" ]]; then
    rm -rf ${DEST}
fi

mkdir -p ${DEST}

if [[ ! -f ${BIN_UTILS_ARCHIVE} ]]; then
    echo "\033[1;36mDownloading ${BINUTILS_2_24_SOURCE}\033[0m"
    curl -# ${BINUTILS_2_24_SOURCE} > ${BIN_UTILS_ARCHIVE}
fi

if [[ ! -f ${GCC_ARCHIVE} ]]; then
    echo "\033[1;36mDownloading ${GCC_4_9_SOURCE}\033[0m"
    curl -# ${GCC_4_9_SOURCE} > ${GCC_ARCHIVE}
fi

# Unpack the packages and prepare for building the toolchain
BUILD_SRC=${DEST}/src
BIN_UTILS_DIR=${BUILD_SRC}/binutils-2.24-build
GCC_DIR=${BUILD_SRC}/gcc-4.9-build

mkdir -p ${BIN_UTILS_DIR} ${GCC_DIR}

echo "\033[1;33mExpanding downloaded packages\033[0m"
tar -zxf ${BIN_UTILS_ARCHIVE}
tar -zxf ${GCC_ARCHIVE}

echo "\033[1;33mConfiguring & Installing binutils\033[0m"
cd ${BIN_UTILS_DIR}
../binutils-2.24/configure --target=${TARGET} --prefix="${PREFIX}"\
    --disable-nls --disable-werror
make
make install

cd ..
