#!/usr/bin/env bash

# global parameters
tmp=".tmp"
output="all"

remote_host="ftp.ncdc.noaa.gov"
remote_path="pub/data/noaa"

dir=$(pwd -P)

start_year=$1
end_year=$2

function create_folder {
    if [ -d "$1" ]; then
        rm -rf "$1";
    fi
    mkdir "$1"
}

function download_data {
    local source_url="ftp://$remote_host/$remote_path/$1"
    wget -r -c -q --no-parent -P "$dir/$tmp" "$source_url";
}

function process_data {
    year=$1
    local_path="$dir/$tmp/$remote_host/$remote_path/$year"
    tmp_output_file="$dir/$tmp/$year"

    for file in $local_path/*; do
        gunzip -c $file >> "$tmp_output_file"
    done

    zipped_file="$dir/$output/$year.gz"
    gzip -c "$tmp_output_file" >> "$zipped_file"
    echo "[INFO][$0] created file: $zipped_file"

    rm -rf "$local_path"
    rm "$tmp_output_file"
}

function main {
    if [ -z $start_year ]; then
        echo "[ERROR] You set start year"
        echo "$0 {start_year} {end_year}"
        exit 1
    fi

    if [ -z $end_year ]; then
        echo "[ERROR] You set end year"
        echo "$0 {start_year} {end_year}"
        exit 1
    fi

    create_folder $dir/$tmp
    create_folder $dir/$output

    for year in `seq $start_year $end_year`; do
        download_data $year
        process_data $year
    done

    rm -rf "$dir/$tmp"
}

main 
