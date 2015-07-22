#!/bin/bash
# ColdKernel build script
# build 0.1a
# 4.0.8-grsec-coldkernel
# ColdHak (C. // J. // R. // T.)

source "$(pwd)/spinner.sh"

GRSECURITY=https://grsecurity.net/test/
GRSECURITY_VERSION="$(curl --silent https://grsecurity.net/testing_rss.php | sed -ne 's/.*\(http[^"]*\).patch/\1/p' | sed 's/<.*//' | sed 's/^.*grsecurity-3.1-4.0.8/grsecurity-3.1-4.0.8/' | sed -n '1p')"
KERNEL=https://www.kernel.org/pub/linux/kernel/v4.x
KERNEL_VERSION=linux-4.0.8

# Fetch Greg & Spender's keys
function get_keys () {
    gpg --recv-key 647F28654894E3BD457199BE38DBBDC86092693E
    gpg --recv-key DE9452CE46F42094907F108B44D1C0F82525FE49
}

# Fetch Linux Kernel sources and signatures
function get_kernel () {
    wget $KERNEL/$KERNEL_VERSION.tar.{sign,xz}
}

# Fetch Kernel patch sources and signatures
function get_patches () {
    wget $GRSECURITY/$GRSECURITY_VERSION.{patch.sig,patch}
}

# Unxz Kernel
function unpack_kernel () {
    unxz $KERNEL_VERSION.tar.xz
}

# Verify Linux Kernel sources
function verify_kernel () {
    gpg --verify $KERNEL_VERSION.{tar.sign,tar}
}

# Verify Kernel patches
function verify_patches () {
    gpg --verify $GRSECURITY_VERSION.{patch.sig,patch}
}

# Extract Linux Kernel
function extract_kernel () {
    tar -xvf $KERNEL_VERSION.tar
}

# Patch the kernel with grsec, and apply coldkernel config
function patch_kernel () {
    cd $KERNEL_VERSION &&
    patch -p1 < ../$GRSECURITY_VERSION.patch
    cp ../coldkernel.config .config
}

# Build coldkernel on Debian
function build_kernel () {
    fakeroot make deb-pkg
}

#	      /\
#	 __   \/   __
#	 \_\_\/\/_/_/
#	   _\_\/_/_
#	  __/_/\_\__
#	 /_/ /\/\ \_\
#	      /\
#	      \/
#
#  ______________________________
#  Do the coldkernel happy dance
#  ------------------------------

case "$1" in
                -v)
                get_keys &&
                get_kernel &&
                get_patches &&
                unpack_kernel &&
                verify_kernel &&
                verify_patches &&
                extract_kernel &&
                patch_kernel &&
                build_kernel
                exit 0;;
		
		*)
		start_spinner "Receiving signing keys..."
		get_keys > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Fetching kernel sources and signatures..."
		get_kernel > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Fetching grsecurity patch and signatures..."
		get_patches > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Unpacking Linux Kernel sources..."
		unpack_kernel > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Verifying the Linux Kernel sources..."
		verify_kernel > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Verifying Kernel patches..."
		verify_patches > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Extracting Linux Kernel sources..."
		extract_kernel > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Applying grsecurity patch, and moving coldkernel.config into place..."
		patch_kernel > /dev/null 2>&1 &&
		stop_spinner $?
		start_spinner "Building coldkernel..."
		build_kernel > /dev/null 2>&1
		stop_spinner $?
		exit 0;;
esac
