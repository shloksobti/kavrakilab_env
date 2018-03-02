if [ ! -d ~/.config/terminator ]
then
    kavrakilab-install-debug "creating ~/.config/terminator, because not existing yet"
    mkdir -p ~/.config/terminator
else
    kavrakilab-install-debug "~/.config/terminator already exists"
fi

if [ -f ~/.config/terminator/config ]
then
    kavrakilab-install-debug "kavrakilab-install-cp config ~/.config/terminator/config2"
    kavrakilab-install-cp config ~/.config/terminator/config2
else
    kavrakilab-install-debug "kavrakilab-install-cp config ~/.config/terminator/config"
    kavrakilab-install-cp config ~/.config/terminator/config
fi
