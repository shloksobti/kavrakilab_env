#!/bin/bash

if [ ! -f /usr/bin/z3 ]
then
	git clone https://github.com/Z3Prover/z3.git ~/.z3
	cd ~/.z3
	python scripts/mk_make.py
	cd build
	make
	sudo make install 
fi
