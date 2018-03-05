#!/bin/bash

if ! hash bower &> /dev/null
then
    # We need the nodejs package manager
    kavrakilab-install-target nodejs

    # Unfortunately this is necessary. kavrakilab-get only installs
    # system debs in the end (TODO: make nicer)
    sudo apt-get install --assume-yes nodejs

	sudo -H npm install -g bower
fi



