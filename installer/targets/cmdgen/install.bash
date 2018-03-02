#!/bin/bash

if [ ! -d ~/src/GPSRCmdGen ]
then
    kavrakilab-install-debug "GPSRCmdGen not yet installed"
    echo "Installing GPSRCmdGen to ~/src/GPSRCmdGen"

    echo "Installing dependency of GPSRCmdGen: mono-complete"
    sudo apt-get install --assume-yes mono-complete

    kavrakilab-install-git http://github.com/kyordhel/GPSRCmdGen.git ~/src/GPSRCmdGen

    echo "Making GPSRCmdGen"
    cd ~/src/GPSRCmdGen
    make

    kavrakilab-install-info "GPSRCmdGen is only pulled and maked once. In the future you have to do this yourself.
               cd ~/src/GPSRCmdGen
               make"
else
    kavrakilab-install-debug "GPSRCmdGen already installed"
fi
