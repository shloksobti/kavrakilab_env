#! /bin/bash

mkdir -p $KAVRAKILAB_ENV_DIR/cmake

# Generate cmake-files
for pkg in `ls $KAVRAKILAB_ENV_DIR/pkgs`
do
	if [ -f $KAVRAKILAB_ENV_DIR/pkgs/$pkg/CMakeLists.txt ]
	then
        libs=`find $KAVRAKILAB_ENV_DIR/build/$pkg -name *.so -o -name *.a`
		cmake_file=$KAVRAKILAB_ENV_DIR/cmake/${pkg}Config.cmake
		echo "set(${pkg}_INCLUDE_DIRS $KAVRAKILAB_ENV_DIR/pkgs/$pkg/include)" > $cmake_file
		echo "set(${pkg}_LIBRARIES $libs)" >> $cmake_file
	fi
done

