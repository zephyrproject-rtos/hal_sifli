# Copyright (c) 2025 Core Devices LLC
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
set -e

SIFLI_SDK=$1
if [ -z "$SIFLI_SDK" ]; then
	echo "Usage: $0 /path/to/SiFli_SDK"
	exit 1
fi

rm -rf cmsis hal

# HAL drivers
mkdir hal
cp -r $SIFLI_SDK/drivers/Include/ hal/include
cp -r $SIFLI_SDK/drivers/hal hal/src

# Remove HAL unwanted files
rm -rf \
	hal/src/SConscript \
	hal/src/*.sym

# CMSIS register definitions
mkdir cmsis
cp -r $SIFLI_SDK/drivers/cmsis/Include cmsis/
cp -r $SIFLI_SDK/drivers/cmsis/sf32lb52x cmsis/
cp $SIFLI_SDK/external/CMSIS/Include/core_mstar.h cmsis/Include

# Remove CMSIS unwanted files (including binary blobs, not allowed)
rm -rf \
	cmsis/sf32lb52x/ad9364.h \
	cmsis/sf32lb52x/ble_rf_fulcal_ad9364.c \
	cmsis/sf32lb52x/lcpu_patch_rev_b.c \
	cmsis/sf32lb52x/lcpu_patch.c \
	cmsis/sf32lb52x/SConscript \
	cmsis/sf32lb52x/spi_tst_drv.c \
	cmsis/sf32lb52x/spi_tst_drv.h \
	cmsis/sf32lb52x/Templates/arm \
	cmsis/sf32lb52x/Templates/gcc \
	cmsis/sf32lb52x/Templates/iar \

# Update revision file
SIFLI_REV=$(git -C "$SIFLI_SDK" rev-parse HEAD)
sed -i.bak "s/[a-z0-9]\{40\}/$SIFLI_REV/g" README.md
rm README.md.bak

echo "HAL updated successfully to revision $SIFLI_REV"
