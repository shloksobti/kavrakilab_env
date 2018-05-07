#!/bin/bash

# check for git-extras
if [ ! -f /usr/local/bin/git-extras ]; then
	# https://github.com/tj/git-extras
	cd /tmp && git clone --depth 1 https://github.com/visionmedia/git-extras.git && cd git-extras && sudo make install

	# enable color
	git config --global color.ui true
fi

kavrakilab-install-system git
kavrakilab-install-system gitk
kavrakilab-install-system git-gui

# gitsu is installed as a ruby gem
#hash gem 2> /dev/null || sudo apt-get install -y ruby
#hash git-su 2> /dev/null || sudo gem install gitsu

# install the authors file
#if [ ! -f ~/.gitsu ]
#then
#    echo "linking ~/.gitsu"
#    ln -s $KAVRAKILAB_DIR/installer/targets/git/gitsu.txt ~/.gitsu
#fi

# install the global hooks
#if [ ! -d ~/.git_hooks ]
#then
#    echo "linking ~/.git_hooks"
#    ln -s $KAVRAKILAB_DIR/installer/targets/git/git_hooks ~/.git_hooks
#fi

# Update the hooks for all repos
#source $KAVRAKILAB_DIR/installer/targets/git/git-install-all-hooks
