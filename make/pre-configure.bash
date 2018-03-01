#! /bin/bash

cmake_file=$KAVRAKILAB_ENV_DIR/pkgs/CMakeLists.txt

echo "# This file was auto-generated by 'era-make'. Please do not edit by hand.
cmake_minimum_required(VERSION 2.8.3)
project(all)

include_directories(" > $cmake_file

for f in `ls $KAVRAKILAB_ENV_DIR/pkgs`
do
	if [ -f $KAVRAKILAB_ENV_DIR/pkgs/$f/CMakeLists.txt ]
	then
		echo "    \${CMAKE_CURRENT_SOURCE_DIR}/$f/include" >> $cmake_file
	fi
done

echo ")

# set(CMAKE_INSTALL_PREFIX /tmp)
set(BUILD_SHARED_LIBS shared)
set(EXECUTABLE_OUTPUT_PATH \${CMAKE_CURRENT_SOURCE_DIR}/../bin)
set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_MODULE_PATH \${CMAKE_CURRENT_SOURCE_DIR}/../cmake)
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY \${CMAKE_CURRENT_SOURCE_DIR}/../lib)
" >> $cmake_file

for f in `ls $KAVRAKILAB_ENV_DIR/pkgs`
do
	if [ -f $KAVRAKILAB_ENV_DIR/pkgs/$f/CMakeLists.txt ]
	then
		echo "add_subdirectory($f)" >> $cmake_file
	fi
done
