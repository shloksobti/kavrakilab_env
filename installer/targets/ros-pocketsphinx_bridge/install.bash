#!/bin/bash

if [ ! -d $HOME/.language_model/cmusphinx-en-us-8khz-5.2 ]
then
	rm -rf $HOME/.language_model
	mdkir -p $HOME/.language_model
	wget https://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/US%20English/cmusphinx-en-us-8khz-5.2.tar.gz --directory-prefix $HOME/.language_model
	tar zxvf $HOME/.language_model/cmusphinx-en-us-8khz-5.2.tar.gz -C $HOME/.language_model/
	rm $HOME/.language_model/cmusphinx-en-us-8khz-5.2.tar.gz
fi