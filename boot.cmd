# boot.cmd
# Set multi-console output
setenv stdout serial,vidconsole
setenv stderr serial,vidconsole
setenv stdin serial,usbkbd

# Continue with boot
usb start
dhcp
pxe get
pxe boot
