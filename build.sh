#!/bin/bash

name=rayimg
comp=gcc
src=*.c

flags=(
    -Wall
    -Wextra
    -std=c99
    -O2
)

inc=(
    -Iinclude/
)

lib=(
    -Llib/
    -lz
    -lpng
    -ljpeg
    -limgtool
    -lfract
)

mac_os=(
    -mmacosx-version-min=10.10
)

fail() {
    echo "Use with -comp to compile or -run to compile and execute"
    exit
}

build() {
    pushd libfract/
    ./build.sh -s
    popd
    pushd imgtool/
    ./build.sh -slib
    popd

    mkdir lib/
    mv libfract/libfract.a lib/libfract.a
    mv imgtool/libimgtool.a lib/libimgtool.a
}

comp() {
    if echo "$OSTYPE" | grep -q "darwin"; then
        $comp ${flags[*]} ${mac_os[*]} ${inc[*]} ${lib[*]} $src -o $name
    elif echo "$OSTYPE" | grep -q "linux"; then
        $comp ${flags[*]} ${inc[*]} ${lib[*]} -lm $src -o $name
    else
        echo "OS not supported yet"
        exit
    fi
}

clean() {
    rm -r lib/
    rm $name
    rm *.png
}

if [[ $# < 1 ]]; then
    fail
elif [[ "$1" == "-build" ]]; then
    build
    exit
elif [[ "$1" == "-comp" ]]; then
    build
    comp
    exit
elif [[ "$1" == "-run" ]]; then
    build
    comp
    ./$name
    exit
elif [[ "$1" == "-clean" ]]; then
    clean
    exit
else 
    fail
fi
