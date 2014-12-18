#!/bin/sh

if [[ $# -lt 1 ]]; then
    echo "Usage:"
    echo "      r to run the local server"
    echo "      c to clean the local _site folder"
    exit
fi

if [[ $1 = "r" ]]; then
    jekyll s -w
elif [[ $1 = "c" ]]; then
    rm -fr _site
fi
