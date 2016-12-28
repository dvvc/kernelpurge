#!/bin/bash

# Get current kernel version
CURRENT_KERNEL=`uname -r | sed -e 's/-generic//'`

# Get installed kernels
INSTALLED_KERNELS=`dpkg-query -l | grep -E ^ii | grep -v generic | grep linux-headers | awk '{ print $2 }' | sed -e 's/linux-headers-//' | sort -r`

#echo $INSTALLED_KERNELS
KERNEL_COUNT=`echo $INSTALLED_KERNELS | tr " " "\n" | wc -l`
LATEST_KERNEL=`echo $INSTALLED_KERNELS | tr " " "\n" | head -1`
OTHER_KERNELS=`echo $INSTALLED_KERNELS | tr " " "\n" | tail -$((KERNEL_COUNT-1))`

echo "Current version: ${CURRENT_KERNEL}"
echo "Installed versions: `echo ${INSTALLED_KERNELS}`"
echo "Latest kernel: ${LATEST_KERNEL}"
echo "Old kernels: ${OTHER_KERNELS}"

echo ""

if [[ $KERNEL_COUNT == "1" ]]; then
    echo "There are no kernels to clean up"
    exit 0
fi

if [[ $CURRENT_KERNEL != $LATEST_KERNEL ]]; then
    echo "You are not using the latest kernel. Reboot before purging"
    exit 1
fi

# There is more than one kernel installed, and the one we are using is the latest.
# We can clean up all the other kernels

PACKAGES=""
for v in `echo ${OTHER_KERNELS}`; do
    PACKAGES="${PACKAGES} linux-headers-${v} linux-headers-${v}-generic linux-image-${v}-generic linux-image-extra-${v}-generic linux-signed-image-${v}-generic"
done

COMMAND="sudo apt-get remove --purge -y ${PACKAGES}"

echo "The system has some old kernel files installed: ${OTHER_KERNELS}"
echo "If you choose to purge them, the following command will be executed:"
echo "${COMMAND}"
echo "Do you want to purge the old kernels? [y/N]"

read ANSWER

if [[ $ANSWER == 'y' ]]; then
    $COMMAND
else
    echo "Operation aborted"
    exit 0
fi

echo "Old kernels are cleaned, have a nice day!"
