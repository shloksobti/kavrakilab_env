#!/bin/bash

if ! hash grunt &> /dev/null
then
	# We need the nodejs package manager
	kavrakilab-install-target nodejs

	# Unfortunately this is necessary. kavrakilab-get only installs
	# system debs in the end (TODO: make nicer)
	sudo apt-get --assume-yes install nodejs

	sudo -H npm install -g grunt-cli
fi



