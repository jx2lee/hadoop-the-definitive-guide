#!/bin/bash

run_dir=$(pwd -P)
dir_name=$1

if [ -z $dir_name ];
then
   echo "[ERROR] set data directory"
   echo "usage:" >&2
   echo "    $0 all" >&2
   exit 1
fi

function main() {
    for year in $run_dir/$dir_name/*
    do
      printf `basename $year .gz`'\t'
      gunzip -c $year | \
        awk '{ temp = substr($0, 88, 5) + 0;
               q = substr($0, 93, 1);
               if (temp !=9999 && q ~ /[01459]/ && temp > max) max = temp }
             END { print max }'
    done
}

main
