# OSDev Support
The purpose of this repository is to provide an access point/portal to various commonly used resources in my own OS Development projects, that can be easily accessed or used across various projects.

Overtime it will have GRUB template disk images added, toolchain build scripts, and various other useful scripts related to generic OS Dev.

### Current Limitations
The build scripts all assume a bash environment, and will only build GCC-4.9 and binutils-2.24.

### How to Use
It is very simple to use the script. By default the script will run with
default options matching the limitations mentioned previously.

    ./prepare

Get help on how to use the prepare script beyond default configuration

    ./prepare --help

### Using image
`./image` is a script that based on the parameters it is given will download one of the template disk images available in the repo. Currently it is limited to a FAT12, Floppy Disk image with GRUB 0.94 installed.

This script is slightly more complex to launch, and should be embedded into another shell script that calls it automatically.

    PROJ_ROOT=`pwd`
    URL="https://raw.githubusercontent.com/tjhancocks/osdev-support"
    URL="${URL}/master/image"
    SRC="$(curl -fsSL ${URL})"
    sh -c "${SRC}" -- --o="${PROJ_ROOT}/template-disk.img"

This will download the image script from the repo execute it and pass it the `--o` flag detailing where the disk image template should be placed.

### WARNING
The script will currently make no attempt to test if the environment its running in is valid. What it will do is test to see if you already have the requested tools installed. If you do, it will exit early.

### LICENSE
The MIT License (MIT)

Copyright (c) 2015 Tom Hancocks

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

