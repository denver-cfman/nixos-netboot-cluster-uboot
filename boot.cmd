# boot.cmd
# 1. Initialize the network interface
dhcp

# 2. Set the server IP (optional, DHCP usually provides this)
# setenv serverip 192.168.1.10

# 3. Load the kernel/boot files via TFTP
# Using the standard PXE boot command is often more reliable
pxe get
pxe boot

# Fallback: if PXE fails, reset
reset
