# boot.cmd
# 1. Initialize USB bus
usb start

# 2. Force probing of all USB devices
usb reset

# 3. List devices to verify the network interface is bound
# If this doesn't show an 'eth' device, the driver is missing
dm tree

# 4. Attempt to initialize the network interface
# Some boards require this to bind the driver to the USB device
setenv autoload no
dhcp

# 5. Proceed with PXE
pxe get
pxe boot
