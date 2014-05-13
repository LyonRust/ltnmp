#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
ScriptName=${0##*/}
function print_usage() {
    echo "Please Use $ScriptName <directory>."
}
## Check the number of arguments.
if [ $# -ne 1 ]; then
print_usage
    exit 1
fi
## $1 - the static file directory.
function gzip_static_files() {
    filelist=`find $1 -maxdepth 88 \( -name "*.css" -o -name "*.js" -o -name "*.html" \) -type f`
    for file in $filelist
    do
        gzip -5 -f -c $file > $file.gz
    done
}
# gzip_static_files
gzip_static_files $1
exit 0