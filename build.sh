#!/bin/bash

name=rayimg
cc=gcc
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
    -limgtool
    -lfract
    -lz
    -lpng
    -ljpeg
)

mac_os=(
    -mmacosx-version-min=10.10
)

fail() {
    echo "Use with -comp to compile or -run to compile and execute"
    exit
}

build_lib() {
    pushd $1/ && ./build.sh $2 && mv *.a ../lib/ && popd
}

build() {
    mkdir lib/
    build_lib fract -s
    build_lib imgtool -slib
}

comp() {
    if echo "$OSTYPE" | grep -q "darwin"; then
        $cc $src -o $name ${flags[*]} ${mac_os[*]} ${inc[*]} ${lib[*]}
    elif echo "$OSTYPE" | grep -q "linux"; then
        $cc $src -o $name ${flags[*]} ${inc[*]} ${lib[*]} -lm
    else
        echo "OS not supported yet" && exit
    fi
}

clean() {
    rm -r lib/ && rm $name
}

case "$1" in
    "-build")
        build;;
    "-comp")
        build && comp;;
    "-run")
        build && comp && ./$name "$@";;
    "-clean")
        clean;;
    *)
        fail;;
esac
