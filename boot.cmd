# boot.cmd
# Set multi-console output
setenv stdout serial,vidconsole
setenv stderr serial,vidconsole
setenv stdin serial,usbkbd

sleep 20
usb start
usb tree
net list
sleep 10
dhcp
pxe get
pxe boot
