if [ ! -f /etc/udev/rules.d/99-arduino-usb.rules ]
then
    sudo kavrakilab-install-cp udev-rules/* /etc/udev/rules.d/
fi
