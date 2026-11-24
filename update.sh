# Copyright (c) 2025 Core Devices LLC
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
set -e

SIFLI_SDK=$1
if [ -z "$SIFLI_SDK" ]; then
	echo "Usage: $0 /path/to/SiFli_SDK"
	exit 1
fi

rm -rf cmsis hal ipc_queue ll

# HAL drivers
mkdir hal
cp -r $SIFLI_SDK/drivers/Include/ hal/include
cp -r $SIFLI_SDK/drivers/hal hal/src

# Remove HAL unwanted files
rm -rf \
	hal/src/SConscript \
	hal/src/*.sym

# LL headers
mkdir ll
cp -r $SIFLI_SDK/drivers/ll/sf32lb52x ll/

# Remove LL unwanted files
rm -rf \
	ll/sf32lb52x/SConscript \
	ll/sf32lb52x/ll_gpio_ex.h

mkdir ipc_queue
cp -r $SIFLI_SDK/middleware/ipc_queue/common ipc_queue/common
cp -r $SIFLI_SDK/middleware/ipc_queue/include/*.h ipc_queue/common
cp -r $SIFLI_SDK/middleware/ipc_queue/porting/sf32lb52x/hcpu ipc_queue/sf32lb52x
cp -r $SIFLI_SDK/middleware/include/sf_type.h ipc_queue/common

# Remove ipc_queue unwanted files
rm -rf \
	ipc_queue/common/SConscript \
	ipc_queue/sf32lb52x/SConscript 


# CMSIS register definitions
mkdir cmsis
cp -r $SIFLI_SDK/drivers/cmsis/Include cmsis/
cp -r $SIFLI_SDK/drivers/cmsis/sf32lb52x cmsis/
cp -r $SIFLI_SDK/middleware/bluetooth/patch/sf32lb52/*.c cmsis/sf32lb52x
cp $SIFLI_SDK/external/CMSIS/Include/core_mstar.h cmsis/Include

# Remove CMSIS unwanted files (including binary blobs, not allowed)
rm -rf \
	cmsis/sf32lb52x/ad9364.h \
	cmsis/sf32lb52x/ble_rf_fulcal_ad9364.c \
	cmsis/sf32lb52x/SConscript \
	cmsis/sf32lb52x/lcpu_patch.c \
	cmsis/sf32lb52x/lcpu_patch_rev_b.c \
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
