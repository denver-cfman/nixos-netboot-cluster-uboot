# boot.cmd
# Set multi-console output
setenv stdout serial,vidconsole
setenv stderr serial,vidconsole
setenv stdin serial,usbkbd
echo "we need to wait 20 sec for the auto neg to work on the network switch"
sleep 20
usb start
usb tree
net list
echo "we need to wait 20 sec for the auto neg to work on the network switch"
sleep 15
dhcp
# Example boot.cmd for debugging
echo "--- Starting Netboot ---"
echo "Setting up network..."
dhcp
echo "Network configured, attempting to load kernel..."
tftpboot ${kernel_addr_r} kernel.img
echo "Kernel loaded to ${kernel_addr_r}"
booti ${kernel_addr_r} - ${fdt_addr_r}
echo "Boot command executed!"
echo "Verifying variables: IP=${ipaddr} Server=${serverip} Kernel=${kernel_addr_r}"
pxe get
pxe boot
